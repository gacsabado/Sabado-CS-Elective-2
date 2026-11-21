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

  /*Admin: every order with the customer's name and email.
  Future<List<Order>> getAllOrders() async {
    final rows = await _supabase
        .from('orders')
        .select('id, order_number, user_id, total_amount, status, '
            'created_at, profiles (email, first_name, last_name), $_items')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows).map(Order.fromMap).toList();
  }
*/
  // Admin: every order with customer details.
  // Fetch profiles separately to avoid requiring an orders -> profiles
  // foreign-key relationship.
  Future<List<Order>> getAllOrders() async {
    final rows = await _supabase
        .from('orders')
        .select('id, order_number, user_id, total_amount, status, '
            'created_at, $_items')
        .order('created_at', ascending: false);

    final orderRows = List<Map<String, dynamic>>.from(rows);

    // Collect customer IDs from the orders.
    final userIds = orderRows
        .map((row) => row['user_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    // Fetch profiles separately instead of using a nested relationship.
    final profileMap = <String, Map<String, dynamic>>{};

    if (userIds.isNotEmpty) {
      final profiles = await _supabase
          .from('profiles')
          .select('id, email, first_name, last_name')
          .inFilter('id', userIds);

      for (final profile in profiles) {
        final data = Map<String, dynamic>.from(profile);
        profileMap[data['id'] as String] = data;
      }
    }

    // Attach each profile to its order before parsing.
    final enrichedOrders = orderRows.map((row) {
      final userId = row['user_id'] as String?;
      return {
        ...row,
        'profiles': userId != null ? profileMap[userId] : null,
      };
    }).toList();

    return enrichedOrders.map(Order.fromMap).toList();
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
