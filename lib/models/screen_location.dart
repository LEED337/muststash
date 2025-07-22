class ScreenLocation {
  final String id;
  final String businessName;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String businessType;
  final double latitude;
  final double longitude;
  final int estimatedDailyViews;
  final double pricePerDay;
  final bool isAvailable;
  final String? currentAdId;
  final String? imageUrl;

  ScreenLocation({
    required this.id,
    required this.businessName,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.businessType,
    required this.latitude,
    required this.longitude,
    required this.estimatedDailyViews,
    required this.pricePerDay,
    this.isAvailable = true,
    this.currentAdId,
    this.imageUrl,
  });

  String get fullAddress => '$address, $city, $state $zipCode';
  String get pricePerDayFormatted => '\$${pricePerDay.toStringAsFixed(2)}';
  String get estimatedViewsFormatted => '${estimatedDailyViews.toString()} daily views';
}