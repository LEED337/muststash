import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  bool _isFirstLaunch = true;
  bool _isOnboardingComplete = false;
  String _userName = '';
  bool _isPremiumUser = false;
  bool _isLoading = true;

  bool get isFirstLaunch => _isFirstLaunch;
  bool get isOnboardingComplete => _isOnboardingComplete;
  String get userName => _userName;
  bool get isPremiumUser => _isPremiumUser;
  bool get isLoading => _isLoading;

  AppState() {
    _loadAppState();
  }

  Future<void> _loadAppState() async {
    try {
      _isOnboardingComplete = await StorageService.isOnboardingComplete();
      _userName = await StorageService.getUserName();
      _isPremiumUser = await StorageService.isPremiumUser();
      _isFirstLaunch = !_isOnboardingComplete;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading app state: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding(String name) async {
    try {
      _isFirstLaunch = false;
      _isOnboardingComplete = true;
      _userName = name;
      
      await StorageService.setOnboardingComplete(true);
      await StorageService.setUserName(name);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
    }
  }

  Future<void> setUserName(String name) async {
    try {
      _userName = name;
      await StorageService.setUserName(name);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting user name: $e');
    }
  }

  Future<void> upgradeToPremium() async {
    try {
      _isPremiumUser = true;
      await StorageService.setPremiumUser(true);
      notifyListeners();
    } catch (e) {
      debugPrint('Error upgrading to premium: $e');
    }
  }

  Future<void> resetApp() async {
    try {
      await StorageService.clearAllData();
      _isFirstLaunch = true;
      _isOnboardingComplete = false;
      _userName = '';
      _isPremiumUser = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting app: $e');
    }
  }
}