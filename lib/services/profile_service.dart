import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Profile?> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('id, email, first_name, last_name, role, created_at')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Profile.fromMap(response);
  }
}
