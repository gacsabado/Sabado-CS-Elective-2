import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const ResponsiveDashboardApp());
}

// Starbucks Brand Palette Constants
class StarbucksColors {
  static const Color houseGreen = Color(0xFF006241);
  static const Color darkGreen = Color(0xFF1E3932);
  static const Color warmBackground = Color(0xFFF7F5F0);
  static const Color wireframeCardBg = Color(0xFFE0ECE7);
  static const Color wireframePlaceholder = Color(0xFFA2C4B8);
  static const Color starGold = Color(0xFFD4E9E2);
}

class ResponsiveDashboardApp extends StatelessWidget {
  const ResponsiveDashboardApp({super.key});

  bool get _isApple =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  Widget build(BuildContext context) {
    if (_isApple) {
      return const CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: StarbucksColors.houseGreen,
          barBackgroundColor: StarbucksColors.darkGreen,
          textTheme: CupertinoTextThemeData(
            navTitleTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 16,
            ),
          ),
        ),
        home: DashboardPage(),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: StarbucksColors.warmBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: StarbucksColors.houseGreen),
        appBarTheme: const AppBarTheme(
          backgroundColor: StarbucksColors.darkGreen,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int _selectedCategory = 0;

  bool get _isApple =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (_isApple) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: StarbucksColors.darkGreen.withOpacity(0.85),
          leading: screenWidth < 1000
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.bars, color: Colors.white),
                  onPressed: () => _showCupertinoDrawer(context),
                )
              : null,
          middle: const Text('STARBUCKS'),
          trailing: const Icon(CupertinoIcons.bag, color: Colors.white),
        ),
        child: SafeArea(
          child: _buildLayoutBuilder(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: StarbucksColors.warmBackground,
      appBar: AppBar(
        backgroundColor: StarbucksColors.darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('STARBUCKS STORE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: screenWidth < 1000 ? _buildSidebarDrawer() : null,
      body: _buildLayoutBuilder(),
      bottomNavigationBar: screenWidth < 600 ? _buildMobileBottomBar() : null,
    );
  }

  Widget _buildLayoutBuilder() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1000) {
          return _buildDesktopLayout();
        } else if (constraints.maxWidth >= 600) {
          return _buildTabletLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // RESPONSIVE WIREFRAME LAYOUTS
  // ---------------------------------------------------------------------------

  // DESKTOP: Left Navigation + Central Storefront + Right Live Order Panel
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        SizedBox(
          width: 230,
          child: _buildSidebarContent(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ListView(
                    children: [
                      _buildRewardsBanner(),
                      const SizedBox(height: 16),
                      _buildCategorySelector(),
                      const SizedBox(height: 16),
                      _buildProductGrid(crossAxisCount: 3),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 300,
                  child: _buildCartSummaryPanel(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TABLET: Storefront Grid + Scrollable Cart Section
  Widget _buildTabletLayout() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildRewardsBanner(),
        const SizedBox(height: 16),
        _buildCategorySelector(),
        const SizedBox(height: 16),
        _buildProductGrid(crossAxisCount: 2),
        const SizedBox(height: 20),
        _buildCartSummaryPanel(),
      ],
    );
  }

  // MOBILE: Vertical Single Column Layout + Native Tab Bar
  Widget _buildMobileLayout() {
    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        _buildRewardsBanner(),
        const SizedBox(height: 12),
        _buildCategorySelector(),
        const SizedBox(height: 12),
        _buildProductGrid(crossAxisCount: 1),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // UX COMPONENTS & WIREFRAME WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildRewardsBanner() {
    return GlassContainer(
      isApple: _isApple,
      color: StarbucksColors.starGold,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: StarbucksColors.houseGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: StarbucksColors.darkGreen,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 8,
                  width: 180,
                  decoration: BoxDecoration(
                    color: StarbucksColors.darkGreen.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
          _buildAdaptiveButton(text: 'REDEEM', mini: true),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['DRINKS', 'FOOD', 'WHOLE BEAN', 'MERCHANDISE'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? StarbucksColors.houseGreen : StarbucksColors.wireframeCardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: isSelected ? Colors.white : StarbucksColors.darkGreen,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid({required int crossAxisCount}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: crossAxisCount == 1 ? 2.5 : 0.85,
      ),
      itemBuilder: (context, index) => ProductWireframeCard(isApple: _isApple),
    );
  }

  Widget _buildCartSummaryPanel() {
    return GlassContainer(
      isApple: _isApple,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR ORDER',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
              color: StarbucksColors.darkGreen,
            ),
          ),
          const Divider(height: 20),
          for (int i = 0; i < 3; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: StarbucksColors.wireframePlaceholder,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 10, width: 90, color: StarbucksColors.darkGreen),
                        const SizedBox(height: 4),
                        Container(height: 8, width: 50, color: StarbucksColors.wireframePlaceholder),
                      ],
                    ),
                  ),
                  Container(height: 10, width: 30, color: StarbucksColors.houseGreen),
                ],
              ),
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 12, width: 60, color: StarbucksColors.darkGreen),
              Container(height: 14, width: 45, color: StarbucksColors.houseGreen),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _buildAdaptiveButton(text: 'CHECKOUT'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SIDEBAR & PLATFORM SPECIFIC NAVIGATION
  // ---------------------------------------------------------------------------

  Widget _buildSidebarDrawer() {
    return Drawer(child: _buildSidebarContent());
  }

  void _showCupertinoDrawer(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 250,
          height: double.infinity,
          color: StarbucksColors.warmBackground,
          child: SafeArea(child: _buildSidebarContent()),
        ),
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: StarbucksColors.houseGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_cafe, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'STARBUCKS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: StarbucksColors.darkGreen,
            ),
          ),
          const SizedBox(height: 24),
          _buildNavItem(Icons.local_cafe_outlined, 'STORE', 0),
          _buildNavItem(Icons.stars_outlined, 'REWARDS', 1),
          _buildNavItem(Icons.storefront_outlined, 'LOCATIONS', 2),
          _buildNavItem(Icons.receipt_long_outlined, 'ORDERS', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? StarbucksColors.houseGreen : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          letterSpacing: 1.2,
          color: isSelected ? StarbucksColors.houseGreen : Colors.grey.shade700,
        ),
      ),
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildMobileBottomBar() {
    if (_isApple) {
      return CupertinoTabBar(
        activeColor: StarbucksColors.houseGreen,
        currentIndex: _selectedIndex,
        onTap: (idx) => setState(() => _selectedIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.house_fill), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.star_fill), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.bag_fill), label: 'Cart'),
        ],
      );
    }
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.store), label: 'Store'),
        NavigationDestination(icon: Icon(Icons.star), label: 'Rewards'),
        NavigationDestination(icon: Icon(Icons.shopping_bag), label: 'Cart'),
      ],
    );
  }

  Widget _buildAdaptiveButton({required String text, bool mini = false}) {
    final padding = mini
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    if (_isApple) {
      return CupertinoButton(
        color: StarbucksColors.houseGreen,
        padding: padding,
        borderRadius: BorderRadius.circular(20),
        child: Text(
          text,
          style: TextStyle(
            fontSize: mini ? 10 : 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        onPressed: () {},
      );
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: StarbucksColors.houseGreen,
        foregroundColor: Colors.white,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () {},
      child: Text(
        text,
        style: TextStyle(
          fontSize: mini ? 10 : 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GLASS & WIREFRAME CUSTOM CARDS
// ---------------------------------------------------------------------------

class GlassContainer extends StatelessWidget {
  final Widget child;
  final bool isApple;
  final Color color;
  final EdgeInsetsGeometry padding;

  const GlassContainer({
    super.key,
    required this.child,
    required this.isApple,
    required this.color,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (isApple) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color.withOpacity(0.55),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: child,
          ),
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: child,
    );
  }
}

class ProductWireframeCard extends StatelessWidget {
  final bool isApple;

  const ProductWireframeCard({super.key, required this.isApple});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      isApple: isApple,
      color: StarbucksColors.wireframeCardBg,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: StarbucksColors.wireframePlaceholder,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_cafe, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Container(
            height: 10,
            width: 100,
            decoration: BoxDecoration(
              color: StarbucksColors.darkGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 8,
            width: 60,
            decoration: BoxDecoration(
              color: StarbucksColors.wireframePlaceholder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 12,
                width: 35,
                decoration: BoxDecoration(
                  color: StarbucksColors.houseGreen,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Icon(
                isApple ? CupertinoIcons.add_circled_solid : Icons.add_circle,
                color: StarbucksColors.houseGreen,
                size: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}