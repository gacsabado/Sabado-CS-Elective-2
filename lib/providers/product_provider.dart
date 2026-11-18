import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

class ProductState {
  final List<Product> products;
  final double minPrice;
  final double maxPrice;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const ProductState({
    this.products = const [],
    this.minPrice = 0,
    this.maxPrice = 100,
    this.currentPage = 0,
    this.isLoading = false,
    this.hasMore = false,
    this.error,
  });

  ProductState copyWith({
    List<Product>? products,
    double? minPrice,
    double? maxPrice,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return ProductState(
      products: products ?? this.products,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final productProvider = NotifierProvider<ProductNotifier, ProductState>(
  ProductNotifier.new,
);

class ProductNotifier extends Notifier<ProductState> {
  static const int pageSize = 8;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  ProductState build() {
    return const ProductState();
  }

  // FETCH PRODUCTS WITH PRICE FILTER AND PAGINATION
  Future<void> loadProducts({bool reset = false}) async {
    if (state.isLoading) return;

    if (reset) {
      state = state.copyWith(
        currentPage: 0,
        products: [],
        hasMore: false,
        clearError: true,
      );
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final start = state.currentPage * pageSize;

      final response = await _supabase
          .from('products')
          .select()
          .gte('price', state.minPrice)
          .lte('price', state.maxPrice)
          .order('name')
          .range(start, start + pageSize);

      final rows = List<Map<String, dynamic>>.from(response);

      state = state.copyWith(
        products: rows
            .take(pageSize)
            .map((row) => Product.fromMap(row))
            .toList(),
        hasMore: rows.length > pageSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // CHANGE PRICE RANGE
  Future<void> setPriceRange(double min, double max) async {
    if (min > max) return;

    state = state.copyWith(
      minPrice: min,
      maxPrice: max,
      currentPage: 0,
      clearError: true,
    );

    await loadProducts(reset: true);
  }

  // NEXT PAGE
  Future<void> nextPage() async {
    if (!state.hasMore || state.isLoading) return;

    final previousPage = state.currentPage;

    state = state.copyWith(currentPage: previousPage + 1);

    await loadProducts();

    if (state.error != null) {
      state = state.copyWith(currentPage: previousPage);
    }
  }

  // PREVIOUS PAGE
  Future<void> previousPage() async {
    if (state.currentPage <= 0 || state.isLoading) return;

    final previousPage = state.currentPage;

    state = state.copyWith(currentPage: previousPage - 1);

    await loadProducts();

    if (state.error != null) {
      state = state.copyWith(currentPage: previousPage);
    }
  }

  // REFRESH PRODUCTS
  Future<void> refresh() async {
    await loadProducts(reset: true);
  }
}
