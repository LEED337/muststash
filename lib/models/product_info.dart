class ProductInfo {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final bool isOnSale;
  final String retailer;
  final String description;
  final double rating;
  final int reviewCount;

  ProductInfo({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.isOnSale = false,
    required this.retailer,
    this.description = '',
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      isOnSale: json['on_sale'] as bool? ?? false,
      retailer: json['retailer'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'original_price': originalPrice,
      'image_url': imageUrl,
      'on_sale': isOnSale,
      'retailer': retailer,
      'description': description,
      'rating': rating,
      'review_count': reviewCount,
    };
  }
}