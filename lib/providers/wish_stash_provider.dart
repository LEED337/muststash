import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/wish_item.dart';

class WishStashProvider extends ChangeNotifier {
  List<WishItem> _wishItems = [];
  
  List<WishItem> get wishItems => List.unmodifiable(_wishItems);
  List<WishItem> get sortedWishItems {
    final items = List<WishItem>.from(_wishItems);
    items.sort((a, b) => a.priority.compareTo(b.priority));
    return items;
  }

  WishStashProvider() {
    _loadData();
    _generateMockWishItems(); // For MVP demo purposes
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final wishItemsJson = prefs.getStringList('wishItems') ?? [];
    _wishItems = wishItemsJson
        .map((json) => WishItem.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final wishItemsJson = _wishItems
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList('wishItems', wishItemsJson);
  }

  void addWishItem(WishItem item) {
    _wishItems.add(item);
    _saveData();
    notifyListeners();
  }

  void updateWishItem(WishItem updatedItem) {
    final index = _wishItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _wishItems[index] = updatedItem;
      _saveData();
      notifyListeners();
    }
  }

  void deleteWishItem(String id) {
    _wishItems.removeWhere((item) => item.id == id);
    _saveData();
    notifyListeners();
  }

  void reorderWishItems(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _wishItems.removeAt(oldIndex);
    _wishItems.insert(newIndex, item);
    
    // Update priorities
    for (int i = 0; i < _wishItems.length; i++) {
      _wishItems[i] = _wishItems[i].copyWith(priority: i + 1);
    }
    
    _saveData();
    notifyListeners();
  }

  double getProgressForItem(String itemId, double totalSavings) {
    final item = _wishItems.firstWhere((item) => item.id == itemId);
    return (totalSavings / item.targetPrice).clamp(0.0, 1.0);
  }

  WishItem? getTopPriorityAffordableItem(double totalSavings) {
    final affordableItems = sortedWishItems
        .where((item) => !item.isCompleted && totalSavings >= item.targetPrice)
        .toList();
    return affordableItems.isNotEmpty ? affordableItems.first : null;
  }

  // Mock data generator for MVP demo
  void _generateMockWishItems() {
    if (_wishItems.isNotEmpty) return;
    
    final mockItems = [
      WishItem(
        id: 'mock_1',
        name: 'AirPods Pro',
        description: 'Wireless earbuds with noise cancellation',
        targetPrice: 249.99,
        imageUrl: 'https://via.placeholder.com/300x300?text=AirPods',
        category: 'Electronics',
        priority: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        productUrl: 'https://apple.com/airpods-pro',
      ),
      WishItem(
        id: 'mock_2',
        name: 'Nintendo Switch',
        description: 'Gaming console for home and on-the-go',
        targetPrice: 299.99,
        imageUrl: 'https://via.placeholder.com/300x300?text=Switch',
        category: 'Gaming',
        priority: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      WishItem(
        id: 'mock_3',
        name: 'Coffee Maker',
        description: 'Programmable drip coffee maker',
        targetPrice: 89.99,
        imageUrl: 'https://via.placeholder.com/300x300?text=Coffee',
        category: 'Home',
        priority: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
    
    _wishItems.addAll(mockItems);
    _saveData();
  }
}