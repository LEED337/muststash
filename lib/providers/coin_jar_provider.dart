import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/transaction.dart';

class CoinJarProvider extends ChangeNotifier {
  double _totalSavings = 0.0;
  List<Transaction> _transactions = [];
  double _weeklyGoal = 25.0;

  double get totalSavings => _totalSavings;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  double get weeklyGoal => _weeklyGoal;
  
  double get weeklyProgress {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyTotal = _transactions
        .where((t) => t.timestamp.isAfter(weekStart))
        .fold(0.0, (sum, t) => sum + t.spareChange);
    return (weeklyTotal / _weeklyGoal).clamp(0.0, 1.0);
  }

  CoinJarProvider() {
    _loadData();
    _generateMockTransactions(); // For MVP demo purposes
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _totalSavings = prefs.getDouble('totalSavings') ?? 0.0;
    _weeklyGoal = prefs.getDouble('weeklyGoal') ?? 25.0;
    
    final transactionsJson = prefs.getStringList('transactions') ?? [];
    _transactions = transactionsJson
        .map((json) => Transaction.fromJson(jsonDecode(json)))
        .toList();
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalSavings', _totalSavings);
    await prefs.setDouble('weeklyGoal', _weeklyGoal);
    
    final transactionsJson = _transactions
        .map((t) => jsonEncode(t.toJson()))
        .toList();
    await prefs.setStringList('transactions', transactionsJson);
  }

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    _totalSavings += transaction.spareChange;
    _saveData();
    notifyListeners();
  }

  void setWeeklyGoal(double goal) {
    _weeklyGoal = goal;
    _saveData();
    notifyListeners();
  }

  // Mock data generator for MVP demo
  void _generateMockTransactions() {
    if (_transactions.isNotEmpty) return;
    
    final random = Random();
    final merchants = ['Starbucks', 'Target', 'Amazon', 'Walmart', 'McDonald\'s', 'Shell', 'Uber'];
    final categories = ['Food', 'Shopping', 'Gas', 'Entertainment', 'Transportation'];
    
    for (int i = 0; i < 15; i++) {
      final originalAmount = 5.0 + random.nextDouble() * 45.0;
      final roundedAmount = originalAmount.ceilToDouble();
      final spareChange = roundedAmount - originalAmount;
      
      final transaction = Transaction(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}_$i',
        originalAmount: originalAmount,
        roundedAmount: roundedAmount,
        spareChange: spareChange,
        merchantName: merchants[random.nextInt(merchants.length)],
        timestamp: DateTime.now().subtract(Duration(days: random.nextInt(30))),
        category: categories[random.nextInt(categories.length)],
      );
      
      _transactions.add(transaction);
      _totalSavings += spareChange;
    }
    
    _transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _saveData();
  }
}