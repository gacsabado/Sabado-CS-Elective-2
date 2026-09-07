import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../state/cart_state.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
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
    setState(() {
      _isAdding = true;
    });

    // Pass chosen quantity to cart state
    CartState.instance.addToCart(widget.product, quantity: _quantity);

    // FIXED: Clear lingering snackbars before showing new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true, // FIXED: User can manually close SnackBar anytime
        content: Text('${widget.product.name} (x$_quantity) added to cart!'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            // FIXED: Hide snackbar immediately upon clicking View Cart
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            context.go('/cart');
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          ListenableBuilder(
            listenable: CartState.instance,
            builder: (context, _) {
              final count = CartState.instance.totalItemCount;
              return Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    context.go('/cart');
                  },
                  tooltip: 'Shopping Cart',
                ),
              );
            },
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
              padding: const EdgeInsets.all(16.0),
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

                  // FIXED: Interactive Quantity Selector (+ / -)
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
                            color: theme.colorScheme.outline.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _quantity > 1 ? _decrementQuantity : null,
                              tooltip: 'Decrease quantity',
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _isAdding ? null : _handleAddToCart,
            icon: const Icon(Icons.add_shopping_cart),
            label: Text(_isAdding ? 'ADDING...' : 'ADD TO CART ($_quantity)'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ),
    );
  }
}