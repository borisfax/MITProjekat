class Product {
  final String id;
  final String name;
  final String description;
  final double priceRSD;
  final String imageUrl;
  final double rating;
  final String category;
  final bool inStock;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceRSD,
    required this.imageUrl,
    required this.rating,
    required this.category,
    required this.inStock,
  });

  // From JSON (from API response)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priceRSD: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      rating: 4.5, // Default rating since backend doesn't have it yet
      category: json['category'] ?? 'Bombone',
      inStock: json['isAvailable'] ?? true,
    );
  }

  // To JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': priceRSD,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': inStock,
    };
  }
}
