import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../providers/rewards_provider.dart';
import '../models/wish_item.dart';
import '../utils/theme.dart';
import '../widgets/mustache_logo.dart';


class AddRewardScreen extends StatefulWidget {
  const AddRewardScreen({super.key});

  @override
  State<AddRewardScreen> createState() => _AddRewardScreenState();
}

class _AddRewardScreenState extends State<AddRewardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _urlController = TextEditingController();
  
  String _selectedCategory = 'Electronics';
  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home',
    'Books',
    'Gaming',
    'Sports',
    'Beauty',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/rewards'),
        ),
        title: Row(
          children: [
            const MustacheLogo(size: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'MustStash',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Add New Reward',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What do you want to save for?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          hintText: 'e.g., AirPods Pro, Nintendo Switch',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an item name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Why do you want this item?',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Target Price',
                                hintText: '0.00',
                                prefixText: '\$ ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a price';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price <= 0) {
                                  return 'Please enter a valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          labelText: 'Product URL (Optional)',
                          hintText: 'https://amazon.com/...',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            color: AppTheme.accentGold,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Pro Tips',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('• Add items you really want but haven\'t bought yet'),
                      const SizedBox(height: 4),
                      const Text('• Set realistic prices based on current market value'),
                      const SizedBox(height: 4),
                      const Text('• Higher priority items will be saved for first'),
                      const SizedBox(height: 4),
                      const Text('• You can reorder your wishes anytime'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveWish,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Add to Rewards',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveWish() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final url = _urlController.text.trim();

    final rewards = context.read<RewardsProvider>();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await rewards.addWishItem(
        name: name,
        description: description.isEmpty ? 'No description provided' : description,
        targetPrice: price,
        category: _selectedCategory,
        productUrl: url.isEmpty ? null : url,
      );

      // Hide loading indicator
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name added to your rewards!'),
            backgroundColor: AppTheme.primaryGreen,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () => context.go('/rewards'),
            ),
          ),
        );

        // Navigate back to rewards screen
        context.go('/rewards');
      }
    } catch (e) {
      // Hide loading indicator
      if (mounted) Navigator.of(context).pop();
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding reward: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}