import 'package:flutter/material.dart';
import '../services/optisigns_service.dart';

class AdsScreenEnhanced extends StatefulWidget {
  const AdsScreenEnhanced({super.key});

  @override
  State<AdsScreenEnhanced> createState() => _AdsScreenEnhancedState();
}

class _AdsScreenEnhancedState extends State<AdsScreenEnhanced> with TickerProviderStateMixin {
  final OptiSignsService _optiSignsService = OptiSignsService();
  late TabController _tabController;
  List<Map<String, dynamic>> _ads = [];
  List<Map<String, dynamic>> _campaigns = [];
  List<Map<String, dynamic>> _availableScreens = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load available OptiSigns screens first
      _availableScreens = await _optiSignsService.getAvailableScreens();
      
      // Load existing campaigns from OptiSigns
      final optiSignsCampaigns = await _optiSignsService.getAllCampaigns();
      
      // Simulate loading delay for UI smoothness
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock ads data (in production, these would be loaded from your database)
      // Each ad now includes OptiSigns deployment information
      final ads = [
      {
        'id': '1',
        'title': 'Summer Sale Campaign',
        'description': 'Promote our biggest summer discounts',
        'type': 'Image',
        'status': 'Active',
        'createdDate': '2024-01-15',
        'views': 1250,
        'clicks': 89,
        'budget': 150.00,
        'spent': 87.50,
        'imageUrl': null,
      },
      {
        'id': '2',
        'title': 'New Product Launch',
        'description': 'Introducing our latest innovation',
        'type': 'Video',
        'status': 'Draft',
        'createdDate': '2024-01-20',
        'views': 0,
        'clicks': 0,
        'budget': 300.00,
        'spent': 0.00,
        'imageUrl': null,
      },
      {
        'id': '3',
        'title': 'Holiday Special',
        'description': 'Limited time holiday offers',
        'type': 'Image',
        'status': 'Paused',
        'createdDate': '2024-01-10',
        'views': 2100,
        'clicks': 156,
        'budget': 200.00,
        'spent': 145.75,
        'imageUrl': null,
      },
    ];

    // Mock campaigns data
    final campaigns = [
      {
        'id': '1',
        'name': 'Q1 Marketing Push',
        'description': 'First quarter marketing campaign',
        'status': 'Active',
        'startDate': '2024-01-01',
        'endDate': '2024-03-31',
        'totalBudget': 1000.00,
        'spent': 342.25,
        'adsCount': 5,
        'locations': 3,
      },
      {
        'id': '2',
        'name': 'Brand Awareness',
        'description': 'Building brand recognition',
        'status': 'Scheduled',
        'startDate': '2024-02-01',
        'endDate': '2024-04-30',
        'totalBudget': 750.00,
        'spent': 0.00,
        'adsCount': 3,
        'locations': 2,
      },
    ];

