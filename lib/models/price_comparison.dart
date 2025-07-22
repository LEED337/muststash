class PriceComparison {
  final String retailer;
  final double price;
  final String url;
  final bool inStock;
  final String shippingInfo;
  final double rating;

  PriceComparison({
    required this.retailer,
    required this.price,
    required this.url,
    this.inStock = true,
    this.shippingInfo = '',
    this.rating = 0.0,
  });

  factory PriceComparison.fromJson(Map<String, dynamic> json) {
    return PriceComparison(
      retailer: json['retailer'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      url: json['url'] as String? ?? '',
      inStock: json['in_stock'] as bool? ?? true,
      shippingInfo: json['shipping_info'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'retailer': retailer,
      'price': price,
      'url': url,
      'in_stock': inStock,
      'shipping_info': shippingInfo,
      'rating': rating,
    };
  }
}