import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/transaction.dart';
import '../models/product_info.dart';
import '../models/price_comparison.dart';
import '../models/price_history.dart';
import '../models/deal_recommendation.dart';
import 'bank_simulation_service.dart';
import 'storage_service.dart';

/// Service adapter that switches between mock and real APIs based on configuration
class ApiServiceAdapter {
  
  // Banking API Methods
  static Future<List<BankAccount>> getConnectedAccounts() async {
    if (ApiConfig.enableRealBankingApi && ApiConfig.hasValidPlaidConfig) {
      try {
        // In a real implementation, this would call PlaidService.getAccounts()
        // For now, we'll use the mock service as fallback
        debugPrint('Real banking API would be called here');
        return await BankSimulationService.getConnectedAccounts();
      } catch (e) {
        debugPrint('Real banking API failed, falling back to mock: $e');
        return await BankSimulationService.getConnectedAccounts();
      }
    } else {
      return await BankSimulationService.getConnectedAccounts();
    }
  }
  
  static Future<bool> connectBankAccount(String bankName, String username, String password) async {
    if (ApiConfig.enableRealBankingApi && ApiConfig.hasValidPlaidConfig) {
      try {
        // In a real implementation, this would open Plaid Link
        debugPrint('Real banking API connection would be initiated here');
        return await BankSimulationService.connectBankAccount(bankName, username, password);
      } catch (e) {
        debugPrint('Real banking API failed, falling back to mock: $e');
        return await BankSimulationService.connectBankAccount(bankName, username, password);
      }
    } else {
      return await BankSimulationService.connectBankAccount(bankName, username, password);
    }
  }
  
