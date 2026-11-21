
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/format.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_image.dart';
import '../../widgets/state_views.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  void _addToCart(Product product) {
    final error = ref
        .read(cartProvider.notifier)
        .addToCart(product, quantity: _quantity);

    if (error != null) {
      showMessage(context, error, error: true);
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          showCloseIcon: true,
          content: Text('${product.name} (x$_quantity) added to cart!'),
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: () => context.push('/cart'),
          ),
        ),
      );

    setState(() => _quantity = 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(productAsync.value?.name ?? 'Product'),
        actions: [
          Badge(
            isLabelVisible: cart.totalItemCount > 0,
            label: Text('${cart.totalItemCount}'),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: 'Shopping cart',
              onPressed: () => context.push('/cart'),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          title: 'Unable to load this product',
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.productId)),
        ),
        data: (product) {
          if (product == null) {
            return const EmptyView(
              icon: Icons.inventory_2_outlined,
              title: 'Product not found',
              message: 'This product may have been removed.',
            );
          }

          final label = [product.categoryName]
              .where((s) => s.isNotEmpty)
              .join(' · ');

          final inCart = cart.quantityOf(product.id);
          final available = product.stockQuantity - inCart;
          final maxQuantity = available < 1 ? 1 : available;
          final quantity =
              _quantity > maxQuantity ? maxQuantity : _quantity;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 850;

              final image = Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  maxHeight: 900,
                ),
                padding: const EdgeInsets.all(16),
                child: ProductImage(
                  url: product.imageUrl,
                  iconSize: 60,
                ),
              );

              final details = _buildProductDetails(
                theme: theme,
                product: product,
                label: label,
                available: available,
                maxQuantity: maxQuantity,
                quantity: quantity,
              );

              final addToCartButton = SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: available > 0
                          ? () => _addToCart(product)
                          : null,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(
                        !product.isInStock
                            ? 'OUT OF STOCK'
                            : available <= 0
                                ? 'ALL AVAILABLE ITEMS IN CART'
                                : 'ADD TO CART ($quantity)',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
                ),
              );

              // DESKTOP / WEB LAYOUT
              if (isWide) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1250,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product image on the left
                          Expanded(
                            flex: 11,
                            child: image,
                          ),

                          const SizedBox(width: 48),

                          // Product details on the right
                          Expanded(
                            flex: 9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                details,
                                const SizedBox(height: 24),
                                addToCartButton,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // MOBILE / SMALL SCREEN LAYOUT
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          image,
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: details,
                          ),
                        ],
                      ),
                    ),
                  ),
                  addToCartButton,
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductDetails({
    required ThemeData theme,
    required Product product,
    required String label,
    required int available,
    required int maxQuantity,
    required int quantity,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          product.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          formatPrice(product.price),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.isInStock
              ? '${product.stockQuantity} in stock'
              : 'Out of stock',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: product.isInStock
                ? null
                : theme.colorScheme.error,
          ),
        ),
        const Divider(height: 32),
        if (available > 0) ...[
          Row(
            children: [
              Text(
                'Quantity:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              IconButton.outlined(
                icon: const Icon(Icons.remove),
                onPressed: quantity > 1
                    ? () => setState(
                          () => _quantity = quantity - 1,
                        )
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$quantity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton.outlined(
                icon: const Icon(Icons.add),
                onPressed: quantity < maxQuantity
                    ? () => setState(
                          () => _quantity = quantity + 1,
                        )
                    : null,
              ),
            ],
          ),
          const Divider(height: 32),
        ],
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description.isEmpty
              ? 'No description provided.'
              : product.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
