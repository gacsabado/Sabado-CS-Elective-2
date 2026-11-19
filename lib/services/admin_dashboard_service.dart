
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
    final products = await _supabase
        .from('products')
        .select('id');

    final categories = await _supabase
        .from('categories')
        .select('id');

    final orders = await _supabase
        .from('orders')
        .select('total_amount');

    final totalSales = orders.fold<double>(
      0,
      (sum, order) =>
          sum + ((order['total_amount'] as num?)?.toDouble() ?? 0),
    );

    return AdminDashboardStats(
      totalProducts: products.length,
      totalCategories: categories.length,
      totalOrders: orders.length,
      totalSales: totalSales,
    );
  }
}
