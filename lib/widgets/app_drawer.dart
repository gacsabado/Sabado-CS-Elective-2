import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/profile_provider.dart';

/// One drawer for the whole app. Admin destinations only appear for admins;
/// customers never see them (and the router and database also refuse them).
class AppDrawer extends ConsumerWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final profileAsync = ref.watch(profileProvider);
    final isAdmin = profileAsync.value?.isAdmin == true;

    final items = isAdmin
        ? const [
            _Dest('Dashboard', Icons.dashboard_outlined, '/admin'),
            _Dest('Products', Icons.inventory_2_outlined, '/admin/products'),
            _Dest('Categories', Icons.category_outlined, '/admin/categories'),
            _Dest('Orders', Icons.receipt_long_outlined, '/admin/orders'),
            _Dest('My Profile', Icons.person_outline, '/profile'),
          ]
        : const [
            _Dest('Shop', Icons.storefront_outlined, '/'),
            _Dest('My Cart', Icons.shopping_cart_outlined, '/cart'),
            _Dest('My Orders', Icons.receipt_long_outlined, '/orders'),
            _Dest('My Profile', Icons.person_outline, '/profile'),
          ];

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Icon(Icons.storefront_rounded,
                        color: colors.onPrimary),
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
                      Text(
                        profileAsync.isLoading
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
            for (final item in items)
              ListTile(
                leading: Icon(item.icon),
                title: Text(item.label),
                selected: currentRoute == item.route,
                selectedTileColor: colors.primary.withValues(alpha: 0.1),
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != item.route) context.go(item.route);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _Dest {
  final String label;
  final IconData icon;
  final String route;

  const _Dest(this.label, this.icon, this.route);
}
