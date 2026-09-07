import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/cart_item.dart';
import '../state/cart_state.dart';

class CheckoutConfirmationScreen extends StatefulWidget {
  const CheckoutConfirmationScreen({super.key});

  @override
  State<CheckoutConfirmationScreen> createState() => _CheckoutConfirmationScreenState();
}

class _CheckoutConfirmationScreenState extends State<CheckoutConfirmationScreen> {
  late final List<CartItem> _summaryItems;
  late final double _finalTotal;

  @override
  void initState() {
    super.initState();
    // Snapshot current cart details before clearing cart state
    _summaryItems = List.from(CartState.instance.items);
    _finalTotal = CartState.instance.totalAmount;

    // Clear cart after checkout purchase is confirmed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CartState.instance.clearCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Guard against direct navigation when cart was empty
    if (_summaryItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout Summary')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No order found.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('RETURN HOME'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Thank You for Your Order!',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your POP MART items are being prepared for shipping.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 20),
                    ..._summaryItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product.name} (x${item.quantity})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '\$${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount Paid', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          '\$${_finalTotal.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('BACK TO HOME'),
            ),
          ],
        ),
      ),
    );
  }
}