    setState(() {
      _ads = ads;
      _campaigns = campaigns;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Advertisements',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your advertising content and campaigns',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateAdDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Ad'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                _buildStatCard('Total Ads', '${_ads.length}', Icons.campaign, Colors.blue),
                const SizedBox(width: 16),
                _buildStatCard('Active', '${_ads.where((ad) => ad['status'] == 'Active').length}', Icons.play_circle, Colors.green),
                const SizedBox(width: 16),
                _buildStatCard('Total Views', '${_ads.fold(0, (sum, ad) => sum + (ad['views'] as int))}', Icons.visibility, Colors.orange),
                const SizedBox(width: 16),
                _buildStatCard('Total Clicks', '${_ads.fold(0, (sum, ad) => sum + (ad['clicks'] as int))}', Icons.mouse, Colors.purple),
              ],
            ),
            const SizedBox(height: 24),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Advertisements'),
                  Tab(text: 'Campaigns'),
                ],
                labelColor: const Color(0xFF1E3A8A),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF1E3A8A),
                indicatorWeight: 3,
                dividerColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 24),

            // Tab Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF1E3A8A),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading your ads...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAdsTab(),
                        _buildCampaignsTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdsTab() {
    if (_ads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No advertisements yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first ad to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateAdDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Ad'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _ads.length,
      itemBuilder: (context, index) {
        final ad = _ads[index];
        return _buildAdCard(ad);
      },
    );
  }

  Widget _buildCampaignsTab() {
    if (_campaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No campaigns yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a campaign to organize your ads',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _campaigns.length,
      itemBuilder: (context, index) {
        final campaign = _campaigns[index];
        return _buildCampaignCard(campaign);
      },
    );
  }

  Widget _buildAdCard(Map<String, dynamic> ad) {
    Color statusColor;
    switch (ad['status']) {
      case 'Active':
        statusColor = Colors.green;
        break;
      case 'Paused':
        statusColor = Colors.orange;
        break;
      case 'Draft':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    ad['type'] == 'Video' ? Icons.videocam : Icons.image,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ad['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    ad['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Metrics
            Row(
              children: [
                _buildMetric('Views', ad['views'].toString(), Icons.visibility),
                const SizedBox(width: 24),
                _buildMetric('Clicks', ad['clicks'].toString(), Icons.mouse),
                const SizedBox(width: 24),
                _buildMetric('Budget', '\$${ad['budget'].toStringAsFixed(2)}', Icons.attach_money),
                const SizedBox(width: 24),
                _buildMetric('Spent', '\$${ad['spent'].toStringAsFixed(2)}', Icons.trending_up),
              ],
            ),
            const SizedBox(height: 20),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Usage',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${((ad['spent'] / ad['budget']) * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: ad['spent'] / ad['budget'],
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ad['spent'] / ad['budget'] > 0.8 ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _editAd(ad),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _toggleAdStatus(ad),
                  icon: Icon(
                    ad['status'] == 'Active' ? Icons.pause : Icons.play_arrow,
                    size: 16,
                  ),
                  label: Text(ad['status'] == 'Active' ? 'Pause' : 'Resume'),
                  style: TextButton.styleFrom(
                    foregroundColor: ad['status'] == 'Active' ? Colors.orange : Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _deleteAd(ad),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                const Spacer(),
                Text(
                  'Created ${ad['createdDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign) {
    Color statusColor;
    switch (campaign['status']) {
      case 'Active':
        statusColor = Colors.green;
        break;
      case 'Scheduled':
        statusColor = Colors.blue;
        break;
      case 'Completed':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder,
                    color: Colors.purple.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        campaign['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    campaign['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campaign Details
            Row(
              children: [
                _buildMetric('Ads', campaign['adsCount'].toString(), Icons.campaign),
                const SizedBox(width: 24),
                _buildMetric('Locations', campaign['locations'].toString(), Icons.location_on),
                const SizedBox(width: 24),
                _buildMetric('Budget', '\$${campaign['totalBudget'].toStringAsFixed(2)}', Icons.attach_money),
                const SizedBox(width: 24),
                _buildMetric('Spent', '\$${campaign['spent'].toStringAsFixed(2)}', Icons.trending_up),
              ],
            ),
            const SizedBox(height: 20),

            // Date Range
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${campaign['startDate']} - ${campaign['endDate']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCreateAdDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.add_circle, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text(
                'Create New Advertisement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          content: const SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose how you\'d like to create your advertisement:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                // Add creation options here
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createNewAd();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _createNewAd() {
    // Create a new ad with default values
    final newAd = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'New Advertisement',
      'description': 'Click edit to customize this ad',
      'type': 'Image',
      'status': 'Draft',
      'createdDate': DateTime.now().toString().substring(0, 10),
      'views': 0,
      'clicks': 0,
      'budget': 100.00,
      'spent': 0.00,
      'imageUrl': null,
    };

    setState(() {
      _ads.insert(0, newAd);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('New advertisement created! Click edit to customize it.'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _editAd(Map<String, dynamic> ad) {
    _showScreenSelectionDialog(ad);
  }

  void _showScreenSelectionDialog(Map<String, dynamic> ad) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.tv, color: Color(0xFF1E3A8A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Deploy "${ad['title']}" to OptiSigns Screens',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select which OptiSigns screens to display this advertisement:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _availableScreens.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                              SizedBox(height: 16),
                              Text('Loading OptiSigns screens...'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _availableScreens.length,
                          itemBuilder: (context, index) {
                            final screen = _availableScreens[index];
                            return _buildScreenSelectionTile(screen, ad);
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deployAdToSelectedScreens(ad);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Deploy to Screens'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScreenSelectionTile(Map<String, dynamic> screen, Map<String, dynamic> ad) {
    final isAvailable = screen['isAvailable'] && screen['status'] == 'online';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAvailable ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.tv,
            color: isAvailable ? Colors.green.shade600 : Colors.red.shade600,
            size: 20,
          ),
        ),
        title: Text(
          screen['name'],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              screen['location'],
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isAvailable ? 'Available' : 'Occupied',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${screen['dailyViews']} daily views',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: isAvailable
            ? Checkbox(
                value: ad['selectedScreens']?.contains(screen['id']) ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    ad['selectedScreens'] ??= <String>[];
                    if (value == true) {
                      ad['selectedScreens'].add(screen['id']);
                    } else {
                      ad['selectedScreens'].remove(screen['id']);
                    }
                  });
                },
                activeColor: const Color(0xFF1E3A8A),
              )
            : const Icon(Icons.block, color: Colors.red),
      ),
    );
  }

  Future<void> _deployAdToSelectedScreens(Map<String, dynamic> ad) async {
    final selectedScreens = ad['selectedScreens'] as List<String>? ?? [];
    
    if (selectedScreens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one screen to deploy the ad'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            SizedBox(height: 16),
            Text('Deploying ad to OptiSigns screens...'),
          ],
        ),
      ),
    );

    try {
      // Deploy to OptiSigns
      final success = await _optiSignsService.deployAdToScreens(
        adId: ad['id'],
        adTitle: ad['title'],
        screenIds: selectedScreens,
        contentUrl: ad['imageUrl'] ?? 'https://example.com/placeholder-ad.jpg',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(days: 30)),
        settings: {
          'type': ad['type'],
          'description': ad['description'],
        },
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        // Update ad status
        setState(() {
          ad['status'] = 'Active';
          ad['deployedScreens'] = selectedScreens;
          ad['lastDeployed'] = DateTime.now().toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Successfully deployed "${ad['title']}" to ${selectedScreens.length} OptiSigns screens!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        throw Exception('Deployment failed');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to deploy ad: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _toggleAdStatus(Map<String, dynamic> ad) {
    setState(() {
      ad['status'] = ad['status'] == 'Active' ? 'Paused' : 'Active';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              ad['status'] == 'Active' ? Icons.play_circle : Icons.pause_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text('Ad "${ad['title']}" ${ad['status'] == 'Active' ? 'resumed' : 'paused'}'),
          ],
        ),
        backgroundColor: ad['status'] == 'Active' ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _deleteAd(Map<String, dynamic> ad) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Advertisement'),
            ],
          ),
          content: Text('Are you sure you want to delete "${ad['title']}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _ads.removeWhere((item) => item['id'] == ad['id']);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Ad "${ad['title']}" deleted'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}