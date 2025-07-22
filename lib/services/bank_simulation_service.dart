import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class BankSimulationService {
  static final Random _random = Random();
  
  // Mock bank accounts for demonstration
  static final List<BankAccount> _mockAccounts = [
    BankAccount(
      id: 'checking_001',
      name: 'Primary Checking',
      bankName: 'Chase Bank',
      accountType: AccountType.checking,
      balance: 2847.32,
      accountNumber: '****1234',
      isConnected: true,
    ),
    BankAccount(
      id: 'savings_001',
      name: 'High Yield Savings',
      bankName: 'Ally Bank',
      accountType: AccountType.savings,
      balance: 15420.89,
      accountNumber: '****5678',
      isConnected: true,
    ),
    BankAccount(
      id: 'credit_001',
      name: 'Rewards Credit Card',
      bankName: 'Capital One',
      accountType: AccountType.credit,
      balance: -1247.65, // Negative for credit card debt
      accountNumber: '****9012',
      isConnected: false,
    ),
  ];

  /// Get all connected bank accounts
  static Future<List<BankAccount>> getConnectedAccounts() async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Add some balance variation for realism
      return _mockAccounts.map((account) {
        final variation = (_random.nextDouble() - 0.5) * 100; // ±$50 variation
        return account.copyWith(
          balance: account.balance + variation,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching bank accounts: $e');
      return [];
    }
  }

  /// Simulate connecting a new bank account
  static Future<bool> connectBankAccount(String bankName, String username, String password) async {
    try {
      // Simulate authentication delay
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // Simulate success/failure (90% success rate)
      if (_random.nextDouble() < 0.9) {
        debugPrint('Successfully connected to $bankName');
        return true;
      } else {
        throw Exception('Invalid credentials or connection failed');
      }
    } catch (e) {
      debugPrint('Error connecting bank account: $e');
      return false;
    }
  }

  /// Import transactions from connected accounts
  static Future<List<Transaction>> importTransactions({
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final transactions = <Transaction>[];
      final merchants = [
        'Starbucks Coffee',
        'Target Store',
        'Amazon.com',
        'Shell Gas Station',
        'McDonald\'s',
        'Walmart Supercenter',
        'CVS Pharmacy',
        'Uber Technologies',
        'Netflix Subscription',
        'Spotify Premium',
        'Whole Foods Market',
        'Home Depot',
        'Best Buy',
        'Chipotle Mexican Grill',
        'Dunkin\' Donuts',
      ];
      
      final categories = [
        'Food & Dining',
        'Shopping',
        'Gas & Fuel',
        'Entertainment',
        'Transportation',
        'Groceries',
        'Health & Pharmacy',
        'Subscriptions',
        'Home Improvement',
      ];
      
      // Generate 20-30 transactions over the past 30 days
      final transactionCount = 20 + _random.nextInt(11);
      final now = DateTime.now();
      
      for (int i = 0; i < transactionCount; i++) {
        final daysAgo = _random.nextInt(30);
        final timestamp = now.subtract(Duration(
          days: daysAgo,
          hours: _random.nextInt(24),
          minutes: _random.nextInt(60),
        ));
        
        final originalAmount = 5.0 + _random.nextDouble() * 95.0; // $5-$100
        final roundedAmount = originalAmount.ceilToDouble();
        final spareChange = roundedAmount - originalAmount;
        
        transactions.add(Transaction(
          id: 'import_${timestamp.millisecondsSinceEpoch}_$i',
          amount: double.parse(originalAmount.toStringAsFixed(2)),
          spareChange: double.parse(spareChange.toStringAsFixed(2)),
          merchant: merchants[_random.nextInt(merchants.length)],
          date: timestamp,
          category: categories[_random.nextInt(categories.length)],
        ));
      }
      
      // Sort by timestamp (newest first)
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return transactions;
    } catch (e) {
      debugPrint('Error importing transactions: $e');
      return [];
    }
  }

  /// Get account balance for a specific account
  static Future<double> getAccountBalance(String accountId) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      final account = _mockAccounts.firstWhere(
        (acc) => acc.id == accountId,
        orElse: () => _mockAccounts.first,
      );
      
      // Add some variation for realism
      final variation = (_random.nextDouble() - 0.5) * 50;
      return account.balance + variation;
    } catch (e) {
      debugPrint('Error fetching account balance: $e');
      return 0.0;
    }
  }

  /// Simulate automatic transaction categorization
  static Future<String> categorizeTransaction(String merchantName, double amount) async {
    try {
      // Simulate AI processing delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      final merchant = merchantName.toLowerCase();
      
      // Simple rule-based categorization
      if (merchant.contains('starbucks') || merchant.contains('coffee') || 
          merchant.contains('restaurant') || merchant.contains('mcdonald') ||
          merchant.contains('chipotle') || merchant.contains('dunkin')) {
        return 'Food & Dining';
      } else if (merchant.contains('target') || merchant.contains('walmart') ||
                 merchant.contains('amazon') || merchant.contains('best buy')) {
        return 'Shopping';
      } else if (merchant.contains('shell') || merchant.contains('gas') ||
                 merchant.contains('exxon') || merchant.contains('bp')) {
        return 'Gas & Fuel';
      } else if (merchant.contains('uber') || merchant.contains('lyft') ||
                 merchant.contains('taxi')) {
        return 'Transportation';
      } else if (merchant.contains('netflix') || merchant.contains('spotify') ||
                 merchant.contains('subscription')) {
        return 'Subscriptions';
      } else if (merchant.contains('cvs') || merchant.contains('pharmacy') ||
                 merchant.contains('walgreens')) {
        return 'Health & Pharmacy';
      } else if (merchant.contains('whole foods') || merchant.contains('grocery') ||
                 merchant.contains('kroger')) {
        return 'Groceries';
      } else if (merchant.contains('home depot') || merchant.contains('lowes')) {
        return 'Home Improvement';
      } else {
        return 'Other';
      }
    } catch (e) {
      debugPrint('Error categorizing transaction: $e');
      return 'Other';
    }
  }

  /// Get spending insights across accounts
  static Future<SpendingInsights> getSpendingInsights() async {
    try {
      // Simulate analysis delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      
      return SpendingInsights(
        totalSpentThisMonth: 1247.83 + _random.nextDouble() * 200,
        totalSpentLastMonth: 1156.92 + _random.nextDouble() * 200,
        averageDailySpending: 41.59 + _random.nextDouble() * 10,
        topCategory: 'Food & Dining',
        topCategoryAmount: 387.45 + _random.nextDouble() * 50,
        savingsOpportunity: 89.32 + _random.nextDouble() * 30,
        categoryBreakdown: {
          'Food & Dining': 387.45 + _random.nextDouble() * 50,
          'Shopping': 298.76 + _random.nextDouble() * 40,
          'Gas & Fuel': 156.23 + _random.nextDouble() * 30,
          'Transportation': 89.45 + _random.nextDouble() * 20,
          'Entertainment': 67.89 + _random.nextDouble() * 25,
          'Other': 248.05 + _random.nextDouble() * 35,
        },
        monthlyTrend: List.generate(12, (index) {
          return MonthlySpending(
            month: DateTime(now.year, index + 1),
            amount: 800 + _random.nextDouble() * 600,
          );
        }),
      );
    } catch (e) {
      debugPrint('Error fetching spending insights: $e');
      return SpendingInsights.empty();
    }
  }

  /// Simulate setting up automatic savings rules
  static Future<bool> setupAutomaticSavings({
    required String accountId,
    required double roundUpAmount,
    required String frequency,
  }) async {
    try {
      // Simulate setup delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
      debugPrint('Automatic savings rule set up: Round up to \$${roundUpAmount.toStringAsFixed(2)} $frequency');
      
      return true;
    } catch (e) {
      debugPrint('Error setting up automatic savings: $e');
      return false;
    }
  }

  /// Get available banks for connection
  static Future<List<BankInfo>> getAvailableBanks() async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      return [
        BankInfo(name: 'Chase Bank', logo: 'https://via.placeholder.com/100x50?text=Chase', color: Colors.blue),
        BankInfo(name: 'Bank of America', logo: 'https://via.placeholder.com/100x50?text=BofA', color: Colors.red),
        BankInfo(name: 'Wells Fargo', logo: 'https://via.placeholder.com/100x50?text=Wells', color: Colors.orange),
        BankInfo(name: 'Citi Bank', logo: 'https://via.placeholder.com/100x50?text=Citi', color: Colors.indigo),
        BankInfo(name: 'Capital One', logo: 'https://via.placeholder.com/100x50?text=CapOne', color: Colors.purple),
        BankInfo(name: 'Ally Bank', logo: 'https://via.placeholder.com/100x50?text=Ally', color: Colors.green),
        BankInfo(name: 'USAA', logo: 'https://via.placeholder.com/100x50?text=USAA', color: Colors.teal),
        BankInfo(name: 'PNC Bank', logo: 'https://via.placeholder.com/100x50?text=PNC', color: Colors.brown),
      ];
    } catch (e) {
      debugPrint('Error fetching available banks: $e');
      return [];
    }
  }
}

