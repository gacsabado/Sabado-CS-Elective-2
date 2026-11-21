
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/state_views.dart';
import '../customer/order_history_screen.dart'
    show orderStatusColor, orderStatusLabel;

/// Admin view of every order. Admins can read all orders and update status.
class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() =>
      _AdminOrdersScreenState();
}

class _AdminOrdersScreenState
    extends ConsumerState<AdminOrdersScreen> {
  String? _statusFilter;

  Future<void> _updateStatus(Order order, String status) async {
    if (status == order.status) return;

    try {
      await ref
          .read(orderActionsProvider)
          .updateStatus(order.id, status);

      if (!mounted) return;

      showMessage(
        context,
        'Order #${order.orderNumber} marked ${orderStatusLabel(status)}.',
      );
    } catch (error) {
      if (!mounted) return;

      showMessage(
        context,
        'Unable to update: ${friendlyError(error)}',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/admin/orders'),
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminOrdersProvider),
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          title: 'Could not load orders',
          onRetry: () => ref.invalidate(adminOrdersProvider),
        ),
        data: (all) {
          final orders = _statusFilter == null
              ? all
              : all
                  .where((o) => o.status == _statusFilter)
                  .toList();

          // Use one scrollable page to prevent RenderFlex overflow.
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminOrdersProvider);
              await ref.read(adminOrdersProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // Sales Report
                _SalesReport(orders: all),

                // Order status filters
                SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('All (${all.length})'),
                          selected: _statusFilter == null,
                          onSelected: (_) {
                            setState(() => _statusFilter = null);
                          },
                        ),
                      ),
                      for (final status in Order.statuses)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(orderStatusLabel(status)),
                            selected: _statusFilter == status,
                            onSelected: (_) {
                              setState(() => _statusFilter = status);
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // Orders list
                if (orders.isEmpty)
                  SizedBox(
                    height: 250,
                    child: EmptyView(
                      icon: Icons.receipt_long_outlined,
                      title: 'No orders',
                      message: _statusFilter == null
                          ? 'Orders placed by customers will show up here.'
                          : 'No orders with this status.',
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        for (final order in orders)
                          _AdminOrderCard(
                            order: order,
                            onStatusChanged: (status) {
                              _updateStatus(order, status);
                            },
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// SALES REPORT
// ============================================================

class _SalesReport extends StatelessWidget {
  final List<Order> orders;

  const _SalesReport({required this.orders});

  // Only completed orders count as actual sales.
  bool _isCompleted(Order order) {
    return order.status == 'done';
  }

  // Calculate sales within a specific date range.
  double _salesForPeriod(
    List<Order> completedOrders,
    DateTime start,
    DateTime end,
  ) {
    return completedOrders.fold<double>(0, (total, order) {
      final date = order.createdAt;

      if (date == null) return total;

      if (!date.isBefore(start) && date.isBefore(end)) {
        return total + order.totalAmount;
      }

      return total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Date boundaries.
    final today = DateTime(now.year, now.month, now.day);

    // Week starts on Monday.
    final weekStart = today.subtract(
      Duration(days: today.weekday - 1),
    );

    final nextWeek = weekStart.add(
      const Duration(days: 7),
    );

    // Current month.
    final monthStart = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    // Current year.
    final yearStart = DateTime(now.year);
    final nextYear = DateTime(now.year + 1);

    // Completed orders.
    final completedOrders = orders
        .where(_isCompleted)
        .toList();

    // All-time sales.
    final totalSales = completedOrders.fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );

    // Weekly sales.
    final weeklySales = _salesForPeriod(
      completedOrders,
      weekStart,
      nextWeek,
    );

    // Monthly sales.
    final monthlySales = _salesForPeriod(
      completedOrders,
      monthStart,
      nextMonth,
    );

    // Yearly sales.
    final yearlySales = _salesForPeriod(
      completedOrders,
      yearStart,
      nextYear,
    );

    // ========================================================
    // BEST-SELLING PRODUCTS
    // Rank by total quantity sold, NOT revenue.
    // ========================================================

    final Map<String, int> productSales = {};

    for (final order in completedOrders) {
      for (final item in order.items) {
        final productName = item.productName.trim();

        if (productName.isEmpty) continue;

        productSales[productName] =
            (productSales[productName] ?? 0) +
                item.quantity.toInt();
      }
    }

    // Sort from highest units sold to lowest.
    final bestSellers = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Total units sold across all products.
    final totalUnitsSold = productSales.values.fold<int>(
      0,
      (sum, quantity) => sum + quantity,
    );

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.analytics_outlined),
        title: const Text(
          'Sales Report',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${completedOrders.length} completed orders',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        children: [
          // ALL-TIME TOTAL SALES
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Sales',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  formatPrice(totalSales),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All-time completed sales',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SALES BY PERIOD
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sales by Period',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.65,
            children: [
              _SalesMetric(
                title: 'This Week',
                value: formatPrice(weeklySales),
                icon: Icons.date_range,
                color: Colors.blue,
              ),
              _SalesMetric(
                title: 'This Month',
                value: formatPrice(monthlySales),
                icon: Icons.calendar_month,
                color: Colors.green,
              ),
              _SalesMetric(
                title: 'This Year',
                value: formatPrice(yearlySales),
                icon: Icons.calendar_today,
                color: Colors.orange,
              ),
              _SalesMetric(
                title: 'Completed Orders',
                value: '${completedOrders.length}',
                icon: Icons.shopping_bag_outlined,
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // BEST-SELLING PRODUCTS
          Row(
            children: [
              const Icon(Icons.emoji_events_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Best-Selling Products',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Ranked by total units sold',
              style: theme.textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: 12),

          if (bestSellers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No completed product sales yet.',
              ),
            )
          else
            for (var i = 0;
                i < bestSellers.length && i < 5;
                i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          theme.colorScheme.primaryContainer,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bestSellers[i].key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${bestSellers[i].value} sold',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

          if (bestSellers.length > 5)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '+ ${bestSellers.length - 5} more products',
                style: theme.textTheme.bodySmall,
              ),
            ),

          const Divider(height: 24),

          // TOTAL UNITS SOLD
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Products Sold'),
              Text(
                '$totalUnitsSold units',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SALES METRIC CARD
// ============================================================

class _SalesMetric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SalesMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN ORDER CARD
// ============================================================

class _AdminOrderCard extends StatelessWidget {
  final Order order;
  final ValueChanged<String> onStatusChanged;

  const _AdminOrderCard({
    required this.order,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = orderStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        title: Text(
          'Order #${order.orderNumber}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${order.customerName ?? order.customerEmail ?? 'Customer'} · '
          '${formatDate(order.createdAt)} · '
          '${formatPrice(order.totalAmount)}',
        ),
        trailing: Chip(
          label: Text(orderStatusLabel(order.status)),
          backgroundColor: color.withValues(alpha: 0.15),
          labelStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          side: BorderSide.none,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        children: [
          if (order.customerEmail != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  order.customerEmail!,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),

          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName} '
                      '(${item.quantity} × '
                      '${formatPrice(item.unitPrice)})',
                    ),
                  ),
                  Text(
                    formatPrice(item.subtotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 24),

          Row(
            children: [
              const Text('Update status:'),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: Order.statuses.contains(order.status)
                    ? order.status
                    : null,
                items: [
                  for (final status in Order.statuses)
                    DropdownMenuItem(
                      value: status,
                      child: Text(orderStatusLabel(status)),
                    ),
                ],
                onChanged: (status) {
                  if (status != null) {
                    onStatusChanged(status);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
