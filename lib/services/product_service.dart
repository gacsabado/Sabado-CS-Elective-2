import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../models/product_filter.dart';

/// The only place that talks to the `products` table and the
/// `product-images` storage bucket.
class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const _bucket = 'product-images';
  static const _select = '*, categories(name)';

  // READ (customer browsing: search + category + price + stock + sort + page)
  Future<ProductPage> fetchProducts(ProductFilter filter) async {
    var query = _supabase
        .from('products')
        .select(_select)
        .gte('price', filter.minPrice)
        .lte('price', filter.maxPrice);

    final search = _sanitizeSearch(filter.search);
    if (search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,description.ilike.%$search%,series.ilike.%$search%');
    }

    if (filter.categoryId != null) {
      query = query.eq('category_id', filter.categoryId!);
    }

    if (filter.inStockOnly) {
      query = query.gt('stock_quantity', 0);
    }

    final sorted = switch (filter.sort) {
      ProductSort.nameAsc => query.order('name', ascending: true),
      ProductSort.priceAsc => query.order('price', ascending: true),
      ProductSort.priceDesc => query.order('price', ascending: false),
      ProductSort.newest => query.order('created_at', ascending: false),
    };

    final start = filter.page * ProductFilter.pageSize;

    // Ask for one extra row to know whether a next page exists.
    final rows = await sorted.range(start, start + ProductFilter.pageSize);
    final list = List<Map<String, dynamic>>.from(rows);

    return ProductPage(
      products: list
          .take(ProductFilter.pageSize)
          .map(Product.fromMap)
          .toList(),
      hasMore: list.length > ProductFilter.pageSize,
    );
  }

  // READ (admin: full catalog)
  Future<List<Product>> fetchAll() async {
    final rows = await _supabase.from('products').select(_select).order('name');
    return List<Map<String, dynamic>>.from(rows).map(Product.fromMap).toList();
  }

  Future<Product?> fetchById(String id) async {
    final row = await _supabase
        .from('products')
        .select(_select)
        .eq('id', id)
        .maybeSingle();

    return row == null ? null : Product.fromMap(row);
  }

  // WRITE (admin only - enforced by RLS)
  Future<void> add(Product product) async {
    await _supabase.from('products').insert(product.toMap());
  }

  Future<void> update(Product product) async {
    final updated = await _supabase
        .from('products')
        .update(product.toMap())
        .eq('id', product.id)
        .select('id');

    // RLS hides rows the user may not update, so 0 rows == denied/not found.
    if (updated.isEmpty) {
      throw Exception('The product could not be updated. It may have been '
          'deleted, or you may not have permission.');
    }
  }

  Future<void> delete(String id) async {
    final deleted = await _supabase
        .from('products')
        .delete()
        .eq('id', id)
        .select('id');

    if (deleted.isEmpty) {
      throw Exception('The product could not be deleted. It may already be '
          'gone, or you may not have permission.');
    }
  }

  // STORAGE
  Future<String> uploadImage(Uint8List bytes, String fileName) async {
    final extension = _extension(fileName);
    final path = 'product_${DateTime.now().microsecondsSinceEpoch}.$extension';

    await _supabase.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: _contentType(extension),
            upsert: false,
          ),
        );

    return _supabase.storage.from(_bucket).getPublicUrl(path);
  }

  // REALTIME - returns a function that stops listening.
  void Function() subscribeToChanges(void Function() onChange) {
    final channel = _supabase
        .channel('products-changes-${DateTime.now().microsecondsSinceEpoch}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (_) => onChange(),
        )
        .subscribe();

    return () => _supabase.removeChannel(channel);
  }

  String _sanitizeSearch(String value) {
    // Characters that would break the PostgREST `or` filter syntax.
    return value.trim().replaceAll(RegExp(r'[,()%*\\]'), ' ').trim();
  }

  String _extension(String filename) {
    final parts = filename.split('.');
    if (parts.length < 2) return 'jpg';
    final ext = parts.last.toLowerCase();
    return const ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)
        ? ext
        : 'jpg';
  }

  String _contentType(String extension) {
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }
}


