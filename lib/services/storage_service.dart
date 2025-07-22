import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wish_item.dart';
import '../models/transaction.dart';

class StorageService {
  static const String _wishItemsKey = 'wish_items';
  static const String _transactionsKey = 'transactions';
  static const String _userNameKey = 'user_name';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _isPremiumKey = 'is_premium';
  static const String _totalSavingsKey = 'total_savings';
  static const String _weeklyGoalKey = 'weekly_goal';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Wish Items
  static Future<List<WishItem>> getWishItems() async {
    final String? wishItemsJson = _prefs?.getString(_wishItemsKey);
    if (wishItemsJson == null) return [];
    
    final List<dynamic> wishItemsList = json.decode(wishItemsJson);
    return wishItemsList.map((item) => WishItem.fromJson(item)).toList();
  }

  static Future<void> saveWishItems(List<WishItem> wishItems) async {
    final String wishItemsJson = json.encode(
      wishItems.map((item) => item.toJson()).toList(),
    );
    await _prefs?.setString(_wishItemsKey, wishItemsJson);
  }

  static Future<void> addWishItem(WishItem wishItem) async {
    final List<WishItem> wishItems = await getWishItems();
    wishItems.add(wishItem);
    await saveWishItems(wishItems);
  }

  static Future<void> updateWishItem(WishItem updatedItem) async {
    final List<WishItem> wishItems = await getWishItems();
    final int index = wishItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      wishItems[index] = updatedItem;
      await saveWishItems(wishItems);
    }
  }

  static Future<void> deleteWishItem(String id) async {
    final List<WishItem> wishItems = await getWishItems();
    wishItems.removeWhere((item) => item.id == id);
    await saveWishItems(wishItems);
  }

  // Transactions
  static Future<List<Transaction>> getTransactions() async {
    final String? transactionsJson = _prefs?.getString(_transactionsKey);
    if (transactionsJson == null) return [];
    
    final List<dynamic> transactionsList = json.decode(transactionsJson);
    return transactionsList.map((item) => Transaction.fromJson(item)).toList();
  }

  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final String transactionsJson = json.encode(
      transactions.map((item) => item.toJson()).toList(),
    );
    await _prefs?.setString(_transactionsKey, transactionsJson);
  }

  static Future<void> addTransaction(Transaction transaction) async {
    final List<Transaction> transactions = await getTransactions();
    transactions.insert(0, transaction); // Add to beginning for chronological order
    await saveTransactions(transactions);
  }

  static Future<void> deleteTransaction(String id) async {
    final List<Transaction> transactions = await getTransactions();
    transactions.removeWhere((transaction) => transaction.id == id);
    await saveTransactions(transactions);
  }

  // User Data
  static Future<String> getUserName() async {
    return _prefs?.getString(_userNameKey) ?? 'User';
  }

  static Future<void> setUserName(String name) async {
    await _prefs?.setString(_userNameKey, name);
  }

  static Future<bool> isOnboardingComplete() async {
    return _prefs?.getBool(_onboardingCompleteKey) ?? false;
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    await _prefs?.setBool(_onboardingCompleteKey, complete);
  }

  static Future<bool> isPremiumUser() async {
    return _prefs?.getBool(_isPremiumKey) ?? false;
  }

  static Future<void> setPremiumUser(bool isPremium) async {
    await _prefs?.setBool(_isPremiumKey, isPremium);
  }

  static Future<double> getTotalSavings() async {
    return _prefs?.getDouble(_totalSavingsKey) ?? 0.0;
  }

  static Future<void> setTotalSavings(double amount) async {
    await _prefs?.setDouble(_totalSavingsKey, amount);
  }

  // Boolean storage methods for tutorial system
  static Future<bool?> getBool(String key) async {
    return _prefs?.getBool(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  // String storage methods for API tokens and user data
  static Future<String?> getString(String key) async {
    return _prefs?.getString(key);
  }

  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static Future<void> removeString(String key) async {
    await _prefs?.remove(key);
  }

  static Future<double> getWeeklyGoal() async {
    return _prefs?.getDouble(_weeklyGoalKey) ?? 25.0;
  }

  static Future<void> setWeeklyGoal(double goal) async {
    await _prefs?.setDouble(_weeklyGoalKey, goal);
  }

  // Utility Methods
  static Future<void> clearAllData() async {
    await _prefs?.clear();
  }

  static Future<Map<String, dynamic>> exportData() async {
    final Map<String, dynamic> allData = {
      'version': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'userData': {
        'userName': await getUserName(),
        'isOnboardingComplete': await isOnboardingComplete(),
        'isPremium': await isPremiumUser(),
      },
      'savingsData': {
        'totalSavings': await getTotalSavings(),
        'weeklyGoal': await getWeeklyGoal(),
      },
      'wishItems': (await getWishItems()).map((item) => item.toJson()).toList(),
      'transactions': (await getTransactions()).map((transaction) => transaction.toJson()).toList(),
    };
    
    // For web, we'll log to console. In a real app, this would save to file
    print('=== MustStash Data Export ===');
    print(const JsonEncoder.withIndent('  ').convert(allData));
    print('=== End Export ===');
    
    return allData;
  }

  static Future<bool> importData(Map<String, dynamic> data) async {
    try {
      // Validate data structure
      if (!data.containsKey('version') || !data.containsKey('userData')) {
        throw Exception('Invalid data format');
      }

      // Clear existing data
      await clearAllData();

      // Import user data
      final userData = data['userData'] as Map<String, dynamic>;
      await setUserName(userData['userName'] ?? 'User');
      await setOnboardingComplete(userData['isOnboardingComplete'] ?? false);
      await setPremiumUser(userData['isPremium'] ?? false);

      // Import savings data
      if (data.containsKey('savingsData')) {
        final savingsData = data['savingsData'] as Map<String, dynamic>;
        await setTotalSavings(savingsData['totalSavings']?.toDouble() ?? 0.0);
        await setWeeklyGoal(savingsData['weeklyGoal']?.toDouble() ?? 25.0);
      }

      // Import wish items
      if (data.containsKey('wishItems')) {
        final wishItemsData = data['wishItems'] as List<dynamic>;
        final wishItems = wishItemsData.map((item) => WishItem.fromJson(item)).toList();
        await saveWishItems(wishItems);
      }

      // Import transactions
      if (data.containsKey('transactions')) {
        final transactionsData = data['transactions'] as List<dynamic>;
        final transactions = transactionsData.map((item) => Transaction.fromJson(item)).toList();
        await saveTransactions(transactions);
      }

      return true;
    } catch (e) {
      print('Error importing data: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getAppStatistics() async {
    final transactions = await getTransactions();
    final wishItems = await getWishItems();
    final totalSavings = await getTotalSavings();

    // Calculate statistics
    final now = DateTime.now();
    final thisWeek = now.subtract(Duration(days: now.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);
    
    final weeklyTransactions = transactions.where((t) => t.timestamp.isAfter(thisWeek)).toList();
    final monthlyTransactions = transactions.where((t) => t.timestamp.isAfter(thisMonth)).toList();
    
    final weeklyTotal = weeklyTransactions.fold(0.0, (sum, t) => sum + t.spareChange);
    final monthlyTotal = monthlyTransactions.fold(0.0, (sum, t) => sum + t.spareChange);
    
    // Category breakdown
    final categoryBreakdown = <String, double>{};
    for (final transaction in transactions) {
      categoryBreakdown[transaction.category] = 
          (categoryBreakdown[transaction.category] ?? 0) + transaction.spareChange;
    }

    return {
      'totalSavings': totalSavings,
      'totalTransactions': transactions.length,
      'totalWishItems': wishItems.length,
      'completedWishItems': wishItems.where((item) => item.isCompleted).length,
      'weeklyTotal': weeklyTotal,
      'monthlyTotal': monthlyTotal,
      'averageTransaction': transactions.isNotEmpty ? totalSavings / transactions.length : 0.0,
      'categoryBreakdown': categoryBreakdown,
      'oldestTransaction': transactions.isNotEmpty 
          ? transactions.map((t) => t.timestamp).reduce((a, b) => a.isBefore(b) ? a : b).toIso8601String()
          : null,
      'newestTransaction': transactions.isNotEmpty 
          ? transactions.map((t) => t.timestamp).reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String()
          : null,
    };
  }
}