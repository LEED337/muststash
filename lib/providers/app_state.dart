import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  bool _isFirstLaunch = true;
  bool _isOnboardingComplete = false;
  String _userName = '';
  bool _isPremiumUser = false;

  bool get isFirstLaunch => _isFirstLaunch;
  bool get isOnboardingComplete => _isOnboardingComplete;
  String get userName => _userName;
  bool get isPremiumUser => _isPremiumUser;

  AppState() {
    _loadAppState();
  }

  Future<void> _loadAppState() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    _isOnboardingComplete = prefs.getBool('isOnboardingComplete') ?? false;
    _userName = prefs.getString('userName') ?? '';
    _isPremiumUser = prefs.getBool('isPremiumUser') ?? false;
    notifyListeners();
  }

  Future<void> completeOnboarding(String name) async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = false;
    _isOnboardingComplete = true;
    _userName = name;
    
    await prefs.setBool('isFirstLaunch', false);
    await prefs.setBool('isOnboardingComplete', true);
    await prefs.setString('userName', name);
    
    notifyListeners();
  }

  Future<void> upgradeToPremium() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremiumUser = true;
    await prefs.setBool('isPremiumUser', true);
    notifyListeners();
  }

  Future<void> resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isFirstLaunch = true;
    _isOnboardingComplete = false;
    _userName = '';
    _isPremiumUser = false;
    notifyListeners();
  }
}