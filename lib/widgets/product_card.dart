import 'package:flutter/material.dart';

import '../core/utils/format.dart';
import '../models/product.dart';
import 'product_image.dart';

/// Customer product card. Shows "Add to cart" instead of any admin control.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final int quantityInCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddToCart,
    this.quantityInCart = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final label = product.series.isNotEmpty ? product.series : product.categoryName;
    final canAdd = product.isInStock && quantityInCart < product.stockQuantity;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(url: product.imageUrl),
                  if (!product.isInStock)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: const Text(
                        'OUT OF STOCK',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label.isNotEmpty)
                    Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatPrice(product.price),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (product.isInStock && product.stockQuantity <= 5)
                        Text(
                          '${product.stockQuantity} left',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: colors.error),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (onAddToCart != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canAdd ? onAddToCart : null,
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: Text(
                      !product.isInStock
                          ? 'Sold out'
                          : canAdd
                              ? 'Add to cart'
                              : 'Max in cart',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
