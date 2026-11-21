import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/admin_dashboard_service.dart';

final adminDashboardServiceProvider = Provider<AdminDashboardService>((ref) {
  return AdminDashboardService();
});

final adminDashboardProvider =
    FutureProvider.autoDispose<AdminDashboardStats>((ref) {
  final service = ref.watch(adminDashboardServiceProvider);

  Timer? debounce;

  final stop = service.subscribeToChanges(() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 300), () {
      if (ref.mounted) ref.invalidateSelf();
    });
  });

  ref.onDispose(() {
    debounce?.cancel();
    stop();
  });

  return service.getDashboardStats();
});
