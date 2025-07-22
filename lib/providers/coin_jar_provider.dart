import 'package:flutter/material.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../services/bank_simulation_service.dart';
import '../services/card_service.dart';

class CoinJarProvider extends ChangeNotifier {
  double _totalSavings = 0.0;
  List<Transaction> _transactions = [];
  double _weeklyGoal = 25.0;
  bool _isLoading = true;
  
  // Filtering and search
  String _searchQuery = '';
  String _selectedCategory = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  double get totalSavings => _totalSavings;
  List<Transaction> get transactions => List.unmodifiable(_filteredTransactions);
  List<Transaction> get allTransactions => List.unmodifiable(_transactions);
  double get weeklyGoal => _weeklyGoal;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  List<Transaction> get _filteredTransactions {
    List<Transaction> filtered = List.from(_transactions);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.merchantName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               transaction.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((transaction) => transaction.category == _selectedCategory).toList();
    }

    // Apply date range filter
    if (_startDate != null) {
      filtered = filtered.where((transaction) => transaction.timestamp.isAfter(_startDate!)).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((transaction) => transaction.timestamp.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }

    return filtered;
  }

  List<String> get availableCategories {
    final categories = _transactions.map((t) => t.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }
  
  double get weeklyProgress {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyTotal = _transactions
        .where((t) => t.timestamp.isAfter(weekStart))
        .fold(0.0, (sum, t) => sum + t.spareChange);
    return (weeklyTotal / _weeklyGoal).clamp(0.0, 1.0);
  }

  double get weeklyTotal {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _transactions
        .where((t) => t.timestamp.isAfter(weekStart))
        .fold(0.0, (sum, t) => sum + t.spareChange);
  }

  double get monthlyTotal {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return _transactions
        .where((t) => t.timestamp.isAfter(monthStart))
        .fold(0.0, (sum, t) => sum + t.spareChange);
  }

  double get averageTransaction {
    if (_transactions.isEmpty) return 0.0;
    return _totalSavings / _transactions.length;
  }

  CoinJarProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _totalSavings = await StorageService.getTotalSavings();
      _weeklyGoal = await StorageService.getWeeklyGoal();
      _transactions = await StorageService.getTransactions();
      
      // Generate mock data if no transactions exist (for demo purposes)
      if (_transactions.isEmpty) {
        await _generateMockTransactions();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading coin jar data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction({
    required double originalAmount,
    required String merchantName,
    required String category,
  }) async {
    try {
      final roundedAmount = originalAmount.ceilToDouble();
      final spareChange = roundedAmount - originalAmount;
      
      final transaction = Transaction(
        id: const Uuid().v4(),
        amount: originalAmount,
        spareChange: spareChange,
        merchant: merchantName,
        date: DateTime.now(),
        category: category,
      );
      
      _transactions.insert(0, transaction);
      _totalSavings += spareChange;
      
      await StorageService.addTransaction(transaction);
      await StorageService.setTotalSavings(_totalSavings);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      final transaction = _transactions.firstWhere((t) => t.id == transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
      _totalSavings -= transaction.spareChange;
      
      await StorageService.deleteTransaction(transactionId);
      await StorageService.setTotalSavings(_totalSavings);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  Future<void> setWeeklyGoal(double goal) async {
    try {
      _weeklyGoal = goal;
      await StorageService.setWeeklyGoal(goal);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting weekly goal: $e');
    }
  }

  Future<void> addSpareChange(double amount) async {
    try {
      _totalSavings += amount;
      await StorageService.setTotalSavings(_totalSavings);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding spare change: $e');
    }
  }

  // Filtering and search methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  // Analytics methods
  Map<String, double> getCategoryBreakdown() {
    final breakdown = <String, double>{};
    for (final transaction in _transactions) {
      breakdown[transaction.category] = (breakdown[transaction.category] ?? 0) + transaction.spareChange;
    }
    return breakdown;
  }

  // Card integration features
  Future<void> monitorCardTransactions() async {
    try {
      final newTransactions = await CardService.monitorCardTransactions();
      
      for (final transaction in newTransactions) {
        await addCardTransaction(transaction);
      }
      
      if (newTransactions.isNotEmpty) {
        debugPrint('Added ${newTransactions.length} new card transactions');
      }
    } catch (e) {
      debugPrint('Error monitoring card transactions: $e');
    }
  }

  Future<void> addCardTransaction(Transaction transaction) async {
    try {
      _transactions.insert(0, transaction);
      _totalSavings += transaction.spareChange;
      
      await StorageService.addTransaction(transaction);
      await StorageService.setTotalSavings(_totalSavings);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding card transaction: $e');
    }
  }

  // Bank integration features
  Future<List<BankAccount>> getConnectedAccounts() async {
    try {
      return await BankSimulationService.getConnectedAccounts();
    } catch (e) {
      debugPrint('Error fetching connected accounts: $e');
      return [];
    }
  }

  Future<bool> connectBankAccount(String bankName, String username, String password) async {
    try {
      return await BankSimulationService.connectBankAccount(bankName, username, password);
    } catch (e) {
      debugPrint('Error connecting bank account: $e');
      return false;
    }
  }

  Future<List<Transaction>> importTransactions({
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final importedTransactions = await BankSimulationService.importTransactions(
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
      );

      // Add imported transactions to our local storage
      for (final transaction in importedTransactions) {
        await addImportedTransaction(transaction);
      }

      return importedTransactions;
    } catch (e) {
      debugPrint('Error importing transactions: $e');
      return [];
    }
  }

  Future<void> addImportedTransaction(Transaction transaction) async {
    try {
      _transactions.insert(0, transaction);
      _totalSavings += transaction.spareChange;
      
      await StorageService.addTransaction(transaction);
      await StorageService.setTotalSavings(_totalSavings);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding imported transaction: $e');
    }
  }

  Future<List<BankInfo>> getAvailableBanks() async {
    try {
      return await BankSimulationService.getAvailableBanks();
    } catch (e) {
      debugPrint('Error fetching available banks: $e');
      return [];
    }
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) => 
      t.timestamp.isAfter(start) && 
      t.timestamp.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  // Mock data generator for demo purposes
  Future<void> _generateMockTransactions() async {
    final random = Random();
    final merchants = [
      'Starbucks', 'Target', 'Amazon', 'Walmart', 'McDonald\'s', 
      'Shell', 'Uber', 'Grocery Store', 'Coffee Shop', 'Gas Station'
    ];
    final categories = [
      'Food & Dining', 'Shopping', 'Gas & Fuel', 'Entertainment', 
      'Transportation', 'Groceries', 'Coffee', 'Fast Food'
    ];
    
    for (int i = 0; i < 12; i++) {
      final originalAmount = 5.0 + random.nextDouble() * 45.0;
      final roundedAmount = originalAmount.ceilToDouble();
      final spareChange = roundedAmount - originalAmount;
      
      final transaction = Transaction(
        id: const Uuid().v4(),
        amount: originalAmount,
        spareChange: spareChange,
        merchant: merchants[random.nextInt(merchants.length)],
        date: DateTime.now().subtract(Duration(
          days: random.nextInt(30),
          hours: random.nextInt(24),
          minutes: random.nextInt(60),
        )),
        category: categories[random.nextInt(categories.length)],
      );
      
      _transactions.add(transaction);
      _totalSavings += spareChange;
    }
    
    _transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    await StorageService.saveTransactions(_transactions);
    await StorageService.setTotalSavings(_totalSavings);
  }
}