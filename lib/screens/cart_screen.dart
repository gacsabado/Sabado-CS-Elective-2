import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/cart_state.dart';

/// Stateful Widget: Handles dynamic state changes such as incrementing, decrementing, and recalculating subtotals live.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: ListenableBuilder(
        listenable: CartState.instance,
        builder: (context, _) {
          final items = CartState.instance.items;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('EXPLORE PRODUCTS'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 70,
                                height: 70,
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Image.asset(
                                  item.product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${item.product.price.toStringAsFixed(2)} each',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Stateful Quantity Controls
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    CartState.instance.decrementQuantity(item.product.id);
                                  },
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    CartState.instance.incrementQuantity(item.product.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Items:', style: theme.textTheme.titleMedium),
                          Text(
                            '${CartState.instance.totalItemCount}',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Grand Total:', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            '\$${CartState.instance.totalAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/checkout'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('PROCEED TO CHECKOUT'),
                      ),
                    ],
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