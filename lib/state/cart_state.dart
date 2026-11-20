
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalItemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return const CartState();
  }

  // ADD PRODUCT TO CART
  void addToCart(Product product, {int quantity = 1}) {
    if (quantity <= 0) return;

    final updatedItems = _copyItems();

    final index = updatedItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      updatedItems[index].quantity += quantity;
    } else {
      updatedItems.add(
        CartItem(product: product, quantity: quantity),
      );
    }

    state = CartState(items: updatedItems);
  }

  // INCREMENT QUANTITY
  void incrementQuantity(String productId) {
    final updatedItems = _copyItems();

    final index = updatedItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index >= 0) {
      updatedItems[index].quantity++;
      state = CartState(items: updatedItems);
    }
  }

  // DECREMENT QUANTITY
  void decrementQuantity(String productId) {
    final updatedItems = _copyItems();

    final index = updatedItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index >= 0) {
      if (updatedItems[index].quantity > 1) {
        updatedItems[index].quantity--;
      } else {
        updatedItems.removeAt(index);
      }

      state = CartState(items: updatedItems);
    }
  }

  // REMOVE PRODUCT
  void removeFromCart(String productId) {
    final updatedItems = _copyItems()
      ..removeWhere((item) => item.product.id == productId);

    state = CartState(items: updatedItems);
  }

  // CLEAR CART
  void clearCart() {
    state = const CartState();
  }

  List<CartItem> _copyItems() {
    return state.items
        .map(
          (item) => CartItem(
            product: item.product,
            quantity: item.quantity,
          ),
        )
        .toList();
  }
}
