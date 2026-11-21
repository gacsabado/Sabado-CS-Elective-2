class OrderItem {
  final String id;
  final String? productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  const OrderItem({
    required this.id,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    this.productId,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    final unitPrice = (map['unit_price'] as num?)?.toDouble() ?? 0;
    final quantity = (map['quantity'] as num?)?.toInt() ?? 0;

    // Prefer the snapshot taken at checkout; fall back to the live product
    // (joined as `products(name)`) for rows saved without a snapshot.
    final product = map['products'];
    final liveName = product is Map ? product['name']?.toString() : null;

    return OrderItem(
      id: map['id']?.toString() ?? '',
      productId: map['product_id']?.toString(),
      productName:
          map['product_name']?.toString() ?? liveName ?? 'Removed product',
      unitPrice: unitPrice,
      quantity: quantity,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? unitPrice * quantity,
    );
  }
}


