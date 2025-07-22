import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PriceService {
  static const String _baseUrl = 'https://api.example.com'; // Mock API endpoint
  
  // For demo purposes, we'll simulate API calls with mock data
  static final Random _random = Random();
  
  // Mock product database for demonstration
  static final Map<String, ProductInfo> _mockProducts = {
    'airpods': ProductInfo(
      name: 'Apple AirPods Pro',
      currentPrice: 249.99,
      originalPrice: 279.99,
      imageUrl: 'https://via.placeholder.com/300x300?text=AirPods+Pro',
      retailer: 'Apple Store',
      availability: 'In Stock',
      rating: 4.5,
      reviewCount: 12543,
    ),
    'nintendo switch': ProductInfo(
      name: 'Nintendo Switch Console',
      currentPrice: 299.99,
      originalPrice: 329.99,
      imageUrl: 'https://via.placeholder.com/300x300?text=Nintendo+Switch',
      retailer: 'Best Buy',
      availability: 'In Stock',
      rating: 4.8,
      reviewCount: 8932,
    ),
    'coffee maker': ProductInfo(
      name: 'Keurig K-Elite Coffee Maker',
      currentPrice: 89.99,
      originalPrice: 119.99,
      imageUrl: 'https://via.placeholder.com/300x300?text=Coffee+Maker',
      retailer: 'Amazon',
      availability: 'In Stock',
      rating: 4.3,
      reviewCount: 2156,
    ),
  };

  /// Fetch product information by name or URL
  static Future<ProductInfo?> fetchProductInfo(String query) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // For demo, search our mock database
      final lowerQuery = query.toLowerCase();
      for (final entry in _mockProducts.entries) {
        if (lowerQuery.contains(entry.key) || entry.key.contains(lowerQuery)) {
          // Add some price variation for realism
          final basePrice = entry.value.currentPrice;
          final variation = (_random.nextDouble() - 0.5) * 20; // ±$10 variation
          final newPrice = (basePrice + variation).clamp(basePrice * 0.8, basePrice * 1.2);
          
          return entry.value.copyWith(
            currentPrice: double.parse(newPrice.toStringAsFixed(2)),
          );
        }
      }
      
      // If no match found, return a generic product
      return ProductInfo(
        name: query,
        currentPrice: 50.0 + _random.nextDouble() * 200, // Random price $50-$250
        originalPrice: null,
        imageUrl: 'https://via.placeholder.com/300x300?text=${Uri.encodeComponent(query)}',
        retailer: 'Generic Store',
        availability: 'Available',
        rating: 3.5 + _random.nextDouble() * 1.5, // Random rating 3.5-5.0
        reviewCount: _random.nextInt(5000) + 100,
      );
    } catch (e) {
      debugPrint('Error fetching product info: $e');
      return null;
    }
  }

  /// Get price comparison across multiple retailers
  static Future<List<PriceComparison>> getPriceComparisons(String productName) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 1200));
      
      final retailers = ['Amazon', 'Best Buy', 'Target', 'Walmart', 'eBay'];
      final comparisons = <PriceComparison>[];
      
      final basePrice = 100.0 + _random.nextDouble() * 200; // Base price $100-$300
      
      for (int i = 0; i < retailers.length; i++) {
        final variation = (_random.nextDouble() - 0.5) * 50; // ±$25 variation
        final price = (basePrice + variation).clamp(basePrice * 0.7, basePrice * 1.3);
        final isOnSale = _random.nextBool();
        
        comparisons.add(PriceComparison(
          retailer: retailers[i],
          price: double.parse(price.toStringAsFixed(2)),
          originalPrice: isOnSale ? price * (1.1 + _random.nextDouble() * 0.3) : null,
          availability: _random.nextBool() ? 'In Stock' : 'Limited Stock',
          shipping: _random.nextBool() ? 'Free Shipping' : '\$${(5 + _random.nextDouble() * 10).toStringAsFixed(2)} Shipping',
          rating: 3.0 + _random.nextDouble() * 2.0,
          url: 'https://${retailers[i].toLowerCase().replaceAll(' ', '')}.com/product',
        ));
      }
      
      // Sort by price (lowest first)
      comparisons.sort((a, b) => a.price.compareTo(b.price));
      
      return comparisons;
    } catch (e) {
      debugPrint('Error fetching price comparisons: $e');
      return [];
    }
  }

  /// Track price changes for a product
  static Future<List<PriceHistory>> getPriceHistory(String productId) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      final history = <PriceHistory>[];
      final now = DateTime.now();
      final basePrice = 100.0 + _random.nextDouble() * 200;
      
      // Generate 30 days of price history
      for (int i = 30; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final variation = (_random.nextDouble() - 0.5) * 30; // ±$15 variation
        final price = (basePrice + variation).clamp(basePrice * 0.8, basePrice * 1.2);
        
        history.add(PriceHistory(
          date: date,
          price: double.parse(price.toStringAsFixed(2)),
          retailer: 'Amazon', // Primary retailer for history
        ));
      }
      
      return history;
    } catch (e) {
      debugPrint('Error fetching price history: $e');
      return [];
    }
  }

  /// Set up price drop alerts
  static Future<bool> setPriceAlert(String productId, double targetPrice) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 400));
      
      // In a real app, this would register the alert with a backend service
      debugPrint('Price alert set for product $productId at \$${targetPrice.toStringAsFixed(2)}');
      
      return true;
    } catch (e) {
      debugPrint('Error setting price alert: $e');
      return false;
    }
  }

  /// Get deal recommendations based on user preferences
  static Future<List<DealRecommendation>> getDealRecommendations(List<String> categories) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final deals = <DealRecommendation>[];
      final products = [
        'Wireless Headphones',
        'Smart Watch',
        'Bluetooth Speaker',
        'Gaming Mouse',
        'Coffee Grinder',
        'Yoga Mat',
        'Phone Case',
        'Portable Charger',
      ];
      
      for (int i = 0; i < 5; i++) {
        final product = products[_random.nextInt(products.length)];
        final originalPrice = 50.0 + _random.nextDouble() * 150;
        final discountPercent = 10 + _random.nextDouble() * 40; // 10-50% off
        final salePrice = originalPrice * (1 - discountPercent / 100);
        
        deals.add(DealRecommendation(
          productName: product,
          originalPrice: double.parse(originalPrice.toStringAsFixed(2)),
          salePrice: double.parse(salePrice.toStringAsFixed(2)),
          discountPercent: int.parse(discountPercent.toStringAsFixed(0)),
          retailer: ['Amazon', 'Best Buy', 'Target'][_random.nextInt(3)],
          imageUrl: 'https://via.placeholder.com/200x200?text=${Uri.encodeComponent(product)}',
          expiresAt: DateTime.now().add(Duration(days: _random.nextInt(7) + 1)),
          category: categories.isNotEmpty ? categories[_random.nextInt(categories.length)] : 'Electronics',
        ));
      }
      
      return deals;
    } catch (e) {
      debugPrint('Error fetching deal recommendations: $e');
      return [];
    }
  }
}

class ProductInfo {
  final String name;
  final double currentPrice;
  final double? originalPrice;
  final String imageUrl;
  final String retailer;
  final String availability;
  final double rating;
  final int reviewCount;

  ProductInfo({
    required this.name,
    required this.currentPrice,
    this.originalPrice,
    required this.imageUrl,
    required this.retailer,
    required this.availability,
    required this.rating,
    required this.reviewCount,
  });

  ProductInfo copyWith({
    String? name,
    double? currentPrice,
    double? originalPrice,
    String? imageUrl,
    String? retailer,
    String? availability,
    double? rating,
    int? reviewCount,
  }) {
    return ProductInfo(
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      retailer: retailer ?? this.retailer,
      availability: availability ?? this.availability,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  bool get isOnSale => originalPrice != null && originalPrice! > currentPrice;
  
  double get discountPercent => 
      isOnSale ? ((originalPrice! - currentPrice) / originalPrice!) * 100 : 0;
}

class PriceComparison {
  final String retailer;
  final double price;
  final double? originalPrice;
  final String availability;
  final String shipping;
  final double rating;
  final String url;

  PriceComparison({
    required this.retailer,
    required this.price,
    this.originalPrice,
    required this.availability,
    required this.shipping,
    required this.rating,
    required this.url,
  });

  bool get isOnSale => originalPrice != null && originalPrice! > price;
  
  double get discountPercent => 
      isOnSale ? ((originalPrice! - price) / originalPrice!) * 100 : 0;
}

class PriceHistory {
  final DateTime date;
  final double price;
  final String retailer;

  PriceHistory({
    required this.date,
    required this.price,
    required this.retailer,
  });
}

class DealRecommendation {
  final String productName;
  final double originalPrice;
  final double salePrice;
  final int discountPercent;
  final String retailer;
  final String imageUrl;
  final DateTime expiresAt;
  final String category;

  DealRecommendation({
    required this.productName,
    required this.originalPrice,
    required this.salePrice,
    required this.discountPercent,
    required this.retailer,
    required this.imageUrl,
    required this.expiresAt,
    required this.category,
  });

  double get savings => originalPrice - salePrice;
  
  bool get isExpiringSoon => 
      expiresAt.difference(DateTime.now()).inDays <= 1;
}