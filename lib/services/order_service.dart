import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    final response = await _supabase
        .from('orders')
        .select('''
          id,
          order_number,
          user_id,
          total_amount,
          status,
          created_at,
          order_items (
            id,
            product_id,
            product_name,
            unit_price,
            quantity,
            subtotal
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
