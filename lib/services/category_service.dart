import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';

/// The only place that talks to the `categories` table.
class CategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Category>> fetchAll() async {
    final rows = await _supabase.from('categories').select().order('name');
    return List<Map<String, dynamic>>.from(rows).map(Category.fromMap).toList();
  }

  Future<void> add(String name) async {
    await _supabase.from('categories').insert({'name': name.trim()});
  }

  Future<void> rename(String id, String name) async {
    final updated = await _supabase
        .from('categories')
        .update({'name': name.trim()})
        .eq('id', id)
        .select('id');

    if (updated.isEmpty) {
      throw Exception('The category could not be updated. You may not have '
          'permission.');
    }
  }

  Future<void> delete(String id) async {
    final deleted = await _supabase
        .from('categories')
        .delete()
        .eq('id', id)
        .select('id');

    if (deleted.isEmpty) {
      throw Exception('The category could not be deleted. You may not have '
          'permission.');
    }
  }
}

