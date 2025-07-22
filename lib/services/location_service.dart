import '../models/screen_location.dart';

class LocationService {
  // Mock data for demo - replace with real API calls
  static List<ScreenLocation> getMockLocations() {
    return [
      ScreenLocation(
        id: '1',
        businessName: 'Downtown Coffee Shop',
        address: '123 Main St',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        businessType: 'Coffee Shop',
        latitude: 40.7128,
        longitude: -74.0060,
        estimatedDailyViews: 500,
        pricePerDay: 25.00,
        isAvailable: true,
      ),
      ScreenLocation(
        id: '2',
        businessName: 'Metro Fitness Center',
        address: '456 Broadway Ave',
        city: 'New York',
        state: 'NY',
        zipCode: '10002',
        businessType: 'Fitness Center',
        latitude: 40.7589,
        longitude: -73.9851,
        estimatedDailyViews: 800,
        pricePerDay: 45.00,
        isAvailable: true,
      ),
      ScreenLocation(
        id: '3',
        businessName: 'City Mall Food Court',
        address: '789 Shopping Blvd',
        city: 'Los Angeles',
        state: 'CA',
        zipCode: '90210',
        businessType: 'Shopping Mall',
        latitude: 34.0522,
        longitude: -118.2437,
        estimatedDailyViews: 1200,
        pricePerDay: 75.00,
        isAvailable: false,
        currentAdId: 'ad123',
      ),
      ScreenLocation(
        id: '4',
        businessName: 'University Student Center',
        address: '321 College Way',
        city: 'Austin',
        state: 'TX',
        zipCode: '78701',
        businessType: 'University',
        latitude: 30.2672,
        longitude: -97.7431,
        estimatedDailyViews: 600,
        pricePerDay: 35.00,
        isAvailable: true,
      ),
      ScreenLocation(
        id: '5',
        businessName: 'Airport Terminal B',
        address: '100 Airport Rd',
        city: 'Miami',
        state: 'FL',
        zipCode: '33126',
        businessType: 'Airport',
        latitude: 25.7617,
        longitude: -80.1918,
        estimatedDailyViews: 2000,
        pricePerDay: 120.00,
        isAvailable: true,
      ),
    ];
  }

  Future<List<ScreenLocation>> getAvailableLocations() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return getMockLocations();
  }

  Future<List<ScreenLocation>> searchLocations(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final locations = getMockLocations();
    
    if (query.isEmpty) return locations;
    
    return locations.where((location) {
      return location.businessName.toLowerCase().contains(query.toLowerCase()) ||
             location.city.toLowerCase().contains(query.toLowerCase()) ||
             location.businessType.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}