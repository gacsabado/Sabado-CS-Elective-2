import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../models/product_filter.dart';
import '../services/product_service.dart';
import 'admin_dashboard_provider.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// ---------------------------------------------------------------------
// Customer browsing: filter state + paged results
// ---------------------------------------------------------------------

final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilter>(
  ProductFilterNotifier.new,
);

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => const ProductFilter();

  // Any change to a filter goes back to the first page.
  void setSearch(String value) =>
      state = state.copyWith(search: value.trim(), page: 0);

  void setCategory(String? categoryId) => state = categoryId == null
      ? state.copyWith(clearCategory: true, page: 0)
      : state.copyWith(categoryId: categoryId, page: 0);

  void setPriceRange(double min, double max) =>
      state = state.copyWith(minPrice: min, maxPrice: max, page: 0);

  void setInStockOnly(bool value) =>
      state = state.copyWith(inStockOnly: value, page: 0);

  void setSort(ProductSort sort) => state = state.copyWith(sort: sort, page: 0);

  void nextPage() => state = state.copyWith(page: state.page + 1);

  void previousPage() {
    if (state.page > 0) state = state.copyWith(page: state.page - 1);
  }

  void reset() => state = const ProductFilter();
}

final productPageProvider = FutureProvider.autoDispose<ProductPage>((ref) {
  final filter = ref.watch(productFilterProvider);
  return ref.watch(productServiceProvider).fetchProducts(filter);
});

// ---------------------------------------------------------------------
// Admin: whole catalog
// ---------------------------------------------------------------------

final adminProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(productServiceProvider).fetchAll();
});

// ---------------------------------------------------------------------
// Single product (detail page, edit form)
// ---------------------------------------------------------------------

final productDetailProvider =
    FutureProvider.autoDispose.family<Product?, String>((ref, id) {
  return ref.watch(productServiceProvider).fetchById(id);
});

// ---------------------------------------------------------------------
// Realtime: watch once from a screen; refreshes product lists on change.
// The listener and debounce timer are cleaned up when the screen goes away.
// ---------------------------------------------------------------------

final productRealtimeProvider = Provider.autoDispose<void>((ref) {
  Timer? debounce;

  final stop = ref.watch(productServiceProvider).subscribeToChanges(() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 300), () {
      if (!ref.mounted) return;
      ref.invalidate(productPageProvider);
      ref.invalidate(adminProductsProvider);
    });
  });

  ref.onDispose(() {
    debounce?.cancel();
    stop();
  });
});

// ---------------------------------------------------------------------
// Admin actions (RLS is the real gate; these just call the service)
// ---------------------------------------------------------------------

final productActionsProvider = Provider<ProductActions>((ref) {
  return ProductActions(ref);
});

class ProductActions {
  final Ref _ref;

  ProductActions(this._ref);

  ProductService get _service => _ref.read(productServiceProvider);

  void _refresh({String? productId}) {
    _ref.invalidate(adminProductsProvider);
    _ref.invalidate(productPageProvider);
    _ref.invalidate(adminDashboardProvider);
    if (productId != null) _ref.invalidate(productDetailProvider(productId));
  }

  /// Adds (id empty) or updates a product. Uploads [imageBytes] first when
  /// the admin picked a new image.
  Future<void> save(
    Product product, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    var toSave = product;

    if (imageBytes != null) {
      final url = await _service.uploadImage(
        imageBytes,
        imageName ?? 'product.jpg',
      );
      toSave = Product(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        stockQuantity: product.stockQuantity,
        series: product.series,
        categoryId: product.categoryId,
        imageUrl: url,
      );
    }

    if (toSave.id.isEmpty) {
      await _service.add(toSave);
    } else {
      await _service.update(toSave);
    }

    _refresh(productId: toSave.id.isEmpty ? null : toSave.id);
  }

  Future<void> delete(String id) async {
    await _service.delete(id);
    _refresh(productId: id);
  }
}
