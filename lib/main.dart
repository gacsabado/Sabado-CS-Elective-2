import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/mock_data.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_confirmation_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';

void main() {
  runApp(const PopMartApp());
}

///para ma hold ang global ThemeMode para maka live theme toggling.
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
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final product = hironoProducts.firstWhere(
            (p) => p.id == id,
            orElse: () => hironoProducts.first,
          );
          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutConfirmationScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    
    //LIGHT MODE
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepOrange,
        primary: const Color(0xFFE55322),
        brightness: Brightness.light,
      ),
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
          backgroundColor: const Color(0xFFE55322),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    //DARK MODE
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepOrange,
        primary: const Color(0xFFE55322),
        brightness: Brightness.dark,
      ),
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
          backgroundColor: const Color(0xFFE55322),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
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