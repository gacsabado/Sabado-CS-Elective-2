
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
import '../../providers/profile_provider.dart';
import '../../state/cart_state.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  bool _isAdding = false;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _handleAddToCart() {
    // Only customers are allowed to add products to their cart.
    final profile = ref.read(profileProvider).value;

    if (profile == null || !profile.isCustomer) {
      return;
    }

    setState(() {
      _isAdding = true;
    });

    ref
        .read(cartProvider.notifier)
        .addToCart(widget.product, quantity: _quantity);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        content: Text('${widget.product.name} (x$_quantity) added to cart!'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            context.push('/cart');
          },
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);
    final profileAsync = ref.watch(profileProvider);

    // Hide shopping controls unless the user's customer profile is loaded.
    final isCustomer = profileAsync.value?.isCustomer ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          if (isCustomer)
            Badge(
              isLabelVisible: cart.totalItemCount > 0,
              label: Text('${cart.totalItemCount}'),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  context.push('/cart');
                },
                tooltip: 'Shopping Cart',
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.1,
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Image.asset(
                  widget.product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image,
                    size: 60,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.series.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    widget.product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Divider(height: 24),

                  // QUANTITY SELECTOR: CUSTOMERS ONLY
                  if (isCustomer) ...[
                    Row(
                      children: [
                        Text(
                          'Quantity:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: _quantity > 1
                                    ? _decrementQuantity
                                    : null,
                                tooltip: 'Decrease quantity',
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  '$_quantity',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _incrementQuantity,
                                tooltip: 'Increase quantity',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                  ],

                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    widget.product.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ADD TO CART BUTTON: CUSTOMERS ONLY
      bottomNavigationBar: isCustomer
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _isAdding ? null : _handleAddToCart,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(
                    _isAdding ? 'ADDING...' : 'ADD TO CART ($_quantity)',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
