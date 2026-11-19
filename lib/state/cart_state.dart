
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../providers/profile_provider.dart';

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

  // CHECK IF THE CURRENT USER IS A CUSTOMER
  bool get _isCustomer {
    final profile = ref.read(profileProvider).value;
    return profile?.isCustomer ?? false;
  }

  // ADD PRODUCT TO CART: CUSTOMERS ONLY
  void addToCart(Product product, {int quantity = 1}) {
    if (!_isCustomer || quantity <= 0) return;

    final updatedItems = state.items
        .map((item) => CartItem(product: item.product, quantity: item.quantity))
        .toList();

    final index = updatedItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      updatedItems[index].quantity += quantity;
    } else {
      updatedItems.add(CartItem(product: product, quantity: quantity));
    }

    state = CartState(items: updatedItems);
  }

  // INCREMENT QUANTITY: CUSTOMERS ONLY
  void incrementQuantity(String productId) {
    if (!_isCustomer) return;

    final updatedItems = _copyItems();

    final index = updatedItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index >= 0) {
      updatedItems[index].quantity++;
      state = CartState(items: updatedItems);
    }
  }

  // DECREMENT QUANTITY: CUSTOMERS ONLY
  void decrementQuantity(String productId) {
    if (!_isCustomer) return;

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

  // REMOVE PRODUCT: CUSTOMERS ONLY
  void removeFromCart(String productId) {
    if (!_isCustomer) return;

    final updatedItems = _copyItems()
      ..removeWhere((item) => item.product.id == productId);

    state = CartState(items: updatedItems);
  }

  // CLEAR CART: ALLOWED FOR LOGOUT / RESET
  void clearCart() {
    state = const CartState();
  }

  // CREATE A NEW LIST WITH COPIED CART ITEMS
  List<CartItem> _copyItems() {
    return state.items
        .map((item) => CartItem(product: item.product, quantity: item.quantity))
        .toList();
  }
}
