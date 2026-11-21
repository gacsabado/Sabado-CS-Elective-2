import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/admin_dashboard_provider.dart';
import '../../core/utils/format.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_drawer.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardProvider);
    final profileAsync = ref.watch(profileProvider);
    final adminName = profileAsync.value?.fullName ?? 'Administrator';
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/admin'),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: () => ref.invalidate(adminDashboardProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminDashboardProvider);
          await ref.read(adminDashboardProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HIRONO STORE / ADMIN',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.onPrimaryContainer,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Welcome back, $adminName',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Here is what is happening in your store today.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onPrimaryContainer.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.tonalIcon(
                          onPressed: () => context.push('/admin/products'),
                          icon: const Icon(Icons.inventory_2_outlined),
                          label: const Text('Manage products'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Store overview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'A quick look at your store performance.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  statsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stackTrace) => _DashboardError(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(adminDashboardProvider),
                    ),
                    data: (stats) => LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 850
                            ? 4
                            : constraints.maxWidth >= 520
                                ? 2
                                : 1;

                        return GridView.count(
                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: columns == 1
                              ? 3.0
                              : columns == 2
                                  ? 1.55
                                  : 1.25,
                          children: [
                            _StatCard(
                              title: 'Products',
                              value: stats.totalProducts.toString(),
                              icon: Icons.inventory_2_outlined,
                              description: 'Items in your catalog',
                            ),
                            _StatCard(
                              title: 'Categories',
                              value: stats.totalCategories.toString(),
                              icon: Icons.category_outlined,
                              description: 'Product collections',
                            ),
                            _StatCard(
                              title: 'Orders',
                              value: stats.totalOrders.toString(),
                              icon: Icons.receipt_long_outlined,
                              description: 'Orders received',
                            ),
                            _StatCard(
                              title: 'Total sales',
                              value: formatPrice(stats.totalSales),
                              icon: Icons.payments_outlined,
                              description: 'Recorded store sales',
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Quick actions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _QuickAction(
                    icon: Icons.add_box_outlined,
                    title: 'Add a product',
                    subtitle: 'Create a new item in your catalog',
                    onTap: () => context.push('/admin/products/new'),
                  ),
                  const SizedBox(height: 10),
                  _QuickAction(
                    icon: Icons.inventory_outlined,
                    title: 'View product catalog',
                    subtitle: 'Update prices, stock, and product details',
                    onTap: () => context.push('/admin/products'),
                  ),
                  const SizedBox(height: 10),
                  _QuickAction(
                    icon: Icons.category_outlined,
                    title: 'Manage categories',
                    subtitle: 'Add, rename, or remove categories',
                    onTap: () => context.push('/admin/categories'),
                  ),
                  const SizedBox(height: 10),
                  _QuickAction(
                    icon: Icons.receipt_long_outlined,
                    title: 'Manage orders',
                    subtitle: 'Review customer orders and update their status',
                    onTap: () => context.push('/admin/orders'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String description;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colors.primary, size: 25),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Icon(icon, color: colors.onPrimaryContainer),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, size: 36),
            const SizedBox(height: 10),
            const Text(
              'Unable to load dashboard statistics.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
