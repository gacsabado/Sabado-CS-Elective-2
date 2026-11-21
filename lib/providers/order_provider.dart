import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../services/order_service.dart';
import 'admin_dashboard_provider.dart';
import 'auth_provider.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// Customer: own orders only
final orderHistoryProvider = FutureProvider.autoDispose<List<Order>>((ref) {
  final user = ref.watch(currentUserProvider);

  if (user == null) return <Order>[];

  return ref.watch(orderServiceProvider).getMyOrders(user.id);
});

// Admin: all orders
final adminOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) {
  return ref.watch(orderServiceProvider).getAllOrders();
});

final orderActionsProvider = Provider<OrderActions>((ref) {
  return OrderActions(ref);
});

class OrderActions {
  final Ref _ref;

  OrderActions(this._ref);

  Future<void> updateStatus(String orderId, String status) async {
    await _ref.read(orderServiceProvider).updateStatus(orderId, status);
    _ref.invalidate(adminOrdersProvider);
    _ref.invalidate(adminDashboardProvider);
  }
}
