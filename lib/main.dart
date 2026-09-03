import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const PopMartApp());
}

// =============================================================================
// MODELS & DATA
// =============================================================================

class FeaturedBanner {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String targetProductId;
  final Alignment alignment;

  const FeaturedBanner({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.targetProductId,
    this.alignment = Alignment.center,
  });
}

class Product {
  final String id;
  final String name;
  final String series;
  final double price;
  final String imageUrl;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.series,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}

// Featured Banners matching products in hironoProducts
final List<FeaturedBanner> featuredBanners = [
  const FeaturedBanner(
    title: 'AFTER DARK',
    subtitle: 'Hirono After Dark Series Plush Doll Pendant',
    imageUrl: 'assets/afterdark.jpeg',
    targetProductId: 'h1',
    alignment: Alignment(0.0, 0.5),
  ),
  const FeaturedBanner(
    title: 'ROAD JOURNAL',
    subtitle: 'Hirono Road Journal Series Figurine Collection',
    imageUrl: 'assets/roadjournal.jpeg',
    targetProductId: 'h2',
  ),
  const FeaturedBanner(
    title: 'SHELTER',
    subtitle: 'Hirono Shelter Series Blind Box Figures',
    imageUrl: 'assets/gray.jpeg',
    targetProductId: 'h3',
  ),
  const FeaturedBanner(
    title: 'LITTLE MISCHIEF',
    subtitle: 'Hirono Little Mischief Series Plush Companion',
    imageUrl: 'assets/gray.jpeg',
    targetProductId: 'h4',
  ),
  const FeaturedBanner(
    title: 'PLUSH DOLL',
    subtitle: 'Hirono Bear Vinyl Plush Doll Collection',
    imageUrl: 'assets/gray.jpeg',
    targetProductId: 'h5',
  ),
  const FeaturedBanner(
    title: 'RESHAPE',
    subtitle: 'Hirono Reshape Series Artistic Figurine',
    imageUrl: 'assets/gray.jpeg',
    targetProductId: 'h6',
  ),
];

// Sample POP MART Hirono Products Data (6 items)
final List<Product> hironoProducts = [
  const Product(
    id: 'h1',
    name: 'Hirono After Dark Pendant',
    series: 'After Dark',
    price: 29.99,
    imageUrl: 'assets/gray.jpeg',
    description: 'Embrace the eerie mystery of nightfall with the Hirono After Dark Plush Doll Pendant.',
  ),
  const Product(
    id: 'h2',
    name: 'Hirono Road Journal Figure',
    series: 'Road Journal Series',
    price: 19.99,
    imageUrl: 'assets/gray.jpeg',
    description: 'Documenting wanderlust, solitude, and quiet reflections along forgotten paths.',
  ),
  const Product(
    id: 'h3',
    name: 'Hirono Shelter Figurine',
    series: 'Shelter Series',
    price: 19.99,
    imageUrl: 'assets/gray.jpeg',
    description: 'Find solace in solitude. Explores inner protection and emotional sanctuaries.',
  ),
  const Product(
    id: 'h4',
    name: 'Hirono Mischief Bear',
    series: 'Little Mischief',
    price: 24.99,
    imageUrl: 'assets/gray.jpeg',
    description: 'Playful rebellions and raw unfiltered emotions captured in detailed collectible figures.',
  ),
  const Product(
    id: 'h5',
    name: 'Hirono Bear Vinyl Plush',
    series: 'Plush Doll Collection',
    price: 99.99,
    imageUrl: 'assets/gray.jpeg',
    description: 'A premium oversized vinyl and plush companion showcasing Hirono in moody bear attire.',
  ),
  const Product(
    id: 'h6',
    name: 'Hirono Reshape Figure',
    series: 'Reshape Series',
    price: 19.99,
    imageUrl: 'assets/gray.jpeg',
    description: 'Accepting flaws and reshaping one’s personal narrative through artistic expression.',
  ),
];

// =============================================================================
// APP ROOT WITH LIGHT/DARK THEME STATE
// =============================================================================

class PopMartApp extends StatefulWidget {
  const PopMartApp({super.key});

  @override
  State<PopMartApp> createState() => _PopMartAppState();
}

class _PopMartAppState extends State<PopMartApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(
          themeMode: _themeMode,
          onToggleTheme: _toggleTheme,
        ),
        routes: [
          GoRoute(
            path: 'product/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              final product = hironoProducts.firstWhere(
                (p) => p.id == id,
                orElse: () => hironoProducts.first,
              );
              return ProductDetailScreen(product: product);
            },
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      colorSchemeSeed: Colors.deepOrange,
      scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.deepOrange,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );

    return MaterialApp.router(
      title: 'POP MART Hirono Store',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

// =============================================================================
// SCREEN 1: HOME SCREEN (FEATURED HERO SLIDER + RESPONSIVE GRID)
// =============================================================================

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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
          onPressed: onToggleTheme,
          tooltip: 'Toggle Theme',
        ),
        title: SvgPicture.asset(
          'assets/Pop_Mart_logo.svg',
          height: 32,
          placeholderBuilder: (context) => const Text(
            'POP MART',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
            tooltip: 'Menu',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;

          if (constraints.maxWidth < 600) {
            crossAxisCount = 2; // Mobile
          } else if (constraints.maxWidth <= 1024) {
            crossAxisCount = 3; // Tablet / iPad portrait mode
          } else {
            crossAxisCount = 4; // Desktop & Landscape tablets
          }

          return CustomScrollView(
            slivers: [
              // 1. POP MART HERO BANNER CAROUSEL
              const SliverToBoxAdapter(
                child: HeroBannerSlider(),
              ),

              // 2. SECTION HEADER
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'EXPLORE ALL SERIES',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),

              // 3. RESPONSIVE PRODUCT GRID
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

// =============================================================================
// HERO BANNER SLIDER COMPONENT
// =============================================================================

class HeroBannerSlider extends StatefulWidget {
  const HeroBannerSlider({super.key});

  @override
  State<HeroBannerSlider> createState() => _HeroBannerSliderState();
}

class _HeroBannerSliderState extends State<HeroBannerSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentIndex + 1) % featuredBanners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.85,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: featuredBanners.length,
            itemBuilder: (context, index) {
              final banner = featuredBanners[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Image.asset(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    alignment: banner.alignment,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.black87),
                  ),

                  // Gradient Dark Overlay for contrast
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),

                  // Top Left Branding
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Image.asset(
                      'assets/HIRONO.webp',
                      height: 70,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Failed to load asset image: $error');
                        return Container(
                          color: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: const Text(
                            'HIRONO (Asset Not Found)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Series Title and Info Content
                  Positioned(
                    bottom: 40,
                    left: 16,
                    right: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          banner.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFE55322),
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(blurRadius: 8, color: Colors.black),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          banner.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Dash Indicators
          Positioned(
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                featuredBanners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 2.5,
                  width: _currentIndex == index ? 28 : 16,
                  color: _currentIndex == index ? Colors.white : Colors.white38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PRODUCT CARD COMPONENT
// =============================================================================

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade900,
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.series.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SCREEN 2: PRODUCT DETAIL SCREEN
// =============================================================================

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.1,
              child: Image.asset(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey.shade900),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.series,
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const Divider(height: 32),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(height: 1.5, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}