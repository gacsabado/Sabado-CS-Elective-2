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

    return OrderItem(
      id: map['id']?.toString() ?? '',
      productId: map['product_id']?.toString(),
      productName: map['product_name']?.toString() ?? 'Unknown product',
      unitPrice: unitPrice,
      quantity: quantity,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? unitPrice * quantity,
    );
  }
}

