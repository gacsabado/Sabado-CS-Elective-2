
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/admin_dashboard_service.dart';

final adminDashboardServiceProvider =
    Provider<AdminDashboardService>((ref) {
  return AdminDashboardService();
});

final adminDashboardProvider =
    FutureProvider.autoDispose<AdminDashboardStats>((ref) async {
  final service = ref.watch(adminDashboardServiceProvider);
  return service.getDashboardStats();
});
