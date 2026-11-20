
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/admin_dashboard_service.dart';

final adminDashboardServiceProvider =
    Provider<AdminDashboardService>((ref) {
  return AdminDashboardService();
});

final FutureProvider<AdminDashboardStats> adminDashboardProvider =
    FutureProvider.autoDispose<AdminDashboardStats>((ref) async {
  final service = ref.watch(adminDashboardServiceProvider);
  final supabase = Supabase.instance.client;

  Timer? refreshDebounce;

  void scheduleRefresh() {
    refreshDebounce?.cancel();

    refreshDebounce = Timer(
      const Duration(milliseconds: 300),
      () {
        if (ref.mounted) {
          ref.invalidateSelf();
        }
      },
    );
  }

  final channel = supabase
      .channel('admin-dashboard-changes')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'products',
        callback: (_) => scheduleRefresh(),
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'categories',
        callback: (_) => scheduleRefresh(),
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'orders',
        callback: (_) => scheduleRefresh(),
      )
      .subscribe();

  ref.onDispose(() {
    refreshDebounce?.cancel();
    supabase.removeChannel(channel);
  });

  return service.getDashboardStats();
});
