import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile.dart';
import '../services/profile_service.dart';
import 'auth_provider.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

/// The signed-in user's profile (including role). Rebuilds when the user
/// changes, so a new login never sees the previous user's role.
final profileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) return null;

  return ref.watch(profileServiceProvider).getProfile(user.id);
});
