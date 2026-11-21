import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardStats {
  final int totalProducts;
  final int totalCategories;
  final int totalOrders;
  final double totalSales;

  const AdminDashboardStats({
    required this.totalProducts,
    required this.totalCategories,
    required this.totalOrders,
    required this.totalSales,
  });
}

class AdminDashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AdminDashboardStats> getDashboardStats() async {
    final results = await Future.wait([
      _supabase.from('products').select('id'),
      _supabase.from('categories').select('id'),
      _supabase.from('orders').select('total, status'),
    ]);

    final orders = List<Map<String, dynamic>>.from(results[2]);

    // Cancelled orders do not count as sales.
    final totalSales = orders
        .where((order) => order['status'] != 'cancelled')
        .fold<double>(
          0,
          (sum, order) =>
              sum + ((order['total'] as num?)?.toDouble() ?? 0),
        );

    return AdminDashboardStats(
      totalProducts: results[0].length,
      totalCategories: results[1].length,
      totalOrders: orders.length,
      totalSales: totalSales,
    );
  }

  // REALTIME - returns a function that stops listening.
  void Function() subscribeToChanges(void Function() onChange) {
    var channel = _supabase.channel(
      'admin-dashboard-${DateTime.now().microsecondsSinceEpoch}',
    );

    for (final table in const ['products', 'categories', 'orders']) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        callback: (_) => onChange(),
      );
    }

    channel.subscribe();

    return () => _supabase.removeChannel(channel);
  }
}
