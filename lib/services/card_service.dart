import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/linked_card.dart';
import '../models/transaction.dart';
import 'storage_service.dart';

class CardService {
  static const String _linkedCardsKey = 'linked_cards';
  static final Random _random = Random();

  /// Get all linked cards
  static Future<List<LinkedCard>> getLinkedCards() async {
    try {
      final cardsJson = await StorageService.getString(_linkedCardsKey);
      if (cardsJson == null || cardsJson.isEmpty) {
        return [];
      }

      final List<dynamic> cardsList = jsonDecode(cardsJson);
      return cardsList.map((json) => LinkedCard.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading linked cards: $e');
      return [];
    }
  }

  /// Save linked cards
  static Future<void> _saveLinkedCards(List<LinkedCard> cards) async {
    try {
      final cardsJson = jsonEncode(cards.map((card) => card.toJson()).toList());
      await StorageService.setString(_linkedCardsKey, cardsJson);
    } catch (e) {
      debugPrint('Error saving linked cards: $e');
    }
  }

  /// Add a new card (simulation - in real app would use secure tokenization)
  static Future<bool> linkCard({
    required String cardNumber,
    required String cardholderName,
    required String expiryDate,
    required String cvv,
    required String bankName,
  }) async {
    try {
      // Simulate card validation delay
      await Future.delayed(const Duration(seconds: 2));

      // Basic validation
      if (cardNumber.length < 13 || cardNumber.length > 19) {
        throw Exception('Invalid card number');
      }

      if (expiryDate.length != 5 || !expiryDate.contains('/')) {
        throw Exception('Invalid expiry date format (MM/YY)');
      }

      if (cvv.length < 3 || cvv.length > 4) {
        throw Exception('Invalid CVV');
      }

      // Simulate 95% success rate
      if (_random.nextDouble() < 0.05) {
        throw Exception('Card verification failed. Please try again.');
      }

      // Determine card type from number
      final cardType = _determineCardType(cardNumber);
      
      // Create new linked card (store only last 4 digits for security)
      final newCard = LinkedCard(
        id: 'card_${DateTime.now().millisecondsSinceEpoch}',
        cardNumber: '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}',
        cardholderName: cardholderName.toUpperCase(),
        expiryDate: expiryDate,
        cardType: cardType,
        bankName: bankName,
        linkedDate: DateTime.now(),
        cardColor: _generateCardColor(cardType),
      );

      // Add to existing cards
      final existingCards = await getLinkedCards();
      existingCards.add(newCard);
      await _saveLinkedCards(existingCards);

      debugPrint('Card linked successfully: ${newCard.cardNumber}');
      return true;
    } catch (e) {
      debugPrint('Error linking card: $e');
      rethrow;
    }
  }

  /// Remove a linked card
  static Future<bool> unlinkCard(String cardId) async {
    try {
      final cards = await getLinkedCards();
      cards.removeWhere((card) => card.id == cardId);
      await _saveLinkedCards(cards);
      return true;
    } catch (e) {
      debugPrint('Error unlinking card: $e');
      return false;
    }
  }

  /// Toggle card active status
  static Future<bool> toggleCardStatus(String cardId) async {
    try {
      final cards = await getLinkedCards();
      final cardIndex = cards.indexWhere((card) => card.id == cardId);
      
      if (cardIndex != -1) {
        cards[cardIndex] = cards[cardIndex].copyWith(
          isActive: !cards[cardIndex].isActive,
        );
        await _saveLinkedCards(cards);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling card status: $e');
      return false;
    }
  }

  /// Update card spare change total
  static Future<void> updateCardSpareChange(String cardId, double spareChange) async {
    try {
      final cards = await getLinkedCards();
      final cardIndex = cards.indexWhere((card) => card.id == cardId);
      
      if (cardIndex != -1) {
        final card = cards[cardIndex];
        cards[cardIndex] = card.copyWith(
          totalSpareChange: card.totalSpareChange + spareChange,
          transactionCount: card.transactionCount + 1,
        );
        await _saveLinkedCards(cards);
      }
    } catch (e) {
      debugPrint('Error updating card spare change: $e');
    }
  }

  /// Simulate transaction monitoring for linked cards
  static Future<List<Transaction>> monitorCardTransactions() async {
    try {
      final cards = await getLinkedCards();
      final activeCards = cards.where((card) => card.isActive).toList();
      
      if (activeCards.isEmpty) return [];

      // Simulate finding new transactions
      final newTransactions = <Transaction>[];
      
      for (final card in activeCards) {
        // Simulate 30% chance of new transaction per card
        if (_random.nextDouble() < 0.3) {
          final transaction = _generateMockTransaction(card);
          newTransactions.add(transaction);
          
          // Update card spare change
          final spareChange = transaction.spareChange;
          await updateCardSpareChange(card.id, spareChange);
        }
      }

      return newTransactions;
    } catch (e) {
      debugPrint('Error monitoring card transactions: $e');
      return [];
    }
  }

  /// Get card statistics
  static Future<Map<String, dynamic>> getCardStatistics() async {
    try {
      final cards = await getLinkedCards();
      
      final totalSpareChange = cards.fold<double>(
        0.0, 
        (sum, card) => sum + card.totalSpareChange,
      );
      
      final totalTransactions = cards.fold<int>(
        0, 
        (sum, card) => sum + card.transactionCount,
      );
      
      final activeCards = cards.where((card) => card.isActive).length;
      
      return {
        'total_cards': cards.length,
        'active_cards': activeCards,
        'total_spare_change': totalSpareChange,
        'total_transactions': totalTransactions,
        'average_spare_change': totalTransactions > 0 
            ? totalSpareChange / totalTransactions 
            : 0.0,
      };
    } catch (e) {
      debugPrint('Error getting card statistics: $e');
      return {};
    }
  }

  /// Determine card type from card number
  static CardType _determineCardType(String cardNumber) {
    final number = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (number.startsWith('4')) {
      return CardType.visa;
    } else if (number.startsWith(RegExp(r'^5[1-5]')) || 
               number.startsWith(RegExp(r'^2[2-7]'))) {
      return CardType.mastercard;
    } else if (number.startsWith(RegExp(r'^3[47]'))) {
      return CardType.amex;
    } else if (number.startsWith('6')) {
      return CardType.discover;
    } else {
      return CardType.other;
    }
  }

  /// Generate card color based on type
  static Color _generateCardColor(CardType cardType) {
    final baseColors = [
      const Color(0xFF1E3A8A), // Blue
      const Color(0xFF7C3AED), // Purple
      const Color(0xFF059669), // Green
      const Color(0xFFDC2626), // Red
      const Color(0xFFEA580C), // Orange
      const Color(0xFF0891B2), // Cyan
    ];
    
    return baseColors[_random.nextInt(baseColors.length)];
  }

  /// Generate mock transaction for testing
  static Transaction _generateMockTransaction(LinkedCard card) {
    final merchants = [
      'Starbucks', 'McDonald\'s', 'Target', 'Amazon', 'Walmart',
      'Gas Station', 'Grocery Store', 'Restaurant', 'Coffee Shop',
      'Pharmacy', 'Bookstore', 'Movie Theater'
    ];
    
    final categories = [
      'Food & Dining', 'Shopping', 'Gas & Fuel', 'Entertainment',
      'Groceries', 'Health & Medical', 'Travel'
    ];
    
    final amount = 5.0 + _random.nextDouble() * 95.0; // $5-$100
    final roundedAmount = amount.ceilToDouble();
    final spareChange = roundedAmount - amount;
    
    return Transaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      amount: amount,
      spareChange: spareChange,
      merchant: merchants[_random.nextInt(merchants.length)],
      category: categories[_random.nextInt(categories.length)],
      date: DateTime.now().subtract(Duration(minutes: _random.nextInt(1440))),
      cardId: card.id,
      cardLast4: card.cardNumber.substring(card.cardNumber.length - 4),
    );
  }
}