import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Profile?> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('id, email, firstname, lastname, role_id, created_at, roles(role)')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Profile.fromMap(response);
  }
}
