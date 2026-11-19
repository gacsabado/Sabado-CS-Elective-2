
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_dashboard_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/admin_dashboard_service.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardProvider);
    final profileAsync = ref.watch(profileProvider);

    final profile = profileAsync.value;
    final adminName = profile?.fullName ?? 'Administrator';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: () {
              ref.invalidate(adminDashboardProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminDashboardProvider);
          await ref.read(adminDashboardProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, $adminName!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here is an overview of your HIRONO store.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 28),

              Text(
                'Store Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              statsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => _buildError(
                  context,
                  error.toString(),
                  () => ref.invalidate(adminDashboardProvider),
                ),
                data: (stats) => _buildStatsGrid(context, stats),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    AdminDashboardStats stats,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 650 ? 4 : 2;

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: columns == 4 ? 1.15 : 1.25,
          children: [
            _StatCard(
              title: 'Products',
              value: stats.totalProducts.toString(),
              icon: Icons.inventory_2_outlined,
            ),
            _StatCard(
              title: 'Categories',
              value: stats.totalCategories.toString(),
              icon: Icons.category_outlined,
            ),
            _StatCard(
              title: 'Orders',
              value: stats.totalOrders.toString(),
              icon: Icons.receipt_long_outlined,
            ),
            _StatCard(
              title: 'Total Sales',
              value: '₱${stats.totalSales.toStringAsFixed(2)}',
              icon: Icons.payments_outlined,
            ),
          ],
        );
      },
    );
  }

  Widget _buildError(
    BuildContext context,
    String error,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load dashboard statistics.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

