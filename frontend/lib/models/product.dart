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
}
