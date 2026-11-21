import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/profile_provider.dart';

/// Goes back if there is a previous screen; otherwise goes to the user's
/// home (admin dashboard for admins, the shop for customers).
class AppBackButton extends ConsumerWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(profileProvider).value?.isAdmin == true;

    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(isAdmin ? '/admin' : '/');
        }
      },
    );
  }
}