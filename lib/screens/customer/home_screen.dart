
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/product_provider.dart';
import '../../state/cart_state.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final currentUser = ref.read(currentUserProvider);

      if (currentUser != null) {
        final productState = ref.read(productProvider);

        if (productState.products.isEmpty &&
            !productState.isLoading) {
          ref.read(productProvider.notifier).loadProducts();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final productState = ref.watch(productProvider);
    final productNotifier = ref.read(productProvider.notifier);

    final currentUser = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(profileProvider);

    // WATCH CART STATE FOR LIVE ITEM COUNT
    final cart = ref.watch(cartProvider);

    // Load products when the authentication session becomes available.
    ref.listen(currentUserProvider, (previousUser, nextUser) {
      if (previousUser == null && nextUser != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final state = ref.read(productProvider);

          if (state.products.isEmpty && !state.isLoading) {
            ref.read(productProvider.notifier).loadProducts(reset: true);
          }
        });
      }
    });

    final isAdmin = profileAsync.when(
      data: (profile) => profile?.isAdmin == true,
      loading: () => false,
      error: (_, _) => false,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        leading: currentUser != null
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip: 'Open Menu',
                ),
              )
            : null,

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
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),

          if (currentUser != null)
            IconButton(
              onPressed: () => context.push('/profile'),
              icon: const Icon(Icons.person_outline),
              tooltip: 'My Profile',
            ),

          // CART ICON WITH LIVE ITEM COUNT
          if (currentUser != null && !isAdmin)
            IconButton(
              onPressed: () => context.push('/cart'),
              tooltip: 'My Cart',
              icon: Badge(
                isLabelVisible: cart.totalItemCount > 0,
                label: Text('${cart.totalItemCount}'),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                ),
              ),
            ),
        ],
      ),

      drawer: currentUser == null
          ? null
          : _HomeNavigationDrawer(
              isAdmin: isAdmin,
              isLoadingProfile: profileAsync.isLoading,
            ),

      body: currentUser == null
          ? const _GuestLandingPage()
          : LayoutBuilder(
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

                    const SliverToBoxAdapter(
                      child: _PriceFilter(),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          20,
                          16,
                          8,
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

                    if (productState.isLoading &&
                        productState.products.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    else if (productState.error != null &&
                        productState.products.isEmpty)
                      SliverToBoxAdapter(
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
                            child: Text(
                              'No products found in this price range.',
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
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
                                  productState.products[index];

                              return ProductCard(
                                product: product,
                                onTap: () {
                                  context.push(
                                    '/product/${product.id}',
                                    extra: product,
                                  );
                                },
                              );
                            },
                            childCount: productState.products.length,
                          ),
                        ),
                      ),

                    SliverToBoxAdapter(
                      child: productState.products.isEmpty
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                32,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Page ${productState.currentPage + 1}',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
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

// GUEST LANDING PAGE

class _GuestLandingPage extends StatelessWidget {
  const _GuestLandingPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 650;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // BACKGROUND IMAGE
                  Image.asset(
                    'assets/afterdark.jpeg',
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDark
                            ? const Color(0xFF302B2B)
                            : const Color(0xFFBBA69A),
                      );
                    },
                  ),

                  // GRADIENT FOR TEXT READABILITY
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.78),
                          Colors.black.withValues(alpha: 0.48),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),

                  // BOTTOM GRADIENT
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // HERO CONTENT
                  Padding(
                    padding: EdgeInsets.all(isWide ? 48 : 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BRAND LABEL
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Text(
                            'THE WORLD OF HIRONO',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // HEADLINE
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWide ? 480 : 340,
                          ),
                          child: Text(
                            'A little piece\nof emotion.',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                              letterSpacing: -1.5,
                              fontSize: isWide ? 58 : 44,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // DESCRIPTION
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWide ? 390 : 310,
                          ),
                          child: Text(
                            'Discover the world of HIRONO. '
                            'Collect meaningful characters, '
                            'express emotions, and find the figure '
                            'that speaks to you.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              height: 1.6,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // BUTTONS
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWide ? 340 : double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FilledButton(
                                onPressed: () => context.push('/signup'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 17,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Create an account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              OutlinedButton(
                                onPressed: () => context.push('/signin'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Colors.white70,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text('Sign in instead'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// HOME NAVIGATION DRAWER

class _HomeNavigationDrawer extends StatelessWidget {
  final bool isAdmin;
  final bool isLoadingProfile;

  const _HomeNavigationDrawer({
    required this.isAdmin,
    required this.isLoadingProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return NavigationDrawer(
      selectedIndex: 0,

      onDestinationSelected: (index) {
        Navigator.pop(context);

        if (isAdmin) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/admin');
              break;
            case 2:
              context.go('/admin/products');
              break;
            case 3:
              context.go('/admin/orders');
              break;
            case 4:
              context.push('/profile');
              break;
          }
        } else {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.push('/profile');
              break;
            case 2:
              context.push('/cart');
              break;
          }
        }
      },

      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HIRONO',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLoadingProfile
                        ? 'LOADING ACCOUNT...'
                        : isAdmin
                            ? 'ADMIN MANAGEMENT'
                            : 'STORE',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(28, 8, 16, 8),
          child: Text(
            'MAIN MENU',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),

        const NavigationDrawerDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text('Home'),
        ),

        if (isAdmin) ...[
          const NavigationDrawerDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: Text('Dashboard'),
          ),

          const NavigationDrawerDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: Text('Products'),
          ),

          const NavigationDrawerDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: Text('Orders'),
          ),

          
        ],

        const Divider(),

        const Padding(
          padding: EdgeInsets.fromLTRB(28, 12, 16, 8),
          child: Text(
            'ACCOUNT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),

        const NavigationDrawerDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person_rounded),
          label: Text('My Profile'),
        ),

        if (!isAdmin)
          const NavigationDrawerDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart_rounded),
            label: Text('My Cart'),
          ),
      ],
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
  RangeValues _selectedRange = const RangeValues(0, 10000);

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
                            _selectedRange = const RangeValues(0, 10000);
                          });

                          productNotifier.setPriceRange(0, 10000);
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
              max: 10000,
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
                      productNotifier.setPriceRange(
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
