import 'order_item.dart';

class Order {
  final String id;
  final String orderNumber;
  final String userId;
  final double totalAmount;
  final String status;
  final DateTime? createdAt;
  final List<OrderItem> items;
  final String? customerName;
  final String? customerEmail;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.items,
    this.createdAt,
    this.customerName,
    this.customerEmail,
  });

  static const statuses = ['pending', 'done', 'cancelled'];

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Order.fromMap(Map<String, dynamic> map) {
    final rawItems = map['order_items'];
    final profile = map['profiles'];

    String? customerName;
    String? customerEmail;
    if (profile is Map) {
      customerEmail = profile['email'] as String?;
      final name = [profile['firstname'], profile['lastname']]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .join(' ');
      customerName = name.isEmpty ? null : name;
    }

    return Order(
      id: map['id'].toString(),
      // orders.id (int8) doubles as the order number.
      orderNumber: map['id'].toString(),
      userId: map['user_id']?.toString() ?? '',
      totalAmount: (map['total'] as num?)?.toDouble() ?? 0,
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      items: rawItems is List
          ? rawItems
              .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
      customerName: customerName,
      customerEmail: customerEmail,
    );
  }
}


