import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/hero_banner_slider.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Load products when the home screen first opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final productState = ref.read(productProvider);

      if (productState.products.isEmpty && !productState.isLoading) {
        ref.read(productProvider.notifier).loadProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Riverpod product state.
    final productState = ref.watch(productProvider);
    final productNotifier = ref.read(productProvider.notifier);

    // Current authenticated user.
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            widget.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
          onPressed: widget.onToggleTheme,
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
          // Guest actions
          if (currentUser == null) ...[
            TextButton(
              onPressed: () => context.push('/signin'),
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () => context.push('/signup'),
              child: const Text('Sign Up'),
            ),
          ],

          // Authenticated customer action
          if (currentUser != null)
            IconButton(
              onPressed: () => context.push('/profile'),
              icon: const Icon(Icons.person_outline),
              tooltip: 'My Profile',
            ),

          // Cart remains accessible
          // Keep your existing cart icon and badge here.
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
              const SliverToBoxAdapter(child: HeroBannerSlider()),

              // PRICE FILTER
              const SliverToBoxAdapter(child: _PriceFilter()),

              // SECTION TITLE
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

              // PRODUCTS FROM SUPABASE
              if (productState.isLoading && productState.products.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (productState.error != null &&
                  productState.products.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 12),
                        const Text('Unable to load products.'),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: productNotifier.refresh,
                          child: const Text('RETRY'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (productState.products.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('No products found in this price range.'),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = productState.products[index];

                      return ProductCard(
                        product: product,
                        onTap: () {
                          context.push('/product/${product.id}', extra: product);
                        },
                      );
                    }, childCount: productState.products.length),
                  ),
                ),

              // PAGINATION CONTROLS
              SliverToBoxAdapter(
                child: productState.products.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        child: Column(
                          children: [
                            Text(
                              'Page ${productState.currentPage + 1}',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed:
                                      productState.currentPage > 0 &&
                                          !productState.isLoading
                                      ? productNotifier.previousPage
                                      : null,
                                  child: const Text('PREVIOUS'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed:
                                      productState.hasMore &&
                                          !productState.isLoading
                                      ? productNotifier.nextPage
                                      : null,
                                  child: const Text('NEXT'),
                                ),
                              ],
                            ),
                            if (productState.isLoading)
                              const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: CircularProgressIndicator(),
                              ),
                            if (productState.error != null)
                              Text(
                                'Unable to load the requested page.',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                          ],
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

// PRICE RANGE SLIDER
class _PriceFilter extends ConsumerStatefulWidget {
  const _PriceFilter();

  @override
  ConsumerState<_PriceFilter> createState() => _PriceFilterState();
}

class _PriceFilterState extends ConsumerState<_PriceFilter> {
  RangeValues _selectedRange = const RangeValues(0, 100);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productState = ref.watch(productProvider);
    final productNotifier = ref.read(productProvider.notifier);

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
                  onPressed: productState.isLoading
                      ? null
                      : () {
                          setState(() {
                            _selectedRange = const RangeValues(0, 100);
                          });

                          productNotifier.setPriceRange(0, 100);
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
              onChanged: productState.isLoading
                  ? null
                  : (values) {
                      setState(() {
                        _selectedRange = values;
                      });
                    },
              onChangeEnd: productState.isLoading
                  ? null
                  : (values) {
                      productNotifier.setPriceRange(values.start, values.end);
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
