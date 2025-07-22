import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/linked_card.dart';
import '../services/card_service.dart';
import '../utils/theme.dart';
import '../widgets/card_widget.dart';

class CardManagementScreen extends StatefulWidget {
  const CardManagementScreen({super.key});

  @override
  State<CardManagementScreen> createState() => _CardManagementScreenState();
}

class _CardManagementScreenState extends State<CardManagementScreen> {
  List<LinkedCard> _linkedCards = [];
  Map<String, dynamic> _cardStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    
    try {
      final cards = await CardService.getLinkedCards();
      final stats = await CardService.getCardStatistics();
      
      setState(() {
        _linkedCards = cards;
        _cardStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading cards: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddCardDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AddCardDialog(
        onCardAdded: () {
          _loadCards();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _toggleCardStatus(LinkedCard card) async {
    final success = await CardService.toggleCardStatus(card.id);
    if (success) {
      _loadCards();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            card.isActive 
                ? 'Card deactivated' 
                : 'Card activated',
          ),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  Future<void> _removeCard(LinkedCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Card'),
        content: Text('Are you sure you want to remove ${card.cardNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await CardService.unlinkCard(card.id);
      if (success) {
        _loadCards();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card removed successfully'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/muststash_logo.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'Linked Cards',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCards,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCard(),
                    const SizedBox(height: 24),
                    _buildAddCardButton(),
                    const SizedBox(height: 24),
                    _buildCardsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Cards',
                  '${_cardStats['total_cards'] ?? 0}',
                  Icons.credit_card,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Active Cards',
                  '${_cardStats['active_cards'] ?? 0}',
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Saved',
                  '\$${(_cardStats['total_spare_change'] ?? 0.0).toStringAsFixed(2)}',
                  Icons.savings,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Transactions',
                  '${_cardStats['total_transactions'] ?? 0}',
                  Icons.receipt,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAddCardButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddCardDialog,
          borderRadius: BorderRadius.circular(12),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_card,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Link New Card',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardsSection() {
    if (_linkedCards.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.credit_card_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Cards Linked',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Link your credit or debit cards to start automatically saving spare change from your purchases.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Cards (${_linkedCards.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _linkedCards.length,
          itemBuilder: (context, index) {
            final card = _linkedCards[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CardWidget(
                card: card,
                onToggleStatus: () => _toggleCardStatus(card),
                onRemove: () => _removeCard(card),
              ),
            );
          },
        ),
      ],
    );
  }
}

class AddCardDialog extends StatefulWidget {
  final VoidCallback onCardAdded;

  const AddCardDialog({
    super.key,
    required this.onCardAdded,
  });

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _bankNameController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  Future<void> _linkCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await CardService.linkCard(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        cardholderName: _cardholderNameController.text,
        expiryDate: _expiryDateController.text,
        cvv: _cvvController.text,
        bankName: _bankNameController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card linked successfully!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        widget.onCardAdded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error linking card: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Link New Card',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your card information is encrypted and secure.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                  CardNumberInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  final digits = value.replaceAll(' ', '');
                  if (digits.length < 13 || digits.length > 19) {
                    return 'Invalid card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardholderNameController,
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  hintText: 'John Doe',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cardholder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        ExpiryDateInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length != 5) {
                          return 'Invalid format';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length < 3) {
                          return 'Invalid CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  hintText: 'Chase, Bank of America, etc.',
                  prefixIcon: Icon(Icons.account_balance),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bank name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _linkCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Link Card'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length == 2 && oldValue.text.length == 1) {
      return TextEditingValue(
        text: '$text/',
        selection: const TextSelection.collapsed(offset: 3),
      );
    }
    
    return newValue;
  }
}