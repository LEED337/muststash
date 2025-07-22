import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import '../providers/coin_jar_provider.dart';
import '../services/plaid_service.dart';
import '../utils/theme.dart';


class RealBankConnectionScreen extends StatefulWidget {
  const RealBankConnectionScreen({super.key});

  @override
  State<RealBankConnectionScreen> createState() => _RealBankConnectionScreenState();
}

class _RealBankConnectionScreenState extends State<RealBankConnectionScreen> {
  bool _isLoading = true;
  bool _isConnecting = false;
  List<PlaidAccount> _connectedAccounts = [];
  bool _hasConnectedAccounts = false;

  @override
  void initState() {
    super.initState();
    _initializePlaid();
  }

  Future<void> _initializePlaid() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize Plaid
      await PlaidService.initializePlaid();
      
      // Check if user already has connected accounts
      _hasConnectedAccounts = await PlaidService.hasConnectedAccounts();
      
      if (_hasConnectedAccounts) {
        // Load connected accounts
        _connectedAccounts = await PlaidService.getAccounts();
      }
    } catch (e) {
      debugPrint('Error initializing Plaid: $e');
      if (mounted) {
        _showErrorDialog('Failed to initialize bank connection service. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _connectBank() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      // Open Plaid Link
      final result = await PlaidService.openPlaidLink();
      
      if (result != null && result['publicToken'] != null) {
        // Exchange public token for access token
        final accessToken = await PlaidService.exchangePublicToken(result['publicToken']!);
        
        if (accessToken != null) {
          // Successfully connected - reload accounts
          await _loadConnectedAccounts();
          
          // Import transactions
          await _importTransactions();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bank connected successfully!'),
                backgroundColor: AppTheme.primaryGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          throw Exception('Failed to exchange public token');
        }
      } else if (result != null && result['error'] != null) {
        throw Exception('Plaid Link error: ${result['error']}');
      }
    } catch (e) {
      debugPrint('Error connecting bank: $e');
      if (mounted) {
        _showErrorDialog('Failed to connect bank account. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _loadConnectedAccounts() async {
    try {
      final accounts = await PlaidService.getAccounts();
      setState(() {
        _connectedAccounts = accounts;
        _hasConnectedAccounts = accounts.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Error loading connected accounts: $e');
    }
  }

  Future<void> _importTransactions() async {
    try {
      final coinJar = Provider.of<CoinJarProvider>(context, listen: false);
      final transactions = await PlaidService.getTransactions();
      
      // Add transactions to coin jar
      for (final transaction in transactions) {
        await coinJar.addImportedTransaction(transaction);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${transactions.length} transactions imported successfully!'),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error importing transactions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing transactions: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _disconnectBank() async {
    final confirmed = await _showConfirmationDialog(
      'Disconnect Bank',
      'Are you sure you want to disconnect your bank account? This will stop automatic transaction imports.',
    );
    
    if (confirmed) {
      try {
        final success = await PlaidService.disconnectAccount();
        if (success) {
          setState(() {
            _connectedAccounts.clear();
            _hasConnectedAccounts = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bank account disconnected successfully'),
                backgroundColor: AppTheme.primaryGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error disconnecting bank: $e');
        if (mounted) {
          _showErrorDialog('Failed to disconnect bank account. Please try again.');
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    return result ?? false;
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_hasConnectedAccounts) ...[
                                _buildConnectedAccountsSection(),
                                const SizedBox(height: 32),
                              ],
                              _buildBankConnectionSection(),
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
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 16),
          Image.asset(
            'assets/images/muststash_logo.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Connection',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Secure connection via Plaid',
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

  Widget _buildConnectedAccountsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Connected Accounts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _importTransactions,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                  ),
                ),
                TextButton.icon(
                  onPressed: _disconnectBank,
                  icon: const Icon(Icons.link_off),
                  label: const Text('Disconnect'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._connectedAccounts.map((account) => _buildConnectedAccountItem(account)),
      ],
    );
  }

  Widget _buildConnectedAccountItem(PlaidAccount account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.institutionName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${account.name} • ${account.type.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CONNECTED',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Balance: \$${account.balance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankConnectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _hasConnectedAccounts ? 'Connect Another Bank' : 'Connect Your Bank',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Securely connect your bank account using Plaid to automatically track transactions and round up purchases for savings.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        _buildPlaidSecurityNotice(),
        const SizedBox(height: 24),
        _buildConnectionButton(),
        const SizedBox(height: 24),
        _buildPlaidInfo(),
      ],
    );
  }

  Widget _buildPlaidSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.blue[700],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Bank-Level Security with Plaid',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSecurityFeature('🔒', 'Your credentials are encrypted and never stored'),
          _buildSecurityFeature('🏦', 'Used by thousands of financial apps'),
          _buildSecurityFeature('👀', 'Read-only access to protect your accounts'),
          _buildSecurityFeature('🛡️', 'SOC 2 Type II certified security'),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.blue[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isConnecting ? null : _connectBank,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isConnecting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _hasConnectedAccounts ? 'Connect Another Bank' : 'Connect Bank Account',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPlaidInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.network(
                'https://plaid.com/assets/img/plaid-logo.svg',
                height: 20,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.info),
              ),
              const SizedBox(width: 8),
              Text(
                'Powered by Plaid',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Plaid is a secure service that connects your bank account to MustStash. Over 11,000 financial institutions are supported, and your data is protected with bank-level security.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'By connecting your account, you agree to Plaid\'s Privacy Policy and our Terms of Service.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}