
class Product {
  final String id;
  final String name;
  final String series;
  final String? categoryId;
  final String? categoryName;
  final double price;
  final String imageUrl;
  final String description;
  final int stockQuantity;

  const Product({
    required this.id,
    required this.name,
    required this.series,
    this.categoryId,
    this.categoryName,
    required this.price,
    required this.imageUrl,
    required this.description,
    this.stockQuantity = 0,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    final categoryData = map['categories'];

    String? resolvedCategoryName;

    if (categoryData is Map<String, dynamic>) {
      resolvedCategoryName = categoryData['name'] as String?;
    } else if (categoryData is List && categoryData.isNotEmpty) {
      final firstCategory = categoryData.first;
      if (firstCategory is Map<String, dynamic>) {
        resolvedCategoryName = firstCategory['name'] as String?;
      }
    }

    return Product(
      id: map['id'].toString(),
      name: map['name'] as String,
      series: map['series'] as String? ?? '',
      categoryId: map['category_id']?.toString(),
      categoryName: resolvedCategoryName,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'] as String? ?? '',
      description: map['description'] as String? ?? '',
      stockQuantity: (map['stock_quantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'series': series,
      'category_id': categoryId,
      'price': price,
      'image_url': imageUrl,
      'description': description,
      'stock_quantity': stockQuantity,
    };
  }
}
