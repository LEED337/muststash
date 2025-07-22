import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:plaid_flutter/plaid_flutter.dart';
import '../models/transaction.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

class PlaidService {
  // Use configuration from ApiConfig
  static String get _clientId => ApiConfig.plaidClientId;
  static String get _secret => ApiConfig.plaidSecret;
  static String get _publicKey => ApiConfig.plaidPublicKey;
  static String get _apiUrl => ApiConfig.plaidBaseUrl;
  
  // Initialize Plaid Link (Mock implementation)
  static Future<void> initializePlaid() async {
    try {
      // Mock implementation - in real app, this would initialize Plaid SDK
      debugPrint('Plaid initialization (mock)');
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error initializing Plaid: $e');
      rethrow;
    }
  }
  
  // Open Plaid Link for bank connection (Mock implementation)
  static Future<Map<String, dynamic>?> openPlaidLink() async {
    try {
      // Mock implementation - in real app, this would open Plaid Link
      debugPrint('Opening Plaid Link (mock)');
      await Future.delayed(const Duration(seconds: 1));
      
      // Return mock result
      return {
        'publicToken': 'mock_public_token_${DateTime.now().millisecondsSinceEpoch}',
        'metadata': {
          'institution': {'name': 'Mock Bank', 'institution_id': 'mock_bank'},
          'accounts': [
            {'id': 'mock_account_1', 'name': 'Checking', 'type': 'depository'}
          ]
        }
      };
    } catch (e) {
      debugPrint('Error opening Plaid Link: $e');
      return null;
    }
  }
  
  // Exchange public token for access token
  static Future<String?> exchangePublicToken(String publicToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/link/token/exchange'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'client_id': _clientId,
          'secret': _secret,
          'public_token': publicToken,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'] as String;
        
        // Store access token securely
        await StorageService.setString('plaid_access_token', accessToken);
        
        return accessToken;
      } else {
        debugPrint('Error exchanging public token: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error exchanging public token: $e');
      return null;
    }
  }
  
  // Get account information
  static Future<List<PlaidAccount>> getAccounts() async {
    try {
      final accessToken = await StorageService.getString('plaid_access_token');
      if (accessToken == null) {
        throw Exception('No access token found');
      }
      
      final response = await http.post(
        Uri.parse('$_apiUrl/accounts/get'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'client_id': _clientId,
          'secret': _secret,
          'access_token': accessToken,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accounts = (data['accounts'] as List)
            .map((account) => PlaidAccount.fromJson(account))
            .toList();
        
        return accounts;
      } else {
        debugPrint('Error getting accounts: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error getting accounts: $e');
      return [];
    }
  }
  
  // Get transactions
  static Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int count = 100,
  }) async {
    try {
      final accessToken = await StorageService.getString('plaid_access_token');
      if (accessToken == null) {
        throw Exception('No access token found');
      }
      
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      
      final response = await http.post(
        Uri.parse('$_apiUrl/transactions/get'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'client_id': _clientId,
          'secret': _secret,
          'access_token': accessToken,
          'start_date': _formatDate(start),
          'end_date': _formatDate(end),
          'count': count,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transactions = (data['transactions'] as List)
            .map((transaction) => _convertPlaidTransaction(transaction))
            .toList();
        
        return transactions;
      } else {
        debugPrint('Error getting transactions: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error getting transactions: $e');
      return [];
    }
  }
  
  // Get account balances
  static Future<Map<String, double>> getAccountBalances() async {
    try {
      final accounts = await getAccounts();
      final balances = <String, double>{};
      
      for (final account in accounts) {
        balances[account.accountId] = account.balance;
      }
      
      return balances;
    } catch (e) {
      debugPrint('Error getting account balances: $e');
      return {};
    }
  }
  
  // Check if user has connected accounts
  static Future<bool> hasConnectedAccounts() async {
    try {
      final accessToken = await StorageService.getString('plaid_access_token');
      return accessToken != null;
    } catch (e) {
      return false;
    }
  }
  
  // Disconnect account
  static Future<bool> disconnectAccount() async {
    try {
      await StorageService.removeString('plaid_access_token');
      return true;
    } catch (e) {
      debugPrint('Error disconnecting account: $e');
      return false;
    }
  }
  
  // Helper methods
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  static Future<String> _getUserName() async {
    // Get user name from app state or storage
    return await StorageService.getString('user_name') ?? 'User';
  }
  
  static Transaction _convertPlaidTransaction(Map<String, dynamic> plaidTransaction) {
    final amount = (plaidTransaction['amount'] as num).toDouble();
    final roundedAmount = amount.ceilToDouble();
    final spareChange = roundedAmount - amount;
    
    return Transaction(
      id: plaidTransaction['transaction_id'] as String,
      amount: amount,
      spareChange: spareChange,
      merchant: plaidTransaction['merchant_name'] as String? ?? 
                   plaidTransaction['name'] as String? ?? 
                   'Unknown Merchant',
      date: DateTime.parse(plaidTransaction['date'] as String),
      category: _mapPlaidCategory(plaidTransaction['category'] as List?),
    );
  }
  
  static String _mapPlaidCategory(List? categories) {
    if (categories == null || categories.isEmpty) {
      return 'Other';
    }
    
    final primaryCategory = categories.first as String;
    
    // Map Plaid categories to our app categories
    switch (primaryCategory.toLowerCase()) {
      case 'food and drink':
        return 'Food & Dining';
      case 'shops':
        return 'Shopping';
      case 'transportation':
        return 'Transportation';
      case 'recreation':
        return 'Entertainment';
      case 'service':
        return 'Services';
      default:
        return primaryCategory;
    }
  }
}

// Plaid Account model
class PlaidAccount {
  final String accountId;
  final String name;
  final String type;
  final String subtype;
  final double balance;
  final String institutionName;
  
  PlaidAccount({
    required this.accountId,
    required this.name,
    required this.type,
    required this.subtype,
    required this.balance,
    required this.institutionName,
  });
  
  factory PlaidAccount.fromJson(Map<String, dynamic> json) {
    final balances = json['balances'] as Map<String, dynamic>;
    final balance = (balances['current'] as num?)?.toDouble() ?? 0.0;
    
    return PlaidAccount(
      accountId: json['account_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      subtype: json['subtype'] as String,
      balance: balance,
      institutionName: json['institution_name'] as String? ?? 'Unknown Bank',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'name': name,
      'type': type,
      'subtype': subtype,
      'balance': balance,
      'institution_name': institutionName,
    };
  }
}