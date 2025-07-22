class DealRecommendation {
  final String id;
  final String productName;
  final String retailer;
  final double originalPrice;
  final double salePrice;
  final double discountPercentage;
  final String imageUrl;
  final String dealUrl;
  final DateTime expiresAt;
  final String category;

  DealRecommendation({
    required this.id,
    required this.productName,
    required this.retailer,
    required this.originalPrice,
    required this.salePrice,
    required this.discountPercentage,
    required this.imageUrl,
    required this.dealUrl,
    required this.expiresAt,
    this.category = '',
  });

  factory DealRecommendation.fromJson(Map<String, dynamic> json) {
    return DealRecommendation(
      id: json['id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      retailer: json['retailer'] as String? ?? '',
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['sale_price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String? ?? '',
      dealUrl: json['deal_url'] as String? ?? '',
      expiresAt: DateTime.parse(json['expires_at'] as String),
      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'retailer': retailer,
      'original_price': originalPrice,
      'sale_price': salePrice,
      'discount_percentage': discountPercentage,
      'image_url': imageUrl,
      'deal_url': dealUrl,
      'expires_at': expiresAt.toIso8601String(),
      'category': category,
    };
  }
}