  static Future<List<Transaction>> importTransactions({
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (ApiConfig.enableRealBankingApi && ApiConfig.hasValidPlaidConfig) {
      try {
        // In a real implementation, this would call PlaidService.getTransactions()
        debugPrint('Real transaction import would happen here');
        return await BankSimulationService.importTransactions(
          accountId: accountId,
          startDate: startDate,
          endDate: endDate,
        );
      } catch (e) {
        debugPrint('Real banking API failed, falling back to mock: $e');
        return await BankSimulationService.importTransactions(
          accountId: accountId,
          startDate: startDate,
          endDate: endDate,
        );
      }
    } else {
      return await BankSimulationService.importTransactions(
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
      );
    }
  }
  
  static Future<List<BankInfo>> getAvailableBanks() async {
    if (ApiConfig.enableRealBankingApi && ApiConfig.hasValidPlaidConfig) {
      // For Plaid, we show a generic "Connect via Plaid" option
      return [
        BankInfo(
          name: 'Connect via Plaid',
          logo: 'https://via.placeholder.com/100x50?text=Plaid',
          color: const Color(0xFF00D4AA), // Plaid brand color
        ),
      ];
    } else {
      return await BankSimulationService.getAvailableBanks();
    }
  }
  
  static Future<bool> hasConnectedAccounts() async {
    if (ApiConfig.enableRealBankingApi && ApiConfig.hasValidPlaidConfig) {
      try {
        // In a real implementation, this would check for stored Plaid access tokens
        final accessToken = await StorageService.getString('plaid_access_token');
        return accessToken != null && accessToken.isNotEmpty;
      } catch (e) {
        debugPrint('Error checking connected accounts: $e');
        return false;
      }
    } else {
      final accounts = await BankSimulationService.getConnectedAccounts();
      return accounts.isNotEmpty;
    }
  }
  
  static Future<bool> disconnectAccount() async {
    if (ApiConfig.enableRealBankingApi && ApiConfig.hasValidPlaidConfig) {
      try {
        // In a real implementation, this would revoke Plaid access tokens
        await StorageService.removeString('plaid_access_token');
        return true;
      } catch (e) {
        debugPrint('Error disconnecting account: $e');
        return false;
      }
    } else {
      // For mock service, we can simulate disconnection
      return true;
    }
  }
  
  // Price Comparison API Methods
  static Future<ProductInfo?> fetchProductInfo(String productName) async {
    if (ApiConfig.enableRealPriceApi && ApiConfig.hasValidPriceApiConfig) {
      try {
        // In a real implementation, this would call real price APIs
        debugPrint('Real price API would be called here for: $productName');
        return await _getMockProductInfo(productName);
      } catch (e) {
        debugPrint('Real price API failed, falling back to mock: $e');
        return await _getMockProductInfo(productName);
      }
    } else {
      return await _getMockProductInfo(productName);
    }
  }
  
  static Future<List<PriceComparison>> getPriceComparisons(String productName) async {
    if (ApiConfig.enableRealPriceApi && ApiConfig.hasValidPriceApiConfig) {
      try {
        // In a real implementation, this would call real price comparison APIs
        debugPrint('Real price comparison would happen here for: $productName');
        return await _getMockPriceComparisons(productName);
      } catch (e) {
        debugPrint('Real price API failed, falling back to mock: $e');
        return await _getMockPriceComparisons(productName);
      }
    } else {
      return await _getMockPriceComparisons(productName);
    }
  }
  
  static Future<List<PriceHistory>> getPriceHistory(String productId) async {
    if (ApiConfig.enableRealPriceApi && ApiConfig.hasValidPriceApiConfig) {
      try {
        // In a real implementation, this would call real price history APIs
        debugPrint('Real price history would be fetched here for: $productId');
        return await _getMockPriceHistory();
      } catch (e) {
        debugPrint('Real price API failed, falling back to mock: $e');
        return await _getMockPriceHistory();
      }
    } else {
      return await _getMockPriceHistory();
    }
  }
  
  static Future<List<DealRecommendation>> getDealRecommendations() async {
    if (ApiConfig.enableRealPriceApi && ApiConfig.hasValidPriceApiConfig) {
      try {
        // In a real implementation, this would call real deal APIs
        debugPrint('Real deal recommendations would be fetched here');
        return await _getMockDealRecommendations();
      } catch (e) {
        debugPrint('Real price API failed, falling back to mock: $e');
        return await _getMockDealRecommendations();
      }
    } else {
      return await _getMockDealRecommendations();
    }
  }
  
  static Future<bool> setPriceAlert(String productId, double targetPrice) async {
    if (ApiConfig.enableRealPriceApi && ApiConfig.hasValidPriceApiConfig) {
      try {
        // In a real implementation, this would set up real price alerts
        debugPrint('Real price alert would be set here for: $productId at \$${targetPrice.toStringAsFixed(2)}');
        return true;
      } catch (e) {
        debugPrint('Real price API failed, falling back to mock: $e');
        return true; // Mock always succeeds
      }
    } else {
      return true; // Mock always succeeds
    }
  }
  
  // Helper methods for mock data
  static Future<ProductInfo> _getMockProductInfo(String productName) async {
    return ProductInfo(
      id: 'mock-${productName.hashCode}',
      name: productName,
      price: 99.99,
      retailer: 'Sample Store',
      rating: 4.2,
      reviewCount: 156,
      isOnSale: true,
      originalPrice: 129.99,
      imageUrl: 'https://via.placeholder.com/300x300?text=${Uri.encodeComponent(productName)}',
      description: 'Mock product description for $productName',
    );
  }
  
  static Future<List<PriceComparison>> _getMockPriceComparisons(String productName) async {
    return [
      PriceComparison(
        retailer: 'Store A',
        price: 89.99,
        url: 'https://example.com/store-a',
        inStock: true,
        shippingInfo: 'Free shipping',
        rating: 4.5,
      ),
      PriceComparison(
        retailer: 'Store B',
        price: 94.99,
        url: 'https://example.com/store-b',
        inStock: true,
        shippingInfo: '\$5.99 shipping',
        rating: 4.2,
      ),
      PriceComparison(
        retailer: 'Store C',
        price: 92.99,
        url: 'https://example.com/store-c',
        inStock: false,
        shippingInfo: 'Free shipping over \$50',
        rating: 4.0,
      ),
    ];
  }
  
  static Future<List<PriceHistory>> _getMockPriceHistory() async {
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
  
  static Future<List<DealRecommendation>> _getMockDealRecommendations() async {
    return [
      DealRecommendation(
        id: 'deal-1',
        productName: 'Wireless Headphones',
        category: 'Electronics',
        originalPrice: 199.99,
        salePrice: 149.99,
        discountPercentage: 25,
        retailer: 'TechStore',
        imageUrl: 'https://via.placeholder.com/300x200?text=Headphones',
        dealUrl: 'https://example.com/headphones-deal',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
      DealRecommendation(
        id: 'deal-2',
        productName: 'Smart Watch',
        category: 'Electronics',
        originalPrice: 299.99,
        salePrice: 199.99,
        discountPercentage: 33,
        retailer: 'GadgetWorld',
        imageUrl: 'https://via.placeholder.com/300x200?text=Smart+Watch',
        dealUrl: 'https://example.com/smartwatch-deal',
        expiresAt: DateTime.now().add(const Duration(days: 2)),
      ),
    ];
  }
  
  // Utility methods
  static String getApiStatus() {
    final status = StringBuffer();
    status.writeln('=== API Service Status ===');
    status.writeln('Banking API: ${ApiConfig.enableRealBankingApi ? 'Real' : 'Mock'}');
    status.writeln('Price API: ${ApiConfig.enableRealPriceApi ? 'Real' : 'Mock'}');
    status.writeln('Plaid Config: ${ApiConfig.hasValidPlaidConfig ? 'Valid' : 'Invalid'}');
    status.writeln('Price Config: ${ApiConfig.hasValidPriceApiConfig ? 'Valid' : 'Invalid'}');
    status.writeln('========================');
    return status.toString();
  }
  
  static void printApiStatus() {
    if (kDebugMode) {
      print(getApiStatus());
    }
  }
}