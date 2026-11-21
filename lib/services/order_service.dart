import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';

/// The only place that reads orders / order_items or updates order status.
/// Orders are never inserted from the app; see CheckoutService.
class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const _items = 'order_items (id, product_id, product_name, '
      'unit_price, quantity, subtotal)';

  // Customer: own orders, newest first (RLS also enforces "own only").
  Future<List<Order>> getMyOrders(String userId) async {
    final rows = await _supabase
        .from('orders')
        .select('id, order_number, user_id, total_amount, status, '
            'created_at, $_items')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows).map(Order.fromMap).toList();
  }

  // Admin: every order with the customer's name and email.
  Future<List<Order>> getAllOrders() async {
    final rows = await _supabase
        .from('orders')
        .select('id, order_number, user_id, total_amount, status, '
            'created_at, profiles (email, first_name, last_name), $_items')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows).map(Order.fromMap).toList();
  }

  Future<void> updateStatus(String orderId, String status) async {
    final updated = await _supabase
        .from('orders')
        .update({'status': status})
        .eq('id', orderId)
        .select('id');

    if (updated.isEmpty) {
      throw Exception('The order status could not be updated. You may not '
          'have permission.');
    }
  }
}
