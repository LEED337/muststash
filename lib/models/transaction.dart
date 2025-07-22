class Transaction {
  final String id;
  final double amount; // Original amount (for backward compatibility, keeping both)
  final double originalAmount;
  final double roundedAmount;
  final double spareChange;
  final String merchant; // Merchant name (for backward compatibility, keeping both)
  final String merchantName;
  final DateTime date; // Date (for backward compatibility, keeping both)
  final DateTime timestamp;
  final String category;
  final String? cardId; // ID of the linked card used
  final String? cardLast4; // Last 4 digits of card used

  Transaction({
    required this.id,
    required this.amount,
    required this.spareChange,
    required this.merchant,
    required this.date,
    required this.category,
    this.cardId,
    this.cardLast4,
  }) : originalAmount = amount,
       roundedAmount = amount.ceilToDouble(),
       merchantName = merchant,
       timestamp = date;

  // Alternative constructor for backward compatibility
  Transaction.legacy({
    required this.id,
    required this.originalAmount,
    required this.roundedAmount,
    required this.spareChange,
    required this.merchantName,
    required this.timestamp,
    required this.category,
    this.cardId,
    this.cardLast4,
  }) : amount = originalAmount,
       merchant = merchantName,
       date = timestamp;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'originalAmount': originalAmount,
      'roundedAmount': roundedAmount,
      'spareChange': spareChange,
      'merchant': merchant,
      'merchantName': merchantName,
      'date': date.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'cardId': cardId,
      'cardLast4': cardLast4,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: (json['amount'] ?? json['originalAmount']).toDouble(),
      spareChange: json['spareChange'].toDouble(),
      merchant: json['merchant'] ?? json['merchantName'],
      date: DateTime.parse(json['date'] ?? json['timestamp']),
      category: json['category'],
      cardId: json['cardId'],
      cardLast4: json['cardLast4'],
    );
  }

  Transaction copyWith({
    String? id,
    double? amount,
    double? spareChange,
    String? merchant,
    DateTime? date,
    String? category,
    String? cardId,
    String? cardLast4,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      spareChange: spareChange ?? this.spareChange,
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      category: category ?? this.category,
      cardId: cardId ?? this.cardId,
      cardLast4: cardLast4 ?? this.cardLast4,
    );
  }
}