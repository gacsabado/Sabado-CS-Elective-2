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
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String? _statusFilter;

  Future<void> _updateStatus(Order order, String status) async {
    if (status == order.status) return;

    try {
      await ref.read(orderActionsProvider).updateStatus(order.id, status);
      if (!mounted) return;
      showMessage(
        context,
        'Order #${order.orderNumber} marked ${orderStatusLabel(status)}.',
      );
    } catch (error) {
      if (!mounted) return;
      showMessage(context, 'Unable to update: ${friendlyError(error)}',
          error: true);
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
              : all.where((o) => o.status == _statusFilter).toList();

          return Column(
            children: [
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('All (${all.length})'),
                        selected: _statusFilter == null,
                        onSelected: (_) => setState(() => _statusFilter = null),
                      ),
                    ),
                    for (final status in Order.statuses)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(orderStatusLabel(status)),
                          selected: _statusFilter == status,
                          onSelected: (_) =>
                              setState(() => _statusFilter = status),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: orders.isEmpty
                    ? EmptyView(
                        icon: Icons.receipt_long_outlined,
                        title: 'No orders',
                        message: _statusFilter == null
                            ? 'Orders placed by customers will show up here.'
                            : 'No orders with this status.',
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(adminOrdersProvider);
                          await ref.read(adminOrdersProvider.future);
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: orders.length,
                          itemBuilder: (context, index) => _AdminOrderCard(
                            order: orders[index],
                            onStatusChanged: (status) =>
                                _updateStatus(orders[index], status),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final Order order;
  final ValueChanged<String> onStatusChanged;

  const _AdminOrderCard({required this.order, required this.onStatusChanged});

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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${order.customerName ?? order.customerEmail ?? 'Customer'} · '
          '${formatDate(order.createdAt)} · ${formatPrice(order.totalAmount)}',
        ),
        trailing: Chip(
          label: Text(orderStatusLabel(order.status)),
          backgroundColor: color.withValues(alpha: 0.15),
          labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
          side: BorderSide.none,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (order.customerEmail != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(order.customerEmail!,
                    style: theme.textTheme.bodySmall),
              ),
            ),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName} (${item.quantity} × ${formatPrice(item.unitPrice)})',
                    ),
                  ),
                  Text(formatPrice(item.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
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
                  if (status != null) onStatusChanged(status);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
