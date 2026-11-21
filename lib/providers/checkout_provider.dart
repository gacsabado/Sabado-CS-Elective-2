import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/checkout_service.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';
import 'order_provider.dart';
import 'product_provider.dart';

final checkoutServiceProvider = Provider<CheckoutService>((ref) {
  return CheckoutService();
});

/// Holds the latest checkout: loading while the order is saved, the result
/// (order number, total, items) on success, an error otherwise.
final checkoutControllerProvider =
    AsyncNotifierProvider<CheckoutController, CheckoutResult?>(
  CheckoutController.new,
);

class CheckoutController extends AsyncNotifier<CheckoutResult?> {
  @override
  CheckoutResult? build() {
    // Forget the last order when the user changes.
    ref.listen(currentUserProvider, (previous, next) {
      if (previous?.id != next?.id) state = const AsyncData(null);
    });
    return null;
  }

  /// Returns true when the order was saved.
  Future<bool> placeOrder() async {
    if (state.isLoading) return false;

    final items = ref.read(cartProvider).items;

    state = const AsyncLoading();

    final next = await AsyncValue.guard(
      () => ref.read(checkoutServiceProvider).placeOrder(items),
    );

    if (!ref.mounted) return false;

    if (next.hasError) {
      state = AsyncError(next.error!, next.stackTrace ?? StackTrace.current);
      // Stock may have changed; refresh what the customer sees.
      ref.invalidate(productPageProvider);
      return false;
    }

    // Success: the cart is emptied only after the order is saved.
    ref.read(cartProvider.notifier).clearCart();
    ref.invalidate(orderHistoryProvider);
    ref.invalidate(productPageProvider);

    state = AsyncData(next.value);
    return true;
  }
}