enum AccountType {
  checking,
  savings,
  credit,
  investment,
}

class BankAccount {
  final String id;
  final String name;
  final String bankName;
  final AccountType accountType;
  final double balance;
  final String accountNumber;
  final bool isConnected;

  BankAccount({
    required this.id,
    required this.name,
    required this.bankName,
    required this.accountType,
    required this.balance,
    required this.accountNumber,
    required this.isConnected,
  });

  BankAccount copyWith({
    String? id,
    String? name,
    String? bankName,
    AccountType? accountType,
    double? balance,
    String? accountNumber,
    bool? isConnected,
  }) {
    return BankAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      bankName: bankName ?? this.bankName,
      accountType: accountType ?? this.accountType,
      balance: balance ?? this.balance,
      accountNumber: accountNumber ?? this.accountNumber,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  String get accountTypeString {
    switch (accountType) {
      case AccountType.checking:
        return 'Checking';
      case AccountType.savings:
        return 'Savings';
      case AccountType.credit:
        return 'Credit Card';
      case AccountType.investment:
        return 'Investment';
    }
  }
}

class BankInfo {
  final String name;
  final String logo;
  final Color color;

  BankInfo({
    required this.name,
    required this.logo,
    required this.color,
  });
}

class SpendingInsights {
  final double totalSpentThisMonth;
  final double totalSpentLastMonth;
  final double averageDailySpending;
  final String topCategory;
  final double topCategoryAmount;
  final double savingsOpportunity;
  final Map<String, double> categoryBreakdown;
  final List<MonthlySpending> monthlyTrend;

  SpendingInsights({
    required this.totalSpentThisMonth,
    required this.totalSpentLastMonth,
    required this.averageDailySpending,
    required this.topCategory,
    required this.topCategoryAmount,
    required this.savingsOpportunity,
    required this.categoryBreakdown,
    required this.monthlyTrend,
  });

  factory SpendingInsights.empty() {
    return SpendingInsights(
      totalSpentThisMonth: 0,
      totalSpentLastMonth: 0,
      averageDailySpending: 0,
      topCategory: 'None',
      topCategoryAmount: 0,
      savingsOpportunity: 0,
      categoryBreakdown: {},
      monthlyTrend: [],
    );
  }

  double get monthOverMonthChange => 
      totalSpentLastMonth > 0 
          ? ((totalSpentThisMonth - totalSpentLastMonth) / totalSpentLastMonth) * 100
          : 0;

  bool get isSpendingUp => monthOverMonthChange > 0;
}

class MonthlySpending {
  final DateTime month;
  final double amount;

  MonthlySpending({
    required this.month,
    required this.amount,
  });
}