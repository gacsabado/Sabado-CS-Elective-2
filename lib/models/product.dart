class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String? categoryId;
  final String categoryName;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.stockQuantity = 0,
    this.categoryId,
    this.categoryName = '',
    this.imageUrl = '',
  });

  bool get isInStock => stockQuantity > 0;

  /// Reads a row from `products`, optionally joined with `categories(name)`.
  factory Product.fromMap(Map<String, dynamic> map) {
    final category = map['categories'];

    return Product(
      id: map['id'].toString(),
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      price: (map['price'] as num).toDouble(),
      stockQuantity: (map['stock_quantity'] as num?)?.toInt() ?? 0,
      categoryId: map['category_id']?.toString(),
      categoryName: category is Map ? (category['name'] as String? ?? '') : '',
      imageUrl: map['image_url'] as String? ?? '',
    );
  }

  /// Columns written on insert / update.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
      'image_url': imageUrl,
    };
  }
}
