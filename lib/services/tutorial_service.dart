import 'package:flutter/material.dart';
import '../widgets/tutorial_overlay.dart';
import 'storage_service.dart';

class TutorialService {
  static const String _tutorialCompletedKey = 'tutorial_completed';
  static const String _homeTutorialKey = 'home_tutorial_completed';
  static const String _coinJarTutorialKey = 'coin_jar_tutorial_completed';
  static const String _rewardsTutorialKey = 'rewards_tutorial_completed';

  // Check if user has completed onboarding tutorial
  static Future<bool> isOnboardingCompleted() async {
    return await StorageService.getBool(_tutorialCompletedKey) ?? false;
  }

  // Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    await StorageService.setBool(_tutorialCompletedKey, true);
  }

  // Check if specific tutorial is completed
  static Future<bool> isTutorialCompleted(String tutorialKey) async {
    return await StorageService.getBool(tutorialKey) ?? false;
  }

  // Mark specific tutorial as completed
  static Future<void> completeTutorial(String tutorialKey) async {
    await StorageService.setBool(tutorialKey, true);
  }

  // Home screen tutorial steps
  static List<TutorialStep> getHomeTutorialSteps() {
    return [
      const TutorialStep(
        title: 'Welcome to Your Dashboard',
        description: 'This is your savings overview. Here you can see your total savings, recent transactions, and quick actions.',
        icon: Icons.home,
        tips: [
          'Your total savings are displayed at the top',
          'Recent transactions show your latest spare change',
          'Use quick actions for common tasks',
        ],
      ),
      const TutorialStep(
        title: 'Quick Actions',
        description: 'These buttons give you fast access to the most important features like adding rewards and viewing your coin jar.',
        icon: Icons.flash_on,
        tips: [
          'Add Reward: Set savings goals for things you want',
          'View Activity: See all your transactions',
          'Connect Bank: Link your account for automatic tracking',
        ],
      ),
      const TutorialStep(
        title: 'Savings Progress',
        description: 'Track your progress towards your savings goals and see how your spare change adds up over time.',
        icon: Icons.trending_up,
        tips: [
          'Visual progress bars show goal completion',
          'Tap on any goal to see more details',
          'Celebrate when you reach milestones!',
        ],
      ),
    ];
  }

  // Coin jar tutorial steps
  static List<TutorialStep> getCoinJarTutorialSteps() {
    return [
      const TutorialStep(
        title: 'Your Digital Coin Jar',
        description: 'This is where all your spare change collects. Every purchase you make gets rounded up automatically.',
        icon: Icons.savings,
        tips: [
          'Spare change from purchases accumulates here',
          'Filter transactions by category or date',
          'Export your data for tax purposes',
        ],
      ),
      const TutorialStep(
        title: 'Transaction History',
        description: 'See every transaction that contributed to your savings, with details about the original amount and spare change.',
        icon: Icons.history,
        tips: [
          'Swipe left on transactions for more options',
          'Use the search bar to find specific purchases',
          'Categories help you understand spending patterns',
        ],
      ),
      const TutorialStep(
        title: 'Analytics & Insights',
        description: 'Understand your spending habits with detailed breakdowns and visual charts.',
        icon: Icons.analytics,
        tips: [
          'Category breakdown shows where you spend most',
          'Monthly trends help you plan better',
          'Set weekly savings goals to stay motivated',
        ],
      ),
    ];
  }

  // Rewards tutorial steps
  static List<TutorialStep> getRewardsTutorialSteps() {
    return [
      const TutorialStep(
        title: 'Set Your Savings Goals',
        description: 'Create rewards for things you want to buy. Your spare change will help you save up for them automatically.',
        icon: Icons.card_giftcard,
        tips: [
          'Add photos to make goals more motivating',
          'Set realistic target amounts',
          'Track progress with visual indicators',
        ],
      ),
      const TutorialStep(
        title: 'Priority & Progress',
        description: 'Organize your goals by priority and watch your progress. The app shows which goals you can afford.',
        icon: Icons.flag,
        tips: [
          'Top priority goals get highlighted',
          'Green badges show when you can afford something',
          'Reorder goals by dragging them',
        ],
      ),
      const TutorialStep(
        title: 'Smart Features',
        description: 'Use price comparison to find the best deals and get notified when items go on sale.',
        icon: Icons.smart_toy,
        tips: [
          'Compare prices across different stores',
          'Set price alerts for better deals',
          'Get recommendations for similar items',
        ],
      ),
    ];
  }

  // Tutorial keys for different screens
  static const String homeTutorialKey = _homeTutorialKey;
  static const String coinJarTutorialKey = _coinJarTutorialKey;
  static const String rewardsTutorialKey = _rewardsTutorialKey;

  // Show tutorial for specific screen
  static Future<bool> shouldShowTutorial(String tutorialKey) async {
    final onboardingCompleted = await isOnboardingCompleted();
    final tutorialCompleted = await isTutorialCompleted(tutorialKey);
    return onboardingCompleted && !tutorialCompleted;
  }

  // Reset all tutorials (for testing/debugging)
  static Future<void> resetAllTutorials() async {
    await StorageService.setBool(_tutorialCompletedKey, false);
    await StorageService.setBool(_homeTutorialKey, false);
    await StorageService.setBool(_coinJarTutorialKey, false);
    await StorageService.setBool(_rewardsTutorialKey, false);
  }
}