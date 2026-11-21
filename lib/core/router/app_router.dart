import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/admin_orders_screen.dart';
import '../../screens/admin/admin_products_screen.dart';
import '../../screens/admin/categories_screen.dart';
import '../../screens/admin/product_form_screen.dart';
import '../../screens/auth/signin_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/customer/cart_screen.dart';
import '../../screens/customer/checkout_confirmation_screen.dart';
import '../../screens/customer/home_screen.dart';
import '../../screens/customer/order_history_screen.dart';
import '../../screens/customer/product_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';

/// Auth gate + role gate in one place.
///
/// - Signed out: only /signin and /signup.
/// - Signed in, role still loading: /loading.
/// - Admin: /admin/* and /profile only.
/// - Customer: everything except /admin/*.
///
/// This only controls what the UI shows. The real protection is Row Level
/// Security in the database.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);

  ref.listen(currentUserProvider, (_, _) => refresh.value++);
  ref.listen(profileProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute = location == '/signin' || location == '/signup';

      final user = ref.read(currentUserProvider);

      if (user == null) return isAuthRoute ? null : '/signin';

      final profile = ref.read(profileProvider).value;

      if (profile == null) return location == '/loading' ? null : '/loading';

      final home = profile.isAdmin ? '/admin' : '/';

      if (isAuthRoute || location == '/loading') return home;

      final inAdminArea = location.startsWith('/admin');

      if (profile.isAdmin) {
        final allowed = inAdminArea || location == '/profile';
        return allowed ? null : home;
      }

      return inAdminArea ? home : null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/loading', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/signin', builder: (_, _) => const SigninScreen()),
      GoRoute(path: '/signup', builder: (_, _) => const SignupScreen()),
      GoRoute(
        path: '/product/:id',
        builder: (_, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
      GoRoute(
        path: '/order-confirmation',
        builder: (_, _) => const CheckoutConfirmationScreen(),
      ),
      GoRoute(path: '/orders', builder: (_, _) => const OrderHistoryScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),

      // ADMIN
      GoRoute(path: '/admin', builder: (_, _) => const AdminDashboardScreen()),
      GoRoute(
        path: '/admin/products',
        builder: (_, _) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: '/admin/products/new',
        builder: (_, _) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/admin/products/:id/edit',
        builder: (_, state) =>
            ProductFormScreen(productId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (_, _) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (_, _) => const AdminOrdersScreen(),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });

  return router;
});
