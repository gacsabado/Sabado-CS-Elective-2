class Product {
  final String id;
  final String name;
  final String series;
  final double price;
  final String imageUrl;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.series,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      name: map['name'] as String,
      series: map['series'] as String,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'] as String,
      description: map['description'] as String,
    );
  }
}