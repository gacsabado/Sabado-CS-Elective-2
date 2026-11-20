
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_data.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/auth/signin_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/customer/cart_screen.dart';
import '../../screens/customer/checkout_confirmation_screen.dart';
import '../../screens/customer/home_screen.dart';
import '../../screens/customer/order_history_screen.dart';
import '../../screens/customer/product_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/admin/admin_products_screen.dart';

GoRouter createAppRouter({
  required ThemeMode Function() getThemeMode,
  required VoidCallback onToggleTheme,
}) {
  GoRouter.optionURLReflectsImperativeAPIs = true;
  
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(
          themeMode: getThemeMode(),
          onToggleTheme: onToggleTheme,
        ),
      ),

      GoRoute(
        path: '/signin',
        builder: (context, state) => const SigninScreen(),
      ),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
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
            (product) => product.id == id,
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
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(currentUserProvider);

              if (user == null) {
                return const SigninScreen();
              }

              return const CheckoutConfirmationScreen();
            },
          );
        },
      ),

      GoRoute(
        path: '/profile',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(currentUserProvider);

              if (user == null) {
                return const SigninScreen();
              }

              return ProfileScreen(
                themeMode: getThemeMode(),
                onToggleTheme: onToggleTheme,
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/orders',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(currentUserProvider);

              if (user == null) {
                return const SigninScreen();
              }

              return const OrderHistoryScreen();
            },
          );
        },
      ),

      // ADMIN DASHBOARD
      GoRoute(
        path: '/admin',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(currentUserProvider);

              if (user == null) {
                return const SigninScreen();
              }

              final profileAsync = ref.watch(profileProvider);

              return profileAsync.when(
                loading: () => const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) => Scaffold(
                  body: Center(
                    child: Text(
                      'Unable to verify admin access: $error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (profile) {
                  if (profile?.isAdmin != true) {
                    return HomeScreen(
                      themeMode: getThemeMode(),
                      onToggleTheme: onToggleTheme,
                    );
                  }

                  return const AdminDashboardScreen();
                },
              );
            },
          );
        },
      ),
      // ADMIN PRODUCT MANAGEMENT
      GoRoute(
        path: '/admin/products',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(currentUserProvider);

              if (user == null) {
                return const SigninScreen();
              }

              final profileAsync = ref.watch(profileProvider);

              return profileAsync.when(
                loading: () => const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) => Scaffold(
                  body: Center(
                    child: Text(
                      'Unable to verify admin access: $error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (profile) {
                  if (profile?.isAdmin != true) {
                    return HomeScreen(
                      themeMode: getThemeMode(),
                      onToggleTheme: onToggleTheme,
                    );
                  }

                  return const AdminProductsScreen();
                },
              );
            },
          );
        },
      ),
    ],
  );
}
