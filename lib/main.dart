import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/app_state.dart';
import 'providers/coin_jar_provider.dart';
import 'providers/rewards_provider.dart';
import 'screens/landing_page.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/coin_jar_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/add_reward_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/bank_connection_screen_simple.dart';
import 'screens/price_comparison_screen.dart';
import 'screens/card_management_screen.dart';
import 'services/storage_service.dart';
import 'config/api_config.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  await StorageService.init();
  
  // Print API configuration for debugging
  ApiConfig.printConfig();
  
  runApp(const MustStashApp());
}

class MustStashApp extends StatelessWidget {
  const MustStashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => CoinJarProvider()),
        ChangeNotifierProvider(create: (_) => RewardsProvider()),
      ],
      child: MaterialApp.router(
        title: 'MustStash',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/coin-jar',
      builder: (context, state) => const CoinJarScreen(),
    ),
    GoRoute(
      path: '/rewards',
      builder: (context, state) => const RewardsScreen(),
    ),
    GoRoute(
      path: '/add-reward',
      builder: (context, state) => const AddRewardScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/bank-connection',
      builder: (context, state) => const BankConnectionScreen(),
    ),
    GoRoute(
      path: '/card-management',
      builder: (context, state) => const CardManagementScreen(),
    ),
    GoRoute(
      path: '/price-comparison/:itemId/:itemName',
      builder: (context, state) => PriceComparisonScreen(
        itemId: state.pathParameters['itemId']!,
        itemName: state.pathParameters['itemName']!,
      ),
    ),
  ],
);