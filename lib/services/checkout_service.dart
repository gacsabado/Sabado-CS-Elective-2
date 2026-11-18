import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_item.dart';

class CheckoutResult {
  final String orderId;
  final String orderNumber;
  final double totalAmount;
  final String status;

  const CheckoutResult({
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
  });

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    return CheckoutResult(
      orderId: json['order_id'].toString(),
      orderNumber: json['order_number'].toString(),
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'].toString(),
    );
  }
}

class CheckoutService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<CheckoutResult> placeOrder(List<CartItem> items) async {
    if (items.isEmpty) {
      throw Exception('Your cart is empty.');
    }

    final orderItems = items.map((item) {
      return {'product_id': item.product.id, 'quantity': item.quantity};
    }).toList();

    final response = await _supabase.rpc(
      'place_order',
      params: {'p_items': orderItems},
    );

    Map<String, dynamic> result;

    if (response is Map) {
      result = Map<String, dynamic>.from(response);
    } else if (response is List &&
        response.isNotEmpty &&
        response.first is Map) {
      result = Map<String, dynamic>.from(response.first as Map);
    } else {
      throw Exception('Unexpected response from the checkout service.');
    }

    return CheckoutResult.fromJson(result);
  }
}
