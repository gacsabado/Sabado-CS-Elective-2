
class Product {
  final String id;
  final String name;
  final String series;
  final double price;
  final String imageUrl;
  final String description;
  final int stockQuantity;

  const Product({
    required this.id,
    required this.name,
    required this.series,
    required this.price,
    required this.imageUrl,
    required this.description,
    this.stockQuantity = 0,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      name: map['name'] as String,
      series: map['series'] as String? ?? '',
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
      'price': price,
      'image_url': imageUrl,
      'description': description,
      'stock_quantity': stockQuantity,
    };
  }
}
