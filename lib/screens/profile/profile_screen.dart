import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_back_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      // Empty the cart first; the router then sends the user to /signin.
      ref.read(cartProvider.notifier).clearCart();

      await ref.read(authServiceProvider).signOut();
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to sign out: $error')),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not available';

    final localDate = date.toLocal();

    return '${_monthName(localDate.month)} ${localDate.day}, ${localDate.year}';
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                const Text('Unable to load your profile.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(profileProvider),
                  child: const Text('RETRY'),
                ),
              ],
            ),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('Profile information not found.'),
            );
          }

          final roleName = profile.isAdmin ? 'Administrator' : 'Customer';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // PROFILE HEADER
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: theme.colorScheme.primary,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.fullName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profile.email ?? 'No email available',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Chip(
                        avatar: Icon(
                          profile.isAdmin
                              ? Icons.admin_panel_settings
                              : Icons.shopping_bag,
                          size: 18,
                        ),
                        label: Text(roleName),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ACCOUNT INFORMATION
              Text(
                'ACCOUNT INFORMATION',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Full Name'),
                      subtitle: Text(profile.fullName),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email Address'),
                      subtitle: Text(
                        profile.email ?? 'Not available',
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Account Type'),
                      subtitle: Text(roleName),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Member Since'),
                      subtitle: Text(
                        _formatDate(profile.createdAt),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CUSTOMER ORDER HISTORY
              if (profile.isCustomer) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('My Order History'),
                    subtitle: const Text(
                      'View your previous purchases',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/orders'),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // THEME
              Card(
                child: SwitchListTile(
                  secondary: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  title: const Text('Dark Mode'),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                ),
              ),

              const SizedBox(height: 20),

              // SIGN OUT
              ElevatedButton.icon(
                onPressed: () => _signOut(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text('SIGN OUT'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
