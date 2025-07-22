import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/theme.dart';
import '../widgets/mustache_logo.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC), // Light gray-white
              Color(0xFFE2E8F0), // Lighter gray
              Color(0xFFF1F5F9), // Very light gray
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildHeroSection(),
                _buildFeaturesSection(),
                _buildHowItWorksSection(),
                _buildCTASection(),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/muststash_logo.png',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 12),
              const Text(
                'MustStash',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B), // Dark gray
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => context.go('/onboarding'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6), // Purple
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/muststash_logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                'Turn Your Spare Change\nInto Real Savings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B), // Dark gray
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Automatically round up your purchases and save the spare change.\nReach your financial goals faster with MustStash.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: const Color(0xFF64748B), // Medium gray
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/onboarding'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6), // Purple
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFF8B5CF6).withOpacity(0.3),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Start Saving Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      // Scroll to how it works section
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Learn More',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              _buildHeroImage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6), // Purple
            Color(0xFF10B981), // Green
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.savings,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Your Digital Coin Jar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Watch your spare change grow into real savings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 48),
          const Text(
            'Why Choose MustStash?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Simple, secure, and effective ways to build your savings habit',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 48),
          _buildFeatureGrid(),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {
        'icon': Icons.credit_card,
        'title': 'Link Your Cards',
        'description': 'Securely connect your credit and debit cards for automatic savings',
      },
      {
        'icon': Icons.autorenew,
        'title': 'Auto Round-Up',
        'description': 'Every purchase is rounded up and the spare change is saved',
      },
      {
        'icon': Icons.trending_up,
        'title': 'Track Progress',
        'description': 'Watch your savings grow with detailed insights and analytics',
      },
      {
        'icon': Icons.security,
        'title': 'Bank-Level Security',
        'description': 'Your financial data is protected with enterprise-grade encryption',
      },
      {
        'icon': Icons.card_giftcard,
        'title': 'Savings Goals',
        'description': 'Set goals for things you want and save towards them automatically',
      },
      {
        'icon': Icons.insights,
        'title': 'Smart Insights',
        'description': 'Get personalized recommendations to optimize your savings',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(
          feature['icon'] as IconData,
          feature['title'] as String,
          feature['description'] as String,
        );
      },
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6), // Purple
            Color(0xFF10B981), // Green
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 48),
          const Text(
            'How It Works',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start saving in just 3 simple steps',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 48),
          _buildStepsRow(),
        ],
      ),
    );
  }

  Widget _buildStepsRow() {
    final steps = [
      {
        'number': '1',
        'title': 'Link Your Cards',
        'description': 'Securely connect your credit and debit cards to MustStash',
        'icon': Icons.credit_card,
      },
      {
        'number': '2',
        'title': 'Make Purchases',
        'description': 'Shop normally with your linked cards - no changes needed',
        'icon': Icons.shopping_cart,
      },
      {
        'number': '3',
        'title': 'Watch Savings Grow',
        'description': 'Spare change from each purchase automatically goes to your savings',
        'icon': Icons.trending_up,
      },
    ];

    return Row(
      children: steps.map((step) {
        final index = steps.indexOf(step);
        return Expanded(
          child: Column(
            children: [
              _buildStepCard(
                step['number'] as String,
                step['title'] as String,
                step['description'] as String,
                step['icon'] as IconData,
              ),
              if (index < steps.length - 1) ...[
                const SizedBox(height: 16),
                Container(
                  height: 2,
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepCard(
    String number,
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF10B981)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            icon,
            size: 32,
            color: const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6), // Purple
            Color(0xFF10B981), // Green
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Ready to Start Saving?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Join thousands of users who are already building their savings with MustStash',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/onboarding'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF8B5CF6),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get Started Free',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark gray
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/muststash_logo.png',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                'MustStash',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Turn your spare change into real savings. Start your financial journey today.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            '© 2025 MustStash. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}