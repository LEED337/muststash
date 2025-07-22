import 'package:flutter/foundation.dart';

class ApiConfig {
  // Environment settings
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => kDebugMode;
  
  // Plaid Configuration
  static const String plaidClientId = String.fromEnvironment(
    'PLAID_CLIENT_ID',
    defaultValue: 'your_plaid_client_id_here',
  );
  
  static const String plaidSecret = String.fromEnvironment(
    'PLAID_SECRET',
    defaultValue: 'your_plaid_secret_here',
  );
  
  static const String plaidPublicKey = String.fromEnvironment(
    'PLAID_PUBLIC_KEY',
    defaultValue: 'your_plaid_public_key_here',
  );
  
  // Plaid Environment URLs
  static const String plaidSandboxUrl = 'https://sandbox.plaid.com';
  static const String plaidProductionUrl = 'https://production.plaid.com';
  
  static String get plaidBaseUrl => isProduction ? plaidProductionUrl : plaidSandboxUrl;
  
  // Price Comparison API Configuration
  static const String googleShoppingApiKey = String.fromEnvironment(
    'GOOGLE_SHOPPING_API_KEY',
    defaultValue: 'your_google_shopping_api_key_here',
  );
  
  static const String googleSearchEngineId = String.fromEnvironment(
    'GOOGLE_SEARCH_ENGINE_ID',
    defaultValue: 'your_search_engine_id_here',
  );
  
  static const String rapidApiKey = String.fromEnvironment(
    'RAPIDAPI_KEY',
    defaultValue: 'your_rapidapi_key_here',
  );
  
  // API Endpoints
  static const String googleShoppingUrl = 'https://www.googleapis.com/customsearch/v1';
  static const String priceComparisonApiUrl = 'https://price-comparison-api.p.rapidapi.com';
  static const String amazonApiUrl = 'https://amazon-product-api.p.rapidapi.com';
  
  // Feature Flags
  static const bool enableRealBankingApi = bool.fromEnvironment(
    'ENABLE_REAL_BANKING_API',
    defaultValue: false,
  );
  
  static const bool enableRealPriceApi = bool.fromEnvironment(
    'ENABLE_REAL_PRICE_API',
    defaultValue: false,
  );
  
  static const bool enablePushNotifications = bool.fromEnvironment(
    'ENABLE_PUSH_NOTIFICATIONS',
    defaultValue: true,
  );
  
  // App Configuration
  static const String appName = 'MustStash';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@muststash.app';
  
  // Security Configuration
  static const int sessionTimeoutMinutes = 30;
  static const int maxLoginAttempts = 5;
  static const bool requireBiometricAuth = false;
  
  // Validation methods
  static bool get hasValidPlaidConfig => 
    plaidClientId.isNotEmpty && 
    plaidSecret.isNotEmpty && 
    plaidClientId != 'your_plaid_client_id_here';
  
  static bool get hasValidPriceApiConfig => 
    googleShoppingApiKey.isNotEmpty && 
    rapidApiKey.isNotEmpty && 
    googleShoppingApiKey != 'your_google_shopping_api_key_here';
  
  // Development helpers
  static void printConfig() {
    if (isDevelopment) {
      print('=== API Configuration ===');
      print('Environment: ${isProduction ? 'Production' : 'Development'}');
      print('Plaid Config Valid: $hasValidPlaidConfig');
      print('Price API Config Valid: $hasValidPriceApiConfig');
      print('Real Banking API: $enableRealBankingApi');
      print('Real Price API: $enableRealPriceApi');
      print('Push Notifications: $enablePushNotifications');
      print('========================');
    }
  }
}