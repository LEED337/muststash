import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/wish_item.dart';
import '../services/storage_service.dart';

class RewardsProvider extends ChangeNotifier {
  List<WishItem> _wishItems = [];
  bool _isLoading = true;
  
  List<WishItem> get wishItems => List.unmodifiable(_wishItems);
  bool get isLoading => _isLoading;
  
  List<WishItem> get sortedWishItems {
    final items = List<WishItem>.from(_wishItems);
    items.sort((a, b) => a.priority.compareTo(b.priority));
    return items;
  }

  List<WishItem> get activeWishItems {
    return _wishItems.where((item) => !item.isCompleted).toList();
  }

  List<WishItem> get completedWishItems {
    return _wishItems.where((item) => item.isCompleted).toList();
  }

  RewardsProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _wishItems = await StorageService.getWishItems();
      
      // Generate mock data if no wish items exist (for demo purposes)
      if (_wishItems.isEmpty) {
        await _generateMockWishItems();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading wish items: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWishItem({
    required String name,
    required String description,
    required double targetPrice,
    required String category,
    String? productUrl,
  }) async {
    try {
      final newItem = WishItem(
        id: const Uuid().v4(),
        name: name,
        description: description,
        targetPrice: targetPrice,
        imageUrl: 'https://via.placeholder.com/300x300?text=${Uri.encodeComponent(name)}',
        category: category,
        priority: _wishItems.length + 1,
        createdAt: DateTime.now(),
        productUrl: productUrl,
      );
      
      _wishItems.add(newItem);
      await StorageService.addWishItem(newItem);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding wish item: $e');
    }
  }

  Future<void> updateWishItem(WishItem updatedItem) async {
    try {
      final index = _wishItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _wishItems[index] = updatedItem;
        await StorageService.updateWishItem(updatedItem);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating wish item: $e');
    }
  }

  Future<void> deleteWishItem(String id) async {
    try {
      _wishItems.removeWhere((item) => item.id == id);
      await StorageService.deleteWishItem(id);
      
      // Reorder priorities after deletion
      await _reorderPriorities();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting wish item: $e');
    }
  }

  Future<void> markAsCompleted(String id) async {
    try {
      final index = _wishItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _wishItems[index] = _wishItems[index].copyWith(isCompleted: true);
        await StorageService.updateWishItem(_wishItems[index]);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking wish item as completed: $e');
    }
  }

  Future<void> reorderWishItems(int oldIndex, int newIndex) async {
    try {
      if (newIndex > oldIndex) newIndex--;
      final item = _wishItems.removeAt(oldIndex);
      _wishItems.insert(newIndex, item);
      
      await _reorderPriorities();
      notifyListeners();
    } catch (e) {
      debugPrint('Error reordering wish items: $e');
    }
  }

  Future<void> _reorderPriorities() async {
    for (int i = 0; i < _wishItems.length; i++) {
      _wishItems[i] = _wishItems[i].copyWith(priority: i + 1);
    }
    await StorageService.saveWishItems(_wishItems);
  }

  double getProgressForItem(String itemId, double totalSavings) {
    try {
      final item = _wishItems.firstWhere((item) => item.id == itemId);
      return (totalSavings / item.targetPrice).clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  WishItem? getTopPriorityAffordableItem(double totalSavings) {
    final affordableItems = sortedWishItems
        .where((item) => !item.isCompleted && totalSavings >= item.targetPrice)
        .toList();
    return affordableItems.isNotEmpty ? affordableItems.first : null;
  }

  List<WishItem> getAffordableItems(double totalSavings) {
    return sortedWishItems
        .where((item) => !item.isCompleted && totalSavings >= item.targetPrice)
        .toList();
  }

  // Mock data generator for demo purposes
  Future<void> _generateMockWishItems() async {
    final mockItems = [
      WishItem(
        id: const Uuid().v4(),
        name: 'AirPods Pro',
        description: 'Wireless earbuds with active noise cancellation for immersive sound',
        targetPrice: 249.99,
        imageUrl: 'https://via.placeholder.com/300x300?text=AirPods+Pro',
        category: 'Electronics',
        priority: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        productUrl: 'https://apple.com/airpods-pro',
      ),
      WishItem(
        id: const Uuid().v4(),
        name: 'Nintendo Switch',
        description: 'Gaming console perfect for home and portable gaming',
        targetPrice: 299.99,
        imageUrl: 'https://via.placeholder.com/300x300?text=Nintendo+Switch',
        category: 'Gaming',
        priority: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      WishItem(
        id: const Uuid().v4(),
        name: 'Premium Coffee Maker',
        description: 'Programmable drip coffee maker with thermal carafe',
        targetPrice: 89.99,
        imageUrl: 'https://via.placeholder.com/300x300?text=Coffee+Maker',
        category: 'Home & Kitchen',
        priority: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
    
    _wishItems.addAll(mockItems);
    await StorageService.saveWishItems(_wishItems);
  }
}