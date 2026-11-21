import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/format.dart';
import '../../providers/cart_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../widgets/product_image.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_back_button.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(checkoutControllerProvider.notifier).placeOrder();

    if (!context.mounted) return;

    if (ok) {
      context.go('/order-confirmation');
    } else {
      final error = ref.read(checkoutControllerProvider).error;
      showMessage(
        context,
        error == null ? 'Checkout failed.' : friendlyError(error),
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final isPlacing = ref.watch(checkoutControllerProvider).isLoading;
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), title: const Text('Shopping Cart')),
      body: items.isEmpty
          ? EmptyView(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              message: 'Add some products to get started.',
              action: ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('EXPLORE PRODUCTS'),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: ProductImage(
                                    url: item.product.imageUrl,
                                    iconSize: 28,
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
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${formatPrice(item.product.price)} each',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatPrice(item.subtotal),
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (item.atStockLimit)
                                      Text(
                                        'Max available (${item.product.stockQuantity})',
                                        style:
                                            theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Decrease quantity',
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                        onPressed: isPlacing
                                            ? null
                                            : () => cartNotifier
                                                .decrement(item.product.id),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        tooltip: 'Increase quantity',
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        onPressed:
                                            isPlacing || item.atStockLimit
                                                ? null
                                                : () {
                                                    final error = cartNotifier
                                                        .increment(
                                                            item.product.id);
                                                    if (error != null) {
                                                      showMessage(
                                                          context, error,
                                                          error: true);
                                                    }
                                                  },
                                      ),
                                    ],
                                  ),
                                  TextButton.icon(
                                    onPressed: isPlacing
                                        ? null
                                        : () =>
                                            cartNotifier.remove(item.product.id),
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18),
                                    label: const Text('Remove'),
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
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total items',
                                style: theme.textTheme.titleMedium),
                            Text(
                              '${cart.totalItemCount}',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formatPrice(cart.totalAmount),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Final prices and stock are confirmed when you check out.',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                isPlacing ? null : () => _checkout(context, ref),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: isPlacing
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('CHECKOUT'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
