import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/state_views.dart';

/// Shown while the signed-in user's profile (and role) is loading, so the
/// app never flashes the wrong experience. If it fails, the user can retry
/// or sign out instead of being stuck.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      body: profileAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => _Failure(
          message: error,
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (profile) => profile == null
            ? _Failure(
                message: 'Your account profile could not be found.',
                onRetry: () => ref.invalidate(profileProvider),
              )
            : const LoadingView(),
      ),
    );
  }
}

class _Failure extends ConsumerWidget {
  final Object message;
  final VoidCallback onRetry;

  const _Failure({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ErrorView(
          error: message,
          title: 'Unable to load your account',
          onRetry: onRetry,
        ),
        TextButton(
          onPressed: () => ref.read(authServiceProvider).signOut(),
          child: const Text('SIGN OUT'),
        ),
      ],
    );
  }
}
