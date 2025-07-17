class Transaction {
  final String id;
  final double originalAmount;
  final double roundedAmount;
  final double spareChange;
  final String merchantName;
  final DateTime timestamp;
  final String category;

  Transaction({
    required this.id,
    required this.originalAmount,
    required this.roundedAmount,
    required this.spareChange,
    required this.merchantName,
    required this.timestamp,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalAmount': originalAmount,
      'roundedAmount': roundedAmount,
      'spareChange': spareChange,
      'merchantName': merchantName,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      originalAmount: json['originalAmount'].toDouble(),
      roundedAmount: json['roundedAmount'].toDouble(),
      spareChange: json['spareChange'].toDouble(),
      merchantName: json['merchantName'],
      timestamp: DateTime.parse(json['timestamp']),
      category: json['category'],
    );
  }
}