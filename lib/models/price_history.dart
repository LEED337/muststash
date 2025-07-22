class PriceHistory {
  final DateTime date;
  final double price;
  final String retailer;

  PriceHistory({
    required this.date,
    required this.price,
    required this.retailer,
  });

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    return PriceHistory(
      date: DateTime.parse(json['date'] as String),
      price: (json['price'] as num).toDouble(),
      retailer: json['retailer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'price': price,
      'retailer': retailer,
    };
  }
}