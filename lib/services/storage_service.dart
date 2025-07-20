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

  static Future<void> exportData() async {
    final Map<String, dynamic> allData = {
      'wishItems': await getWishItems(),
      'transactions': await getTransactions(),
      'userName': await getUserName(),
      'totalSavings': await getTotalSavings(),
      'weeklyGoal': await getWeeklyGoal(),
      'isPremium': await isPremiumUser(),
    };
    
    // This could be extended to save to file or share
    print('Export Data: ${json.encode(allData)}');
  }
}