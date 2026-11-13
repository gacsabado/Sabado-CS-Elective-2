
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/mock_data.dart';
import 'models/product.dart';
import 'providers/product_provider.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_confirmation_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Supabase credentials from .env
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabasePublishableKey =
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    throw StateError(
      'Missing Supabase URL or publishable key in .env file.',
    );
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const PopMartApp());
}

class PopMartApp extends StatefulWidget {
  const PopMartApp({super.key});

  @override
  State<PopMartApp> createState() => _PopMartAppState();
}

class _PopMartAppState extends State<PopMartApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
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
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      GoRoute(
        path: '/signin',
        builder: (context, state) => const SigninScreen(),
      ),

      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final extraProduct = state.extra;

          if (extraProduct is Product) {
            return ProductDetailScreen(product: extraProduct);
          }

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
        builder: (context, state) =>
            const CheckoutConfirmationScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    // LIGHT MODE
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE55322),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // DARK MODE
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE55322),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // PROVIDER + APP
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            Supabase.instance.client,
          )..loadProducts(),
        ),
      ],
      child: MaterialApp.router(
        title: 'POP MART Hirono Store',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _themeMode,
        routerConfig: _router,
      ),
    );
  }
}
