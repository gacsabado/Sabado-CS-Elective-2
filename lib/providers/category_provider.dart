import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../services/category_service.dart';
import 'product_provider.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) {
  return ref.watch(categoryServiceProvider).fetchAll();
});

final categoryActionsProvider = Provider<CategoryActions>((ref) {
  return CategoryActions(ref);
});

class CategoryActions {
  final Ref _ref;

  CategoryActions(this._ref);

  CategoryService get _service => _ref.read(categoryServiceProvider);

  void _refresh() {
    _ref.invalidate(categoriesProvider);
    // Product rows embed their category name.
    _ref.invalidate(productPageProvider);
    _ref.invalidate(adminProductsProvider);
  }

  Future<void> add(String name) async {
    await _service.add(name);
    _refresh();
  }

  Future<void> rename(String id, String name) async {
    await _service.rename(id, name);
    _refresh();
  }

  Future<void> delete(String id) async {
    await _service.delete(id);
    _refresh();
  }
}


