import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_item.dart';
import '../models/order_item.dart';

class CheckoutResult {
  final String orderId;
  final String orderNumber;
  final double totalAmount;
  final String status;
  final List<OrderItem> items;

  const CheckoutResult({
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
    required this.items,
  });

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return CheckoutResult(
      orderId: json['order_id'].toString(),
      orderNumber: json['order_number'].toString(),
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'].toString(),
      items: rawItems is List
          ? rawItems
              .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }
}

class CheckoutService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sends ONLY product ids and quantities. The `place_order` database
  /// function looks up names and prices, checks stock, reduces stock, and
  /// saves the order and its items in a single transaction.
  Future<CheckoutResult> placeOrder(List<CartItem> items) async {
    if (items.isEmpty) {
      throw Exception('Your cart is empty.');
    }

    final payload = items
        .map((item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
            })
        .toList();

    final response = await _supabase.rpc(
      'place_order',
      params: {'p_items': payload},
    );

    if (response is Map) {
      return CheckoutResult.fromJson(Map<String, dynamic>.from(response));
    }
    if (response is List && response.isNotEmpty && response.first is Map) {
      return CheckoutResult.fromJson(
        Map<String, dynamic>.from(response.first as Map),
      );
    }

    throw Exception('Unexpected response from the checkout service.');
  }
}
