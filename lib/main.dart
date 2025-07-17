import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/app_state.dart';
import 'providers/coin_jar_provider.dart';
import 'providers/wish_stash_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/coin_jar_screen.dart';
import 'screens/wish_stash_screen.dart';
import 'screens/add_wish_screen.dart';
import 'utils/theme.dart';

void main() {
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
        ChangeNotifierProvider(create: (_) => WishStashProvider()),
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
      builder: (context, state) => const WishStashScreen(),
    ),
    GoRoute(
      path: '/add-reward',
      builder: (context, state) => const AddWishScreen(),
    ),
  ],
);