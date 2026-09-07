import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../state/cart_state.dart';
import '../widgets/hero_banner_slider.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
          onPressed: onToggleTheme,
          tooltip: 'Toggle Theme',
        ),
        // FIXED: Removed colorFilter so logo retains natural colors
        title: SvgPicture.asset(
          'assets/Pop_Mart_logo.svg',
          height: 28,
          placeholderBuilder: (context) => Text(
            'POP MART',
            style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
        ),
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
                  onPressed: () => context.go('/cart'),
                  tooltip: 'Shopping Cart',
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          if (constraints.maxWidth < 600) {
            crossAxisCount = 2;
          } else if (constraints.maxWidth <= 1024) {
            crossAxisCount = 3;
          } else {
            crossAxisCount = 4;
          }

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: HeroBannerSlider(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'EXPLORE ALL SERIES',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = hironoProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.go('/product/${product.id}'),
                      );
                    },
                    childCount: hironoProducts.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}