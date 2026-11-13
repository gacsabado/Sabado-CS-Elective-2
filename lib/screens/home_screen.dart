import '../widgets/google_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
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
          icon: Icon(
            themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
          onPressed: onToggleTheme,
          tooltip: 'Toggle Theme',
        ),
        title: SvgPicture.asset(
          'assets/Pop_Mart_logo.svg',
          height: 28,
          placeholderBuilder: (context) => Text(
            'POP MART',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        actions: [
          // GOOGLE SIGN-IN
          const GoogleSignInButton(),

          // SHOPPING CART
          ListenableBuilder(
            listenable: CartState.instance,
            builder: (context, _) {
              final count = CartState.instance.totalItemCount;

              return Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                  ),
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
              // HERO BANNER
              const SliverToBoxAdapter(
                child: HeroBannerSlider(),
              ),

              // PRICE FILTER
              const SliverToBoxAdapter(
                child: _PriceFilter(),
              ),

              // SECTION TITLE
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16, 20, 16, 8,
                  ),
                  child: Text(
                    'EXPLORE ALL SERIES',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),

              // PRODUCTS FROM SUPABASE
              Consumer<ProductProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading &&
                      provider.products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }

                  if (provider.error != null &&
                      provider.products.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Unable to load products.',
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: provider.refresh,
                              child: const Text('RETRY'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (provider.products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No products found in this price range.',
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product =
                              provider.products[index];

                          return ProductCard(
                            product: product,
                            onTap: () {
                              context.go(
                                '/product/${product.id}',
                                extra: product,
                              );
                            },
                          );
                        },
                        childCount: provider.products.length,
                      ),
                    ),
                  );
                },
              ),

              // PAGINATION CONTROLS
              SliverToBoxAdapter(
                child: Consumer<ProductProvider>(
                  builder: (context, provider, _) {
                    if (provider.products.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16, 16, 16, 32,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Page ${provider.currentPage + 1}',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              OutlinedButton(
                                onPressed:
                                    provider.currentPage > 0 &&
                                            !provider.isLoading
                                        ? provider.previousPage
                                        : null,
                                child: const Text('PREVIOUS'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed:
                                    provider.hasMore &&
                                            !provider.isLoading
                                        ? provider.nextPage
                                        : null,
                                child: const Text('NEXT'),
                              ),
                            ],
                          ),
                          if (provider.isLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: CircularProgressIndicator(),
                            ),
                          if (provider.error != null)
                            Text(
                              'Unable to load the requested page.',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// PRICE RANGE SLIDER
class _PriceFilter extends StatefulWidget {
  const _PriceFilter();

  @override
  State<_PriceFilter> createState() => _PriceFilterState();
}

class _PriceFilterState extends State<_PriceFilter> {
  RangeValues _selectedRange = const RangeValues(0, 100);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProductProvider>();

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FILTER BY PRICE',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          setState(() {
                            _selectedRange =
                                const RangeValues(0, 100);
                          });

                          provider.setPriceRange(0, 100);
                        },
                  child: const Text('RESET'),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${_selectedRange.start.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${_selectedRange.end.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            RangeSlider(
              values: _selectedRange,
              min: 0,
              max: 100,
              divisions: 100,
              labels: RangeLabels(
                '\$${_selectedRange.start.toStringAsFixed(0)}',
                '\$${_selectedRange.end.toStringAsFixed(0)}',
              ),
              onChanged: provider.isLoading
                  ? null
                  : (values) {
                      setState(() {
                        _selectedRange = values;
                      });
                    },
              onChangeEnd: provider.isLoading
                  ? null
                  : (values) {
                      provider.setPriceRange(
                        values.start,
                        values.end,
                      );
                    },
            ),

            Text(
              'Adjust the slider to find Hirono figures within your budget.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
