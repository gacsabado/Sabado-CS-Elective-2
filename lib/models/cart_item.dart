import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  /// Display only. The database recomputes prices at checkout.
  bool get atStockLimit => quantity >= product.stockQuantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }
}
