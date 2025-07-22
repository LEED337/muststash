import 'package:flutter/material.dart';
import '../services/optisigns_service.dart';

class LocationsScreenOptiSigns extends StatefulWidget {
  const LocationsScreenOptiSigns({super.key});

  @override
  State<LocationsScreenOptiSigns> createState() => _LocationsScreenOptiSignsState();
}

class _LocationsScreenOptiSignsState extends State<LocationsScreenOptiSigns> {
  final OptiSignsService _optiSignsService = OptiSignsService();
  List<Map<String, dynamic>> _screens = [];
  List<Map<String, dynamic>> _filteredScreens = [];
  bool _isLoading = true;
  bool _connectionError = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOptiSignsScreens();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOptiSignsScreens() async {
    setState(() {
      _isLoading = true;
      _connectionError = false;
    });

    try {
      // Load screens directly from OptiSigns
      final screens = await _optiSignsService.getAvailableScreens();
      
      // Transform OptiSigns screen data to match our UI format
      final transformedScreens = screens.map((screen) {
        return {
          'id': screen['id'],
          'businessName': screen['name'],
          'address': _extractAddress(screen['location']),
          'city': _extractCity(screen['location']),
          'state': _extractState(screen['location']),
          'zipCode': '',
          'businessType': _getBusinessType(screen['name']),
          'estimatedDailyViews': screen['dailyViews'],
          'pricePerDay': screen['pricePerDay'],
          'isAvailable': screen['isAvailable'] && screen['status'] == 'online',
          'status': screen['status'],
          'resolution': screen['resolution'],
          'orientation': screen['orientation'],
          'lastSeen': screen['lastSeen'],
          'optiSignsId': screen['id'], // Keep original OptiSigns ID
        };
      }).toList();

      setState(() {
        _screens = transformedScreens;
        _filteredScreens = transformedScreens;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _connectionError = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to load OptiSigns screens: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadOptiSignsScreens,
            ),
          ),
        );
      }
    }
  }

  String _extractAddress(String location) {
    final parts = location.split(',');
    return parts.isNotEmpty ? parts[0].trim() : 'Address not available';
  }

  String _extractCity(String location) {
    final parts = location.split(',');
    return parts.length > 1 ? parts[1].trim() : 'Unknown City';
  }

  String _extractState(String location) {
    final parts = location.split(',');
    if (parts.length > 1) {
      final cityState = parts[1].trim();
      final stateParts = cityState.split(' ');
      return stateParts.length > 1 ? stateParts.last : 'Unknown';
    }
    return 'Unknown';
  }

  String _getBusinessType(String screenName) {
    final name = screenName.toLowerCase();
    if (name.contains('coffee')) return 'Coffee Shop';
    if (name.contains('fitness') || name.contains('gym')) return 'Fitness Center';
    if (name.contains('mall') || name.contains('shopping')) return 'Shopping Mall';
    if (name.contains('university') || name.contains('college')) return 'University';
    if (name.contains('airport')) return 'Airport';
    if (name.contains('restaurant') || name.contains('food')) return 'Restaurant';
    if (name.contains('hotel')) return 'Hotel';
    if (name.contains('retail') || name.contains('store')) return 'Retail Store';
    return 'Business Location';
  }

  void _filterScreens(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredScreens = _screens;
      } else {
        _filteredScreens = _screens.where((screen) {
          return screen['businessName'].toLowerCase().contains(query.toLowerCase()) ||
                 screen['city'].toLowerCase().contains(query.toLowerCase()) ||
                 screen['businessType'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
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
            // Header with OptiSigns branding
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OptiSigns Screens',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse and select digital screens connected to OptiSigns',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _connectionError 
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _connectionError 
                          ? Colors.red.withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _connectionError ? Colors.red : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _connectionError ? 'CONNECTION ERROR' : 'OPTISIGNS CONNECTED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _connectionError ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Bar
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
              child: TextField(
                controller: _searchController,
                onChanged: _filterScreens,
                decoration: const InputDecoration(
                  hintText: 'Search screens, locations, or business types...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                _buildStatChip('${_filteredScreens.length} Screens', Icons.tv, Colors.blue),
                const SizedBox(width: 12),
                _buildStatChip('${_filteredScreens.where((s) => s['isAvailable']).length} Available', Icons.check_circle, Colors.green),
                const SizedBox(width: 12),
                _buildStatChip('${_filteredScreens.where((s) => !s['isAvailable']).length} Occupied', Icons.cancel, Colors.red),
              ],
            ),
            const SizedBox(height: 24),

            // Content
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
                            'Loading OptiSigns screens...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _connectionError
                      ? _buildErrorState()
                      : _filteredScreens.isEmpty
                          ? _buildEmptyState()
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.1,
                              ),
                              itemCount: _filteredScreens.length,
                              itemBuilder: (context, index) {
                                final screen = _filteredScreens[index];
                                return _buildScreenCard(screen);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Connection Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to connect to OptiSigns platform',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadOptiSignsScreens,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Connection'),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No screens found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenCard(Map<String, dynamic> screen) {
    return Container(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with availability status
            Row(
              children: [
                Expanded(
                  child: Text(
                    screen['businessName'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: screen['isAvailable'] ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    screen['isAvailable'] ? 'Available' : 'Occupied',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Business type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                screen['businessType'],
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Screen details
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${screen['city']}, ${screen['state']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Views
            Row(
              children: [
                const Icon(Icons.visibility, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${screen['estimatedDailyViews']} daily views',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Price and action button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${screen['pricePerDay'].toStringAsFixed(2)}/day',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                ElevatedButton(
                  onPressed: screen['isAvailable']
                      ? () {
                          _selectScreenForAd(screen);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    screen['isAvailable'] ? 'Select' : 'Occupied',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectScreenForAd(Map<String, dynamic> screen) {
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
                  screen['businessName'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(Icons.business, 'Business Type', screen['businessType']),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.location_on, 'Location', '${screen['address']}, ${screen['city']}, ${screen['state']}'),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.tv, 'Resolution', screen['resolution']),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.screen_rotation, 'Orientation', screen['orientation']),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.visibility, 'Daily Views', '${screen['estimatedDailyViews']} estimated views'),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.attach_money, 'Price', '\$${screen['pricePerDay'].toStringAsFixed(2)} per day'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This OptiSigns screen is available for your ads',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                _deployToScreen(screen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Deploy Ad to Screen'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _deployToScreen(Map<String, dynamic> screen) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Screen selected! Go to "My Ads" to deploy your advertisements to ${screen['businessName']}'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Go to Ads',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to ads screen - this would be handled by the parent widget
          },
        ),
      ),
    );
  }
}