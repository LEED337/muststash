import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/coin_jar_provider.dart';
import '../utils/formatters.dart';
import '../utils/theme.dart';
import '../widgets/mustache_logo.dart';
import '../widgets/add_transaction_dialog.dart';


class CoinJarScreen extends StatefulWidget {
  const CoinJarScreen({super.key});

  @override
  State<CoinJarScreen> createState() => _CoinJarScreenState();
}

class _CoinJarScreenState extends State<CoinJarScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
                  child: Consumer<CoinJarProvider>(
                    builder: (context, coinJar, child) {
                      return Column(
                        children: [
                          _buildSummaryCard(context, coinJar),
                          _buildTabBar(),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildTransactionsTab(context, coinJar),
                                _buildAnalyticsTab(context, coinJar),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTransactionDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Purchase',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
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
                  'Coin Jar',
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

  Widget _buildSummaryCard(BuildContext context, CoinJarProvider coinJar) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Saved',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.currency(coinJar.totalSavings),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'This Week',
                    Formatters.currency(coinJar.totalSavings * coinJar.weeklyProgress),
                    Icons.calendar_today_rounded,
                    AppTheme.accentGold,
                  ),
                ),
                Container(
                  width: 2,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Transactions',
                    '${coinJar.transactions.length}',
                    Icons.receipt_long_rounded,
                    AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(BuildContext context, CoinJarProvider coinJar) {
    if (coinJar.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No transactions yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your spare change transactions will appear here when you make purchases',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: coinJar.transactions.length,
            itemBuilder: (context, index) {
              final transaction = coinJar.transactions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(transaction.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(transaction.category),
                          color: _getCategoryColor(transaction.category),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.merchantName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              transaction.category,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${Formatters.currency(transaction.originalAmount)} → ${Formatters.currency(transaction.roundedAmount)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '+${Formatters.currency(transaction.spareChange)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.timeAgo(transaction.timestamp),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: false,
                onTap: () => context.go('/home'),
              ),
              _buildNavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Coin Jar',
                isSelected: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.card_giftcard_rounded,
                label: 'Rewards',
                isSelected: false,
                onTap: () => context.go('/rewards'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryGreen : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryGreen : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'gas':
        return Icons.local_gas_station;
      case 'entertainment':
        return Icons.movie;
      case 'transportation':
        return Icons.directions_car;
      default:
        return Icons.receipt;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food':
      case 'coffee':
      case 'fast food':
        return Colors.orange;
      case 'shopping':
      case 'groceries':
        return Colors.purple;
      case 'gas & fuel':
      case 'gas':
        return Colors.blue;
      case 'entertainment':
        return Colors.red;
      case 'transportation':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food':
        return Icons.restaurant;
      case 'coffee':
        return Icons.local_cafe;
      case 'fast food':
        return Icons.fastfood;
      case 'shopping':
        return Icons.shopping_bag;
      case 'groceries':
        return Icons.local_grocery_store;
      case 'gas & fuel':
      case 'gas':
        return Icons.local_gas_station;
      case 'entertainment':
        return Icons.movie;
      case 'transportation':
        return Icons.directions_car;
      default:
        return Icons.receipt;
    }
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Transactions'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(BuildContext context, CoinJarProvider coinJar) {
    return Column(
      children: [
        _buildSearchAndFilters(context, coinJar),
        Expanded(
          child: _buildTransactionsList(context, coinJar),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, CoinJarProvider coinJar) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        coinJar.setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) => coinJar.setSearchQuery(value),
          ),
          const SizedBox(height: 16),
          // Filter row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: coinJar.selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  items: coinJar.availableCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) => coinJar.setSelectedCategory(value!),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () => _showDateRangePicker(context, coinJar),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: () {
                    _searchController.clear();
                    coinJar.clearFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context, CoinJarProvider coinJar) {
    final categoryBreakdown = coinJar.getCategoryBreakdown();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _buildAnalyticsCard(
            context,
            'Total Savings',
            Formatters.currency(coinJar.totalSavings),
            Icons.account_balance_wallet,
            AppTheme.primaryGreen,
          ),
          const SizedBox(height: 16),
          _buildAnalyticsCard(
            context,
            'Weekly Progress',
            '${(coinJar.weeklyProgress * 100).toInt()}%',
            Icons.trending_up,
            AppTheme.accentGold,
          ),
          const SizedBox(height: 16),
          _buildAnalyticsCard(
            context,
            'Average Transaction',
            Formatters.currency(coinJar.averageTransaction),
            Icons.receipt,
            Colors.blue,
          ),
          const SizedBox(height: 24),
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...categoryBreakdown.entries.map((entry) => 
            _buildCategoryBreakdownItem(context, entry.key, entry.value, coinJar.totalSavings)
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownItem(BuildContext context, String category, double amount, double total) {
    final percentage = total > 0 ? (amount / total * 100) : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: _getCategoryColor(category),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.currency(amount),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _getCategoryColor(category),
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor(category)),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  void _showDateRangePicker(BuildContext context, CoinJarProvider coinJar) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: coinJar.startDate != null && coinJar.endDate != null
          ? DateTimeRange(start: coinJar.startDate!, end: coinJar.endDate!)
          : null,
    );
    
    if (picked != null) {
      coinJar.setDateRange(picked.start, picked.end);
    }
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }
}