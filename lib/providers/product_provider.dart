
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final SupabaseClient _supabase;

  ProductProvider(this._supabase);

  static const int pageSize = 8;

  List<Product> _products = [];

  double _minPrice = 0;
  double _maxPrice = 100;

  int _currentPage = 0;

  bool _isLoading = false;
  bool _hasMore = false;

  String? _error;

  // Getters
  List<Product> get products => List.unmodifiable(_products);

  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;

  int get currentPage => _currentPage;

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  String? get error => _error;

  // FETCH PRODUCTS WITH PRICE FILTER AND PAGINATION
  Future<void> loadProducts({bool reset = false}) async {
    if (_isLoading) return;

    if (reset) {
      _currentPage = 0;
      _products = [];
      _hasMore = false;
    }

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final start = _currentPage * pageSize;

      final response = await _supabase
          .from('products')
          .select()
          .gte('price', _minPrice)
          .lte('price', _maxPrice)
          .order('name')
          // Fetch one extra record to determine
          // whether another page exists.
          .range(start, start + pageSize);

      final rows = List<Map<String, dynamic>>.from(response);

      _hasMore = rows.length > pageSize;

      _products = rows
          .take(pageSize)
          .map((row) => Product.fromMap(row))
          .toList();

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CHANGE PRICE RANGE
  Future<void> setPriceRange(
    double min,
    double max,
  ) async {
    if (min > max) return;

    _minPrice = min;
    _maxPrice = max;

    await loadProducts(reset: true);
  }

  // NEXT PAGE
  Future<void> nextPage() async {
    if (!_hasMore || _isLoading) return;

    _currentPage++;

    await loadProducts();
    
    if (_error != null) {
      _currentPage--;
    }
  }

  // PREVIOUS PAGE
  Future<void> previousPage() async {
    if (_currentPage <= 0 || _isLoading) return;

    _currentPage--;

    await loadProducts();

    if (_error != null) {
      _currentPage++;
    }
  }

  // REFRESH PRODUCTS
  Future<void> refresh() async {
    await loadProducts(reset: true);
  }
}
