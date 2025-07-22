import 'package:flutter/material.dart';

class LinkedCard {
  final String id;
  final String cardNumber; // Last 4 digits only for security
  final String cardholderName;
  final String expiryDate;
  final CardType cardType;
  final String bankName;
  final bool isActive;
  final DateTime linkedDate;
  final Color cardColor;
  final double totalSpareChange;
  final int transactionCount;

  LinkedCard({
    required this.id,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    required this.cardType,
    required this.bankName,
    this.isActive = true,
    required this.linkedDate,
    required this.cardColor,
    this.totalSpareChange = 0.0,
    this.transactionCount = 0,
  });

  factory LinkedCard.fromJson(Map<String, dynamic> json) {
    return LinkedCard(
      id: json['id'] as String,
      cardNumber: json['card_number'] as String,
      cardholderName: json['cardholder_name'] as String,
      expiryDate: json['expiry_date'] as String,
      cardType: CardType.values.firstWhere(
        (type) => type.name == json['card_type'],
        orElse: () => CardType.visa,
      ),
      bankName: json['bank_name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      linkedDate: DateTime.parse(json['linked_date'] as String),
      cardColor: Color(json['card_color'] as int),
      totalSpareChange: (json['total_spare_change'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transaction_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_number': cardNumber,
      'cardholder_name': cardholderName,
      'expiry_date': expiryDate,
      'card_type': cardType.name,
      'bank_name': bankName,
      'is_active': isActive,
      'linked_date': linkedDate.toIso8601String(),
      'card_color': cardColor.value,
      'total_spare_change': totalSpareChange,
      'transaction_count': transactionCount,
    };
  }

  LinkedCard copyWith({
    String? id,
    String? cardNumber,
    String? cardholderName,
    String? expiryDate,
    CardType? cardType,
    String? bankName,
    bool? isActive,
    DateTime? linkedDate,
    Color? cardColor,
    double? totalSpareChange,
    int? transactionCount,
  }) {
    return LinkedCard(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      cardholderName: cardholderName ?? this.cardholderName,
      expiryDate: expiryDate ?? this.expiryDate,
      cardType: cardType ?? this.cardType,
      bankName: bankName ?? this.bankName,
      isActive: isActive ?? this.isActive,
      linkedDate: linkedDate ?? this.linkedDate,
      cardColor: cardColor ?? this.cardColor,
      totalSpareChange: totalSpareChange ?? this.totalSpareChange,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }
}

enum CardType {
  visa,
  mastercard,
  amex,
  discover,
  other;

  String get displayName {
    switch (this) {
      case CardType.visa:
        return 'Visa';
      case CardType.mastercard:
        return 'Mastercard';
      case CardType.amex:
        return 'American Express';
      case CardType.discover:
        return 'Discover';
      case CardType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case CardType.visa:
        return Icons.credit_card;
      case CardType.mastercard:
        return Icons.credit_card;
      case CardType.amex:
        return Icons.credit_card;
      case CardType.discover:
        return Icons.credit_card;
      case CardType.other:
        return Icons.payment;
    }
  }

  Color get brandColor {
    switch (this) {
      case CardType.visa:
        return const Color(0xFF1A1F71);
      case CardType.mastercard:
        return const Color(0xFFEB001B);
      case CardType.amex:
        return const Color(0xFF006FCF);
      case CardType.discover:
        return const Color(0xFFFF6000);
      case CardType.other:
        return Colors.grey;
    }
  }
}