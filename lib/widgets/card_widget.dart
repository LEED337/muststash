import 'package:flutter/material.dart';
import '../models/linked_card.dart';
import '../utils/theme.dart';

class CardWidget extends StatelessWidget {
  final LinkedCard card;
  final VoidCallback onToggleStatus;
  final VoidCallback onRemove;

  const CardWidget({
    super.key,
    required this.card,
    required this.onToggleStatus,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                card.cardColor,
                card.cardColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: -20,
                bottom: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              
              // Card content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with bank name and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          card.bankName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: card.isActive 
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: card.isActive 
                                      ? Colors.green.withOpacity(0.5)
                                      : Colors.red.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                card.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: card.isActive 
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              onSelected: (value) {
                                switch (value) {
                                  case 'toggle':
                                    onToggleStatus();
                                    break;
                                  case 'remove':
                                    onRemove();
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Row(
                                    children: [
                                      Icon(
                                        card.isActive 
                                            ? Icons.pause_circle_outline
                                            : Icons.play_circle_outline,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(card.isActive ? 'Deactivate' : 'Activate'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Remove', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Card number
                    Text(
                      card.cardNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Bottom row with cardholder name, expiry, and card type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARDHOLDER',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              card.cardholderName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXPIRES',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              card.expiryDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              card.cardType.icon,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card.cardType.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}