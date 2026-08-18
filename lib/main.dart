import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 1. Configure GoRouter with nested sub-routes
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const FruitListScreen(),
      routes: [
        GoRoute(
          path: 'fruit/:name',
          builder: (context, state) {
            final fruitName = state.pathParameters['name'] ?? 'Unknown';
            return FruitDetailScreen(fruitName: fruitName);
          },
        ),
      ],
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Fresh Market',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B1E3F)),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// 2. Fruit Data Model (Simplified to Name, Image URL, and Flavor Profile)
class Fruit {
  final String name;
  final String imageUrl;
  final String flavorProfile;

  const Fruit({
    required this.name,
    required this.imageUrl,
    required this.flavorProfile,
  });
}

const List<Fruit> fruits = [
  Fruit(
    name: 'Papaya Red Lady',
    imageUrl:
        'https://images.unsplash.com/photo-1517260739337-6799d239ce83?q=80&w=600&auto=format&fit=crop',
    flavorProfile:
        'Sweet, mildly musky flavor with a soft, creamy butter-like texture.',
  ),
  Fruit(
    name: 'Saba Banana',
    imageUrl:
        'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?q=80&w=600&auto=format&fit=crop',
    flavorProfile:
        'Mildly sweet with a rich, unique tart-and-sweet flavor profile when cooked or ripe.',
  ),
  Fruit(
    name: 'Guyabano',
    imageUrl:
        'https://images.unsplash.com/photo-1543528176-61b239494933?q=80&w=600&auto=format&fit=crop',
    flavorProfile:
        'Tangy and tropical flavor combination resembling a mix of strawberry, pineapple, and citrus.',
  ),
  Fruit(
    name: 'Red Gala Apple',
    imageUrl:
        'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?q=80&w=600&auto=format&fit=crop',
    flavorProfile:
        'Crisp and refreshingly sweet with subtle floral honey undertones.',
  ),
  Fruit(
    name: 'Fresh Black Grapes',
    imageUrl:
        'https://images.unsplash.com/photo-1537640538966-79f369143f8f?q=80&w=600&auto=format&fit=crop',
    flavorProfile:
        'Deeply sweet, rich, and juicy taste with a light natural tartness.',
  ),
];

// 3. Main Catalog Screen at "/"
class FruitListScreen extends StatelessWidget {
  const FruitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Image.asset(
          'assets/marketplace.png',
          height: 200,
          errorBuilder: (context, error, stackTrace) => const Text(
            'FRESH MARKETPLACE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'FRESH & PRODUCE',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(child: Divider(thickness: 1)),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: fruits.length,
              itemBuilder: (context, index) {
                final fruit = fruits[index];
                return GroceryCard(
                  fruit: fruit,
                  onTap: () => context.go('/fruit/${fruit.name}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Grid Card Widget
class GroceryCard extends StatelessWidget {
  final Fruit fruit;
  final VoidCallback onTap;

  const GroceryCard({super.key, required this.fruit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                'FRESH & PRODUCE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.black54,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    fruit.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.fastfood, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Text(
                fruit.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. Simplified Detail Page at "/fruit/:name"
class FruitDetailScreen extends StatelessWidget {
  final String fruitName;

  const FruitDetailScreen({super.key, required this.fruitName});

  @override
  Widget build(BuildContext context) {
    final fruit = fruits.firstWhere(
      (item) => item.name.toLowerCase() == fruitName.toLowerCase(),
      orElse: () => const Fruit(
        name: 'Fresh Fruit',
        imageUrl:
            'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?q=80&w=600&auto=format&fit=crop',
        flavorProfile: 'Sweet and refreshing flavor profile.',
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          fruit.name,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  fruit.imageUrl,
                  height: 220,
                  width: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                fruit.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                fruit.flavorProfile,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}