class WishItem {
  final String id;
  final String name;
  final String description;
  final double targetPrice;
  final String imageUrl;
  final String category;
  final int priority;
  final DateTime createdAt;
  final String? productUrl;
  final bool isCompleted;

  WishItem({
    required this.id,
    required this.name,
    required this.description,
    required this.targetPrice,
    required this.imageUrl,
    required this.category,
    required this.priority,
    required this.createdAt,
    this.productUrl,
    this.isCompleted = false,
  });

  WishItem copyWith({
    String? id,
    String? name,
    String? description,
    double? targetPrice,
    String? imageUrl,
    String? category,
    int? priority,
    DateTime? createdAt,
    String? productUrl,
    bool? isCompleted,
  }) {
    return WishItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetPrice: targetPrice ?? this.targetPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      productUrl: productUrl ?? this.productUrl,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetPrice': targetPrice,
      'imageUrl': imageUrl,
      'category': category,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'productUrl': productUrl,
      'isCompleted': isCompleted,
    };
  }

  factory WishItem.fromJson(Map<String, dynamic> json) {
    return WishItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      targetPrice: json['targetPrice'].toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'],
      priority: json['priority'],
      createdAt: DateTime.parse(json['createdAt']),
      productUrl: json['productUrl'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}