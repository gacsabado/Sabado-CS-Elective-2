import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/order_service.dart';
import 'auth_provider.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final orderHistoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return [];
  }

  final orderService = ref.watch(orderServiceProvider);

  return orderService.getOrders(user.id);
});
