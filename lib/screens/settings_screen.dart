import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state.dart';
import '../providers/coin_jar_provider.dart';
import '../providers/rewards_provider.dart';
import '../services/storage_service.dart';
import '../utils/theme.dart';
import '../widgets/mustache_logo.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _weeklyGoalController = TextEditingController();
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final appState = context.read<AppState>();
    final coinJar = context.read<CoinJarProvider>();
    
    _nameController.text = appState.userName;
    _weeklyGoalController.text = coinJar.weeklyGoal.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weeklyGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernAppBar(context),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildProfileSection(),
                        const SizedBox(height: 32),
                        _buildGoalsSection(),
                        const SizedBox(height: 32),
                        _buildPreferencesSection(),
                        const SizedBox(height: 32),
                        _buildDataSection(),
                        const SizedBox(height: 32),
                        _buildAboutSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/home'),
            ),
          ),
          const SizedBox(width: 16),
          const MustacheLogo(
            size: 40,
            backgroundColor: Colors.white,
            letterColor: Colors.black,
            mustacheColor: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MustStash',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return _buildSection(
          'Profile',
          Icons.person_rounded,
          [
            _buildSettingsTile(
              'Name',
              appState.userName,
              Icons.edit,
              () => _showEditNameDialog(),
            ),
            _buildSettingsTile(
              'Account Type',
              appState.isPremiumUser ? 'Premium' : 'Free',
              appState.isPremiumUser ? Icons.star : Icons.upgrade,
              appState.isPremiumUser ? null : () => _showUpgradeDialog(),
              trailing: appState.isPremiumUser 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildGoalsSection() {
    return Consumer<CoinJarProvider>(
      builder: (context, coinJar, child) {
        return _buildSection(
          'Savings Goals',
          Icons.target,
          [
            _buildSettingsTile(
              'Weekly Goal',
              '\$${coinJar.weeklyGoal.toStringAsFixed(0)}',
              Icons.edit,
              () => _showEditWeeklyGoalDialog(),
            ),
            _buildSettingsTile(
              'Progress This Week',
              '${(coinJar.weeklyProgress * 100).toInt()}%',
              Icons.trending_up,
              null,
              trailing: Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: coinJar.weeklyProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      'Preferences',
      Icons.settings,
      [
        _buildSwitchTile(
          'Push Notifications',
          'Get notified about savings milestones',
          Icons.notifications,
          _notificationsEnabled,
          (value) => setState(() => _notificationsEnabled = value),
        ),
        _buildSwitchTile(
          'Dark Mode',
          'Use dark theme throughout the app',
          Icons.dark_mode,
          _darkModeEnabled,
          (value) => setState(() => _darkModeEnabled = value),
        ),
        _buildSettingsTile(
          'Currency',
          'USD (\$)',
          Icons.attach_money,
          () => _showCurrencyDialog(),
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      'Data Management',
      Icons.storage,
      [
        _buildSettingsTile(
          'Export Data',
          'Download your data as JSON',
          Icons.download,
          () => _exportData(),
        ),
        _buildSettingsTile(
          'Reset App',
          'Clear all data and start fresh',
          Icons.refresh,
          () => _showResetDialog(),
          textColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      'About',
      Icons.info,
      [
        _buildSettingsTile(
          'Version',
          '1.0.0',
          Icons.info_outline,
          null,
        ),
        _buildSettingsTile(
          'Privacy Policy',
          'View our privacy policy',
          Icons.privacy_tip,
          () => _showPrivacyPolicy(),
        ),
        _buildSettingsTile(
          'Terms of Service',
          'View terms and conditions',
          Icons.description,
          () => _showTermsOfService(),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap, {
    Widget? trailing,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? Colors.grey[600], size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AppState>().setUserName(_nameController.text);
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditWeeklyGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Weekly Goal'),
        content: TextField(
          controller: _weeklyGoalController,
          decoration: const InputDecoration(
            labelText: 'Weekly Goal',
            prefixText: '\$ ',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final goal = double.tryParse(_weeklyGoalController.text);
              if (goal != null && goal > 0) {
                await context.read<CoinJarProvider>().setWeeklyGoal(goal);
                if (mounted) Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Get premium features for just \$5/month:'),
            SizedBox(height: 16),
            Text('• Unlimited rewards'),
            Text('• Advanced analytics'),
            Text('• Priority support'),
            Text('• No advertisements'),
            Text('• Export data'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AppState>().upgradeToPremium();
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Welcome to Premium! 🎉')),
                );
              }
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('USD (\$)'),
              leading: const Icon(Icons.attach_money),
              trailing: const Icon(Icons.check, color: AppTheme.primaryGreen),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: const Text('EUR (€)'),
              leading: const Icon(Icons.euro),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Currency support coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App'),
        content: const Text(
          'This will permanently delete all your data including transactions, rewards, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AppState>().resetApp();
              await context.read<CoinJarProvider>().clearFilters();
              if (mounted) {
                Navigator.of(context).pop();
                context.go('/onboarding');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset App', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportData() async {
    try {
      await StorageService.exportData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data exported to console (check developer tools)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting data: $e')),
        );
      }
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'MustStash Privacy Policy\n\n'
            'Your privacy is important to us. This app stores data locally on your device and does not transmit personal information to external servers.\n\n'
            'Data Collection:\n'
            '• Transaction data (stored locally)\n'
            '• Savings goals and preferences\n'
            '• App usage analytics (anonymous)\n\n'
            'Data Usage:\n'
            '• Improve app functionality\n'
            '• Provide personalized experience\n'
            '• Generate savings insights\n\n'
            'Your data remains on your device and is not shared with third parties.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'MustStash Terms of Service\n\n'
            'By using this app, you agree to the following terms:\n\n'
            '1. This is a demo application for educational purposes\n'
            '2. No real financial transactions are processed\n'
            '3. Data is stored locally on your device\n'
            '4. The app is provided "as is" without warranties\n'
            '5. Users are responsible for their own data backup\n\n'
            'For questions, please contact support.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}