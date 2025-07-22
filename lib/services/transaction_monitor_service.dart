import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/card_service.dart';
import '../providers/coin_jar_provider.dart';

class TransactionMonitorService {
  static Timer? _monitoringTimer;
  static bool _isMonitoring = false;
  static CoinJarProvider? _coinJarProvider;

  /// Start monitoring card transactions
  static void startMonitoring(CoinJarProvider coinJarProvider) {
    if (_isMonitoring) return;

    _coinJarProvider = coinJarProvider;
    _isMonitoring = true;

    debugPrint('Starting card transaction monitoring...');

    // Monitor every 30 seconds (in production, this would be much less frequent)
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _checkForNewTransactions(),
    );

    // Also check immediately
    _checkForNewTransactions();
  }

  /// Stop monitoring card transactions
  static void stopMonitoring() {
    if (!_isMonitoring) return;

    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;
    _coinJarProvider = null;

    debugPrint('Stopped card transaction monitoring');
  }

  /// Check for new transactions from linked cards
  static Future<void> _checkForNewTransactions() async {
    if (_coinJarProvider == null) return;

    try {
      await _coinJarProvider!.monitorCardTransactions();
    } catch (e) {
      debugPrint('Error during transaction monitoring: $e');
    }
  }

  /// Manual trigger for checking transactions
  static Future<void> checkNow(CoinJarProvider coinJarProvider) async {
    try {
      await coinJarProvider.monitorCardTransactions();
    } catch (e) {
      debugPrint('Error during manual transaction check: $e');
    }
  }

  /// Get monitoring status
  static bool get isMonitoring => _isMonitoring;
}