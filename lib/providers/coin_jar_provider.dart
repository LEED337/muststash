import 'package:flutter/material.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class CoinJarProvider extends ChangeNotifier {
  double _totalSavings = 0.0;
  List<Transaction> _transactions = [];
  double _weeklyGoal = 25.0;
  bool _isLoading = true;

  double get totalSavings => _totalSavings;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  double get weeklyGoal => _weeklyGoal;
  bool get isLoading => _isLoading;
  
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
        originalAmount: originalAmount,
        roundedAmount: roundedAmount,
        spareChange: spareChange,
        merchantName: merchantName,
        timestamp: DateTime.now(),
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
        originalAmount: originalAmount,
        roundedAmount: roundedAmount,
        spareChange: spareChange,
        merchantName: merchants[random.nextInt(merchants.length)],
        timestamp: DateTime.now().subtract(Duration(
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