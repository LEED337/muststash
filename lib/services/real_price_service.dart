import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../models/product_info.dart';
import '../models/price_comparison.dart';
import '../models/price_history.dart';
import '../models/deal_recommendation.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

class RealPriceService {
  // Use configuration from ApiConfig
  static String get _googleShoppingApiKey => ApiConfig.googleShoppingApiKey;
  static String get _rapidApiKey => ApiConfig.rapidApiKey;
  static String get _searchEngineId => ApiConfig.googleSearchEngineId;
  
  // API Endpoints from configuration
  static String get _googleShoppingUrl => ApiConfig.googleShoppingUrl;
  static String get _priceApiUrl => ApiConfig.priceComparisonApiUrl;
  static String get _amazonApiUrl => ApiConfig.amazonApiUrl;
  
  // Search for products across multiple retailers
  static Future<List<ProductSearchResult>> searchProducts(String query) async {
    try {
      final results = <ProductSearchResult>[];
      
      // Search Google Shopping
      final googleResults = await _searchGoogleShopping(query);
      results.addAll(googleResults);
      
      // Search other price comparison APIs
      final priceApiResults = await _searchPriceComparisonApi(query);
      results.addAll(priceApiResults);
      
      // Remove duplicates and sort by price
      final uniqueResults = _removeDuplicates(results);
      uniqueResults.sort((a, b) => a.price.compareTo(b.price));
      
      return uniqueResults;
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }
  
  // Get detailed product information
  static Future<ProductInfo?> getProductInfo(String productId, String productName) async {
    try {
      // Try to get product info from multiple sources
      final googleInfo = await _getGoogleProductInfo(productName);
      if (googleInfo != null) return googleInfo;
      
      final priceApiInfo = await _getPriceApiProductInfo(productName);
      if (priceApiInfo != null) return priceApiInfo;
      
      // Fallback to basic info
      return ProductInfo(
        id: productId,
        name: productName,
        price: 0.0,
        retailer: 'Unknown',
        rating: 0.0,
        reviewCount: 0,
        isOnSale: false,
        imageUrl: '',
        description: 'Product information not available',
      );
    } catch (e) {
      debugPrint('Error getting product info: $e');
      return null;
    }
  }
  
  // Get price comparisons for a specific product
  static Future<List<PriceComparison>> getPriceComparisons(String productName) async {
    try {
      final comparisons = <PriceComparison>[];
      
      // Search across multiple retailers
      final searchResults = await searchProducts(productName);
      
      for (final result in searchResults.take(10)) {
        comparisons.add(PriceComparison(
          retailer: result.retailer,
          price: result.price,
          url: result.url,
          inStock: result.availability == 'In Stock',
          shippingInfo: result.shipping ?? '',
          rating: 0.0,
        ));
      }
      
      return comparisons;
    } catch (e) {
      debugPrint('Error getting price comparisons: $e');
      return [];
    }
  }
  
  // Get price history for a product
  static Future<List<PriceHistory>> getPriceHistory(String productId) async {
    try {
      // Try to get historical data from price tracking APIs
      final response = await http.get(
        Uri.parse('$_priceApiUrl/history/$productId'),
        headers: {
          'X-RapidAPI-Key': _rapidApiKey,
          'X-RapidAPI-Host': 'price-comparison-api.p.rapidapi.com',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final history = (data['history'] as List?)
            ?.map((item) => PriceHistory.fromJson(item))
            .toList() ?? [];
        
        return history;
      }
      
      // Fallback to mock data if API fails
      return _generateMockPriceHistory();
    } catch (e) {
      debugPrint('Error getting price history: $e');
      return _generateMockPriceHistory();
    }
  }
  
  // Set price alert for a product
  static Future<bool> setPriceAlert(String productId, double targetPrice) async {
    try {
      // Store price alert locally
      final alerts = await _getPriceAlerts();
      alerts[productId] = PriceAlert(
        productId: productId,
        targetPrice: targetPrice,
        createdAt: DateTime.now(),
        isActive: true,
      );
      
      await _savePriceAlerts(alerts);
      
      // In a real implementation, you would also register this with a backend service
      // that monitors prices and sends push notifications
      
      return true;
    } catch (e) {
      debugPrint('Error setting price alert: $e');
      return false;
    }
  }
  
  // Get deal recommendations
  static Future<List<DealRecommendation>> getDealRecommendations() async {
    try {
      // Get deals from multiple sources
      final deals = <DealRecommendation>[];
      
      // Get deals from price comparison API
      final response = await http.get(
        Uri.parse('$_priceApiUrl/deals'),
        headers: {
          'X-RapidAPI-Key': _rapidApiKey,
          'X-RapidAPI-Host': 'price-comparison-api.p.rapidapi.com',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apiDeals = (data['deals'] as List?)
            ?.map((deal) => DealRecommendation.fromJson(deal))
            .toList() ?? [];
        
        deals.addAll(apiDeals);
      }
      
      // Add some curated deals if API doesn't return enough
      if (deals.length < 5) {
        deals.addAll(_getCuratedDeals());
      }
      
      return deals.take(10).toList();
    } catch (e) {
      debugPrint('Error getting deal recommendations: $e');
      return _getCuratedDeals();
    }
  }
  
  // Check for price drops on user's alerts
  static Future<List<PriceAlert>> checkPriceAlerts() async {
    try {
      final alerts = await _getPriceAlerts();
      final triggeredAlerts = <PriceAlert>[];
      
      for (final alert in alerts.values) {
        if (!alert.isActive) continue;
        
        // Check current price for this product
        final currentPrice = await _getCurrentPrice(alert.productId);
        if (currentPrice != null && currentPrice <= alert.targetPrice) {
          triggeredAlerts.add(alert);
          
          // Mark alert as triggered
          alert.isActive = false;
          alert.triggeredAt = DateTime.now();
        }
      }
      
      if (triggeredAlerts.isNotEmpty) {
        await _savePriceAlerts(alerts);
      }
      
      return triggeredAlerts;
    } catch (e) {
      debugPrint('Error checking price alerts: $e');
      return [];
    }
  }
  
  // Private helper methods
  static Future<List<ProductSearchResult>> _searchGoogleShopping(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_googleShoppingUrl?key=$_googleShoppingApiKey&cx=$_searchEngineId&q=$query'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List? ?? [];
        
        return items.map((item) => ProductSearchResult.fromGoogleShopping(item)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Error searching Google Shopping: $e');
      return [];
    }
  }
  
  static Future<List<ProductSearchResult>> _searchPriceComparisonApi(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_priceApiUrl/search?q=${Uri.encodeComponent(query)}'),
        headers: {
          'X-RapidAPI-Key': _rapidApiKey,
          'X-RapidAPI-Host': 'price-comparison-api.p.rapidapi.com',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data['products'] as List? ?? [];
        
        return products.map((product) => ProductSearchResult.fromPriceApi(product)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Error searching price comparison API: $e');
      return [];
    }
  }
  
  static Future<ProductInfo?> _getGoogleProductInfo(String productName) async {
    try {
      final searchResults = await _searchGoogleShopping(productName);
      if (searchResults.isNotEmpty) {
        final result = searchResults.first;
        return ProductInfo(
          id: result.id,
          name: result.name,
          price: result.price,
          retailer: result.retailer,
          rating: 4.0, // Default rating
          reviewCount: 100, // Default review count
          isOnSale: result.isOnSale,
          originalPrice: result.originalPrice,
          imageUrl: '',
          description: 'Product information from API',
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting Google product info: $e');
      return null;
    }
  }
  
  static Future<ProductInfo?> _getPriceApiProductInfo(String productName) async {
    try {
      final response = await http.get(
        Uri.parse('$_priceApiUrl/product?name=${Uri.encodeComponent(productName)}'),
        headers: {
          'X-RapidAPI-Key': _rapidApiKey,
          'X-RapidAPI-Host': 'price-comparison-api.p.rapidapi.com',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProductInfo.fromJson(data);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting price API product info: $e');
      return null;
    }
  }
  
  static List<ProductSearchResult> _removeDuplicates(List<ProductSearchResult> results) {
    final seen = <String>{};
    return results.where((result) {
      final key = '${result.name.toLowerCase()}_${result.retailer.toLowerCase()}';
      return seen.add(key);
    }).toList();
  }
  
  static Future<double?> _getCurrentPrice(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$_priceApiUrl/price/$productId'),
        headers: {
          'X-RapidAPI-Key': _rapidApiKey,
          'X-RapidAPI-Host': 'price-comparison-api.p.rapidapi.com',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['price'] as num?)?.toDouble();
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting current price: $e');
      return null;
    }
  }
  
  static Future<Map<String, PriceAlert>> _getPriceAlerts() async {
    try {
      final alertsJson = await StorageService.getString('price_alerts') ?? '{}';
      final alertsMap = jsonDecode(alertsJson) as Map<String, dynamic>;
      
      return alertsMap.map((key, value) => 
        MapEntry(key, PriceAlert.fromJson(value)));
    } catch (e) {
      debugPrint('Error getting price alerts: $e');
      return {};
    }
  }
  
  static Future<void> _savePriceAlerts(Map<String, PriceAlert> alerts) async {
    try {
      final alertsMap = alerts.map((key, value) => 
        MapEntry(key, value.toJson()));
      final alertsJson = jsonEncode(alertsMap);
      
      await StorageService.setString('price_alerts', alertsJson);
    } catch (e) {
      debugPrint('Error saving price alerts: $e');
    }
  }
  
  static List<PriceHistory> _generateMockPriceHistory() {
    // Generate mock price history for demonstration
    final history = <PriceHistory>[];
    final basePrice = 100.0;
    final now = DateTime.now();
    
    for (int i = 30; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final variation = (i % 7) * 5.0 - 10.0; // Weekly price variation
      final price = basePrice + variation;
      
      history.add(PriceHistory(
        date: date,
        price: price,
        retailer: 'Sample Store',
      ));
    }
    
    return history;
  }
  
  static List<DealRecommendation> _getCuratedDeals() {
    // Return some curated deals as fallback
    return [
      DealRecommendation(
        id: 'deal_1',
        productName: 'Wireless Headphones',
        category: 'Electronics',
        originalPrice: 199.99,
        salePrice: 149.99,
        discountPercentage: 25,
        retailer: 'TechStore',
        imageUrl: 'https://example.com/headphones.jpg',
        dealUrl: 'https://example.com/headphones-deal',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
      DealRecommendation(
        id: 'deal_2',
        productName: 'Smart Watch',
        category: 'Electronics',
        originalPrice: 299.99,
        salePrice: 199.99,
        discountPercentage: 33,
        retailer: 'GadgetWorld',
        imageUrl: 'https://example.com/smartwatch.jpg',
        dealUrl: 'https://example.com/smartwatch-deal',
        expiresAt: DateTime.now().add(const Duration(days: 2)),
      ),
    ];
  }
}

// Data models for real price service
class ProductSearchResult {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final bool isOnSale;
  final String retailer;
  final String availability;
  final String shipping;
  final String url;
  final String? imageUrl;
  
  ProductSearchResult({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.isOnSale,
    required this.retailer,
    required this.availability,
    required this.shipping,
    required this.url,
    this.imageUrl,
  });
  
  factory ProductSearchResult.fromGoogleShopping(Map<String, dynamic> json) {
    // Parse Google Shopping API response
    final snippet = json['snippet'] as String? ?? '';
    final priceMatch = RegExp(r'\$(\d+\.?\d*)').firstMatch(snippet);
    final price = priceMatch != null ? double.tryParse(priceMatch.group(1)!) ?? 0.0 : 0.0;
    
    return ProductSearchResult(
      id: json['cacheId'] as String? ?? '',
      name: json['title'] as String? ?? '',
      price: price,
      isOnSale: false,
      retailer: json['displayLink'] as String? ?? '',
      availability: 'In Stock',
      shipping: 'Check retailer',
      url: json['link'] as String? ?? '',
      imageUrl: json['pagemap']?['cse_image']?[0]?['src'] as String?,
    );
  }
  
  factory ProductSearchResult.fromPriceApi(Map<String, dynamic> json) {
    return ProductSearchResult(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      isOnSale: json['on_sale'] as bool? ?? false,
      retailer: json['retailer'] as String? ?? '',
      availability: json['availability'] as String? ?? 'In Stock',
      shipping: json['shipping'] as String? ?? 'Check retailer',
      url: json['url'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
    );
  }
}

class PriceAlert {
  final String productId;
  final double targetPrice;
  final DateTime createdAt;
  bool isActive;
  DateTime? triggeredAt;
  
  PriceAlert({
    required this.productId,
    required this.targetPrice,
    required this.createdAt,
    required this.isActive,
    this.triggeredAt,
  });
  
  factory PriceAlert.fromJson(Map<String, dynamic> json) {
    return PriceAlert(
      productId: json['product_id'] as String,
      targetPrice: (json['target_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool,
      triggeredAt: json['triggered_at'] != null 
        ? DateTime.parse(json['triggered_at'] as String)
        : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'target_price': targetPrice,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'triggered_at': triggeredAt?.toIso8601String(),
    };
  }
}