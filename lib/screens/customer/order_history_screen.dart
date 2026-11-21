import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/state_views.dart';

String orderStatusLabel(String status) => switch (status) {
      'done' => 'Done',
      'pending' => 'Pending',
      'cancelled' => 'Cancelled',
      _ => status,
    };

Color orderStatusColor(String status) => switch (status) {
      'done' => Colors.green,
      'pending' => Colors.orange,
      'cancelled' => Colors.red,
      _ => Colors.grey,
    };

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: ordersAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          title: 'Unable to load your orders',
          onRetry: () => ref.invalidate(orderHistoryProvider),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyView(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'Your previous purchases will appear here.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(orderHistoryProvider);
              await ref.read(orderHistoryProvider.future);
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) => _OrderCard(order: orders[index]),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = orderStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderNumber}',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(formatDate(order.createdAt),
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Chip(
                  label: Text(orderStatusLabel(order.status)),
                  backgroundColor: color.withValues(alpha: 0.15),
                  labelStyle:
                      TextStyle(color: color, fontWeight: FontWeight.bold),
                  side: BorderSide.none,
                ),
              ],
            ),
            const Divider(height: 24),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${item.quantity} × ${formatPrice(item.unitPrice)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatPrice(item.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  formatPrice(order.totalAmount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
