import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/format.dart';
import '../../models/product_filter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/hero_banner_slider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/state_views.dart';

/// Customer storefront. Admins are redirected away by the router, and this
/// screen never renders add / edit / delete controls.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final cart = ref.watch(cartProvider);
    final pageAsync = ref.watch(productPageProvider);
    final filter = ref.watch(productFilterProvider);

    // Keep the list fresh when products / stock change.
    ref.watch(productRealtimeProvider);

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/'),
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/Pop_Mart_logo.svg',
          height: 28,
          placeholderBuilder: (_) => Text(
            'POP MART',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          Badge(
            isLabelVisible: cart.totalItemCount > 0,
            label: Text('${cart.totalItemCount}'),
            child: IconButton(
              tooltip: 'My cart',
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => context.push('/cart'),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productPageProvider);
          ref.invalidate(categoriesProvider);
          await ref.read(productPageProvider.future).catchError(
                (_) => const ProductPage(products: [], hasMore: false),
              );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 600
                ? 2
                : constraints.maxWidth <= 1024
                    ? 3
                    : 4;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: HeroBannerSlider()),
                const SliverToBoxAdapter(child: _FilterPanel()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'EXPLORE ALL SERIES',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                ...pageAsync.when(
                  loading: () => [
                    const SliverToBoxAdapter(child: LoadingView()),
                  ],
                  error: (error, _) => [
                    SliverToBoxAdapter(
                      child: ErrorView(
                        error: error,
                        title: 'Unable to load products',
                        onRetry: () => ref.invalidate(productPageProvider),
                      ),
                    ),
                  ],
                  data: (page) {
                    if (page.products.isEmpty) {
                      return [
                        SliverToBoxAdapter(
                          child: EmptyView(
                            icon: Icons.search_off_rounded,
                            title: 'No products found',
                            message: filter.isDefault
                                ? 'There are no products yet. Check back soon.'
                                : 'Try changing your search or filters.',
                            action: filter.isDefault
                                ? null
                                : OutlinedButton(
                                    onPressed: () => ref
                                        .read(productFilterProvider.notifier)
                                        .reset(),
                                    child: const Text('CLEAR FILTERS'),
                                  ),
                          ),
                        ),
                      ];
                    }

                    return [
                      SliverPadding(
                        padding: const EdgeInsets.all(12),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = page.products[index];

                              return ProductCard(
                                product: product,
                                quantityInCart: cart.quantityOf(product.id),
                                onTap: () =>
                                    context.push('/product/${product.id}'),
                                onAddToCart: () {
                                  final error = ref
                                      .read(cartProvider.notifier)
                                      .addToCart(product);

                                  showMessage(
                                    context,
                                    error ?? '${product.name} added to cart.',
                                    error: error != null,
                                  );
                                },
                              );
                            },
                            childCount: page.products.length,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _Pagination(
                          page: filter.page,
                          hasMore: page.hasMore,
                        ),
                      ),
                    ];
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Search, category, price, stock, sort
// ---------------------------------------------------------------------
class _FilterPanel extends ConsumerStatefulWidget {
  const _FilterPanel();

  @override
  ConsumerState<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends ConsumerState<_FilterPanel> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  RangeValues _range = const RangeValues(0, ProductFilter.maxPriceLimit);

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {}); // refresh the clear button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) ref.read(productFilterProvider.notifier).setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = ref.watch(productFilterProvider);
    final notifier = ref.read(productFilterProvider.notifier);
    final categoriesAsync = ref.watch(categoriesProvider);

    // Keep the controls in sync when filters are reset elsewhere.
    ref.listen(productFilterProvider, (previous, next) {
      if (next.isDefault) {
        _searchController.clear();
        setState(() {
          _range = const RangeValues(0, ProductFilter.maxPriceLimit);
        });
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEARCH
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _debounce?.cancel();
                        notifier.setSearch('');
                        setState(() {});
                      },
                    ),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),

          // CATEGORY CHIPS
          SizedBox(
            height: 40,
            child: categoriesAsync.when(
              loading: () => const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, _) => Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => ref.invalidate(categoriesProvider),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Categories failed to load. Retry'),
                ),
              ),
              data: (categories) => ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: filter.categoryId == null,
                      onSelected: (_) => notifier.setCategory(null),
                    ),
                  ),
                  for (final category in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category.name),
                        selected: filter.categoryId == category.id,
                        onSelected: (_) => notifier.setCategory(category.id),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // PRICE RANGE
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PRICE: ${formatPrice(_range.start)} - ${formatPrice(_range.end)}',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: filter.isDefault ? null : notifier.reset,
                        child: const Text('RESET ALL'),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _range,
                    min: 0,
                    max: ProductFilter.maxPriceLimit,
                    divisions: 100,
                    labels: RangeLabels(
                      formatPrice(_range.start),
                      formatPrice(_range.end),
                    ),
                    onChanged: (values) => setState(() => _range = values),
                    onChangeEnd: (values) =>
                        notifier.setPriceRange(values.start, values.end),
                  ),
                ],
              ),
            ),
          ),

          // STOCK + SORT
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: const Text('In stock only'),
                  selected: filter.inStockOnly,
                  onSelected: notifier.setInStockOnly,
                ),
              ),
              DropdownButton<ProductSort>(
                value: filter.sort,
                underline: const SizedBox.shrink(),
                items: [
                  for (final sort in ProductSort.values)
                    DropdownMenuItem(value: sort, child: Text(sort.label)),
                ],
                onChanged: (sort) {
                  if (sort != null) notifier.setSort(sort);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pagination extends ConsumerWidget {
  final int page;
  final bool hasMore;

  const _Pagination({required this.page, required this.hasMore});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(productFilterProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: [
          Text('Page ${page + 1}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: page > 0 ? notifier.previousPage : null,
                child: const Text('PREVIOUS'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: hasMore ? notifier.nextPage : null,
                child: const Text('NEXT'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
