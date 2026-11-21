import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import 'auth_provider.dart';
import 'profile_provider.dart';

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.subtotal);

  int quantityOf(String productId) {
    for (final item in items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

/// The cart lives in app state, survives screen changes, and is emptied on
/// logout. Stock limits here are for the UI; the database re-checks them at
/// checkout.
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    // Empty the cart whenever the user signs out (or a different user signs in).
    ref.listen(currentUserProvider, (previous, next) {
      if (previous?.id != next?.id) clearCart();
    });

    return const CartState();
  }

  bool get _isCustomer => ref.read(profileProvider).value?.isCustomer ?? false;

  /// Returns an error message when the product cannot be added, else null.
  String? addToCart(Product product, {int quantity = 1}) {
    if (!_isCustomer) return 'Only customers can add items to a cart.';
    if (quantity <= 0) return 'Choose a quantity of at least 1.';
    if (!product.isInStock) return '${product.name} is out of stock.';

    final current = state.quantityOf(product.id);
    final available = product.stockQuantity - current;

    if (available <= 0) {
      return 'You already have all ${product.stockQuantity} available '
          'in your cart.';
    }
    if (quantity > available) {
      return 'Only $available more of ${product.name} can be added.';
    }

    final items = [...state.items];
    final index = items.indexWhere((i) => i.product.id == product.id);

    if (index >= 0) {
      // Use the freshest product data (stock) we have.
      items[index] = CartItem(
        product: product,
        quantity: items[index].quantity + quantity,
      );
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }

    state = CartState(items: items);
    return null;
  }

  String? increment(String productId) {
    final index = state.items.indexWhere((i) => i.product.id == productId);
    if (index < 0) return null;

    final item = state.items[index];

    if (item.quantity >= item.product.stockQuantity) {
      return 'Only ${item.product.stockQuantity} of ${item.product.name} '
          'in stock.';
    }

    final items = [...state.items];
    items[index] = item.copyWith(quantity: item.quantity + 1);
    state = CartState(items: items);
    return null;
  }

  void decrement(String productId) {
    final index = state.items.indexWhere((i) => i.product.id == productId);
    if (index < 0) return;

    final items = [...state.items];

    if (items[index].quantity > 1) {
      items[index] = items[index].copyWith(quantity: items[index].quantity - 1);
    } else {
      items.removeAt(index);
    }

    state = CartState(items: items);
  }

  void remove(String productId) {
    state = CartState(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void clearCart() {
    state = const CartState();
  }
}

