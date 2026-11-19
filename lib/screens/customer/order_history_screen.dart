import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/order_provider.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  String _formatDate(String? value) {
    if (value == null) return 'Date unavailable';

    final date = DateTime.tryParse(value)?.toLocal();

    if (date == null) return 'Date unavailable';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatPrice(dynamic value) {
    final amount = (value as num?)?.toDouble() ?? 0.0;
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'done':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status ?? 'Unknown';
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'done':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Order History'),
        centerTitle: true,
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                const Text('Unable to load your orders.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(orderHistoryProvider),
                  child: const Text('RETRY'),
                ),
              ],
            ),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Orders Yet',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your previous purchases will appear here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(orderHistoryProvider);
              await ref.read(orderHistoryProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                final items = List<Map<String, dynamic>>.from(
                  order['order_items'] ?? [],
                );

                final status = order['status']?.toString();

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${order['order_number'] ?? order['id']}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(
                                      order['created_at']?.toString(),
                                    ),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(_formatStatus(status)),
                              backgroundColor:
                                  _statusColor(status).withValues(
                                alpha: 0.15,
                              ),
                              labelStyle: TextStyle(
                                color: _statusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                              side: BorderSide.none,
                            ),
                          ],
                        ),

                        const Divider(height: 24),

                        ...items.map((item) {
                          final quantity =
                              (item['quantity'] as num?)?.toInt() ?? 0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['product_name']?.toString() ??
                                            'Unknown Product',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$quantity × ${_formatPrice(item['unit_price'])}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatPrice(item['subtotal']),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const Divider(height: 16),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatPrice(order['total_amount']),
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
              },
            ),
          );
        },
      ),
    );
  }
}
