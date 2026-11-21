import 'package:flutter/material.dart';

/// Shows a product image from a network URL with loading and error states.
class ProductImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double iconSize;

  const ProductImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget placeholder(IconData icon) => Center(
          child: Icon(icon, size: iconSize, color: colors.onSurfaceVariant),
        );

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colors.surfaceContainerHighest,
      child: url.trim().isEmpty
          ? placeholder(Icons.image_outlined)
          : Image.network(
              url,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, _, _) => placeholder(Icons.broken_image_outlined),
            ),
    );
  }
}
