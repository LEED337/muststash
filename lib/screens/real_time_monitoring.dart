import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class RealTimeMonitoring extends StatefulWidget {
  const RealTimeMonitoring({super.key});

  @override
  State<RealTimeMonitoring> createState() => _RealTimeMonitoringState();
}

class _RealTimeMonitoringState extends State<RealTimeMonitoring> with TickerProviderStateMixin {
  late TabController _tabController;
  late Timer _updateTimer;
  bool _isMonitoring = true;
  
  // Real-time data
  Map<String, dynamic> _liveMetrics = {};
  List<Map<String, dynamic>> _activeCampaigns = [];
  List<Map<String, dynamic>> _recentAlerts = [];
  List<Map<String, dynamic>> _livePerformanceData = [];
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _chartController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _initializeData();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    _tabController.dispose();
    _pulseController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  void _initializeData() {
    _liveMetrics = {
      'activeScreens': 12,
      'liveImpressions': 1847,
      'currentCTR': 4.8,
      'revenueToday': 234.56,
      'alertsCount': 3,
      'campaignsRunning': 5,
    };

    _activeCampaigns = [
      {
        'id': '1',
        'name': 'Summer Sale Blitz',
        'status': 'Live',
        'impressions': 2341,
        'clicks': 127,
        'ctr': 5.4,
        'budget': 500.0,
        'spent': 187.45,
        'locations': 4,
        'health': 'Excellent',
        'lastUpdate': DateTime.now(),
      },
      {
        'id': '2',
        'name': 'New Product Launch',
        'status': 'Live',
        'impressions': 1876,
        'clicks': 89,
        'ctr': 4.7,
        'budget': 300.0,
        'spent': 142.30,
        'locations': 3,
        'health': 'Good',
        'lastUpdate': DateTime.now(),
      },
      {
        'id': '3',
        'name': 'Holiday Promotion',
        'status': 'Warning',
        'impressions': 987,
        'clicks': 23,
        'ctr': 2.3,
        'budget': 200.0,
        'spent': 156.78,
        'locations': 2,
        'health': 'Needs Attention',
        'lastUpdate': DateTime.now(),
      },
    ];

    _recentAlerts = [
      {
        'id': '1',
        'type': 'Performance',
        'severity': 'Warning',
        'title': 'Low CTR Detected',
        'message': 'Holiday Promotion CTR dropped below 3%',
        'campaign': 'Holiday Promotion',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'isRead': false,
      },
      {
        'id': '2',
        'type': 'Budget',
        'severity': 'Critical',
        'title': 'Budget Threshold Exceeded',
        'message': 'Holiday Promotion spent 78% of budget',
        'campaign': 'Holiday Promotion',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 12)),
        'isRead': false,
      },
      {
        'id': '3',
        'type': 'System',
        'severity': 'Info',
        'title': 'New Screen Connected',
        'message': 'Downtown Coffee Shop #2 is now live',
        'campaign': null,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 18)),
        'isRead': true,
      },
    ];

    // Initialize performance data for the last hour
    _livePerformanceData = List.generate(12, (index) {
      final time = DateTime.now().subtract(Duration(minutes: (11 - index) * 5));
      return {
        'time': time,
        'impressions': 150 + math.Random().nextInt(100),
        'clicks': 5 + math.Random().nextInt(15),
        'revenue': 12.5 + math.Random().nextDouble() * 25,
      };
    });
  }

  void _startRealTimeUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isMonitoring) {
        _updateLiveData();
      }
    });
  }

  void _updateLiveData() {
    setState(() {
      // Update live metrics with realistic fluctuations
      _liveMetrics['liveImpressions'] += math.Random().nextInt(20) - 5;
      _liveMetrics['currentCTR'] = 4.5 + math.Random().nextDouble() * 1.0;
      _liveMetrics['revenueToday'] += math.Random().nextDouble() * 5;
      
      // Update campaign data
      for (var campaign in _activeCampaigns) {
        campaign['impressions'] += math.Random().nextInt(10);
        campaign['clicks'] += math.Random().nextInt(3);
        campaign['ctr'] = (campaign['clicks'] / campaign['impressions'] * 100);
        campaign['spent'] += math.Random().nextDouble() * 2;
        campaign['lastUpdate'] = DateTime.now();
      }

      // Add new performance data point
      _livePerformanceData.add({
        'time': DateTime.now(),
        'impressions': 150 + math.Random().nextInt(100),
        'clicks': 5 + math.Random().nextInt(15),
        'revenue': 12.5 + math.Random().nextDouble() * 25,
      });

      // Keep only last 12 data points (1 hour)
      if (_livePerformanceData.length > 12) {
        _livePerformanceData.removeAt(0);
      }

      // Occasionally add new alerts
      if (math.Random().nextDouble() < 0.1) {
        _addRandomAlert();
      }
    });

    _chartController.forward().then((_) {
      _chartController.reset();
    });
  }

  void _addRandomAlert() {
    final alertTypes = ['Performance', 'Budget', 'System'];
    final severities = ['Info', 'Warning', 'Critical'];
    final messages = [
      'Campaign performance spike detected',
      'New high-performing location identified',
      'Optimal timing window detected',
      'Budget utilization milestone reached',
    ];

    final newAlert = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': alertTypes[math.Random().nextInt(alertTypes.length)],
      'severity': severities[math.Random().nextInt(severities.length)],
      'title': 'Real-time Update',
      'message': messages[math.Random().nextInt(messages.length)],
      'campaign': _activeCampaigns[math.Random().nextInt(_activeCampaigns.length)]['name'],
      'timestamp': DateTime.now(),
      'isRead': false,
    };

    _recentAlerts.insert(0, newAlert);
    _liveMetrics['alertsCount'] = _recentAlerts.where((alert) => !alert['isRead']).length;

    // Keep only last 10 alerts
    if (_recentAlerts.length > 10) {
      _recentAlerts.removeLast();
    }
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
            // Header with Live Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Real-Time Monitoring',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _isMonitoring 
                                    ? Colors.green.withOpacity(0.1 + 0.1 * _pulseController.value)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isMonitoring 
                                      ? Colors.green.withOpacity(0.3 + 0.3 * _pulseController.value)
                                      : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _isMonitoring ? Colors.green : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isMonitoring ? 'LIVE' : 'PAUSED',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _isMonitoring ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitor your campaigns in real-time with live updates',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                // Control Buttons
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isMonitoring = !_isMonitoring;
                        });
                      },
                      icon: Icon(_isMonitoring ? Icons.pause : Icons.play_arrow),
                      label: Text(_isMonitoring ? 'Pause' : 'Resume'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isMonitoring ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showNotificationSettings(),
                      icon: const Icon(Icons.notifications),
                      label: const Text('Alerts'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Live Metrics Row
            Row(
              children: [
                _buildLiveMetricCard(
                  'Live Impressions',
                  _liveMetrics['liveImpressions'].toString(),
                  Icons.visibility,
                  Colors.blue,
                  isLive: true,
                ),
                const SizedBox(width: 16),
                _buildLiveMetricCard(
                  'Current CTR',
                  '${_liveMetrics['currentCTR'].toStringAsFixed(1)}%',
                  Icons.mouse,
                  Colors.green,
                  isLive: true,
                ),
                const SizedBox(width: 16),
                _buildLiveMetricCard(
                  'Revenue Today',
                  '\$${_liveMetrics['revenueToday'].toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.purple,
                  isLive: true,
                ),
                const SizedBox(width: 16),
                _buildLiveMetricCard(
                  'Active Alerts',
                  _liveMetrics['alertsCount'].toString(),
                  Icons.warning,
                  _liveMetrics['alertsCount'] > 0 ? Colors.red : Colors.grey,
                  isLive: _liveMetrics['alertsCount'] > 0,
                ),
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
                  Tab(text: 'Live Campaigns'),
                  Tab(text: 'Performance'),
                  Tab(text: 'Alerts'),
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLiveCampaignsTab(),
                  _buildPerformanceTab(),
                  _buildAlertsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } 
 Widget _buildLiveMetricCard(String title, String value, IconData icon, Color color, {bool isLive = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                if (isLive)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.5 + 0.5 * _pulseController.value),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
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

  Widget _buildLiveCampaignsTab() {
    return ListView.builder(
      itemCount: _activeCampaigns.length,
      itemBuilder: (context, index) {
        final campaign = _activeCampaigns[index];
        return _buildLiveCampaignCard(campaign);
      },
    );
  }

  Widget _buildLiveCampaignCard(Map<String, dynamic> campaign) {
    Color statusColor;
    Color healthColor;
    
    switch (campaign['status']) {
      case 'Live':
        statusColor = Colors.green;
        break;
      case 'Warning':
        statusColor = Colors.orange;
        break;
      case 'Error':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    switch (campaign['health']) {
      case 'Excellent':
        healthColor = Colors.green;
        break;
      case 'Good':
        healthColor = Colors.blue;
        break;
      case 'Needs Attention':
        healthColor = Colors.orange;
        break;
      case 'Critical':
        healthColor = Colors.red;
        break;
      default:
        healthColor = Colors.grey;
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
                        'Last updated: ${_formatTime(campaign['lastUpdate'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            campaign['status'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: healthColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: healthColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        campaign['health'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: healthColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Live Metrics
            Row(
              children: [
                _buildCampaignMetric('Impressions', campaign['impressions'].toString(), Icons.visibility),
                const SizedBox(width: 24),
                _buildCampaignMetric('Clicks', campaign['clicks'].toString(), Icons.mouse),
                const SizedBox(width: 24),
                _buildCampaignMetric('CTR', '${campaign['ctr'].toStringAsFixed(1)}%', Icons.trending_up),
                const SizedBox(width: 24),
                _buildCampaignMetric('Locations', campaign['locations'].toString(), Icons.location_on),
              ],
            ),
            const SizedBox(height: 20),

            // Budget Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Usage',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${campaign['spent'].toStringAsFixed(2)} / \$${campaign['budget'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: campaign['spent'] / campaign['budget'],
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    campaign['spent'] / campaign['budget'] > 0.8 ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showCampaignDetails(campaign),
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _optimizeCampaign(campaign),
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text('Optimize'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _pauseCampaign(campaign),
                  icon: const Icon(Icons.pause, size: 16),
                  label: const Text('Pause'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignMetric(String label, String value, IconData icon) {
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

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Performance Chart
          Container(
            height: 300,
            padding: const EdgeInsets.all(20),
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
                    const Text(
                      'Live Performance (Last Hour)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1 + 0.1 * _pulseController.value),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'LIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildLivePerformanceChart(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Performance Insights
          Row(
            children: [
              Expanded(
                child: _buildPerformanceInsightCard(
                  'Peak Performance',
                  '2:30 PM',
                  'Highest CTR in the last hour',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerformanceInsightCard(
                  'Best Location',
                  'Downtown Coffee',
                  'Leading in impressions',
                  Icons.location_on,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerformanceInsightCard(
                  'Optimization Tip',
                  'Increase Budget',
                  'Summer Sale performing well',
                  Icons.lightbulb,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLivePerformanceChart() {
    return AnimatedBuilder(
      animation: _chartController,
      builder: (context, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _livePerformanceData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final maxImpressions = _livePerformanceData.map((d) => d['impressions'] as int).reduce(math.max);
            final height = (data['impressions'] as int) / maxImpressions * 200 * _chartController.value;
            
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 20,
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index == _livePerformanceData.length - 1 
                          ? Colors.green.withOpacity(0.8)
                          : Colors.blue.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data['time'].hour}:${data['time'].minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPerformanceInsightCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    return Column(
      children: [
        // Alert Summary
        Container(
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
          child: Row(
            children: [
              _buildAlertSummaryItem('Critical', _recentAlerts.where((a) => a['severity'] == 'Critical').length, Colors.red),
              const SizedBox(width: 24),
              _buildAlertSummaryItem('Warning', _recentAlerts.where((a) => a['severity'] == 'Warning').length, Colors.orange),
              const SizedBox(width: 24),
              _buildAlertSummaryItem('Info', _recentAlerts.where((a) => a['severity'] == 'Info').length, Colors.blue),
              const Spacer(),
              TextButton(
                onPressed: () => _markAllAlertsAsRead(),
                child: const Text('Mark All as Read'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Alerts List
        Expanded(
          child: ListView.builder(
            itemCount: _recentAlerts.length,
            itemBuilder: (context, index) {
              final alert = _recentAlerts[index];
              return _buildAlertCard(alert);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlertSummaryItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    Color severityColor;
    IconData severityIcon;
    
    switch (alert['severity']) {
      case 'Critical':
        severityColor = Colors.red;
        severityIcon = Icons.error;
        break;
      case 'Warning':
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      case 'Info':
        severityColor = Colors.blue;
        severityIcon = Icons.info;
        break;
      default:
        severityColor = Colors.grey;
        severityIcon = Icons.notifications;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert['isRead'] ? Colors.grey.shade200 : severityColor.withOpacity(0.3),
          width: alert['isRead'] ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(severityIcon, color: severityColor, size: 20),
        ),
        title: Text(
          alert['title'],
          style: TextStyle(
            fontSize: 14,
            fontWeight: alert['isRead'] ? FontWeight.normal : FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert['message'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (alert['campaign'] != null) ...[
                  Icon(Icons.campaign, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    alert['campaign'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  _formatTime(alert['timestamp']),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: !alert['isRead'] 
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: severityColor,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _markAlertAsRead(alert),
      ),
    );
  }

  // Helper Methods
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.notifications, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text('Notification Settings'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Configure your real-time alert preferences:'),
              SizedBox(height: 16),
              // Add notification settings here
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showCampaignDetails(Map<String, dynamic> campaign) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing details for ${campaign['name']}'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _optimizeCampaign(Map<String, dynamic> campaign) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Optimizing ${campaign['name']}...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _pauseCampaign(Map<String, dynamic> campaign) {
    setState(() {
      campaign['status'] = 'Paused';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${campaign['name']} paused'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _markAlertAsRead(Map<String, dynamic> alert) {
    setState(() {
      alert['isRead'] = true;
      _liveMetrics['alertsCount'] = _recentAlerts.where((alert) => !alert['isRead']).length;
    });
  }

  void _markAllAlertsAsRead() {
    setState(() {
      for (var alert in _recentAlerts) {
        alert['isRead'] = true;
      }
      _liveMetrics['alertsCount'] = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All alerts marked as read'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}