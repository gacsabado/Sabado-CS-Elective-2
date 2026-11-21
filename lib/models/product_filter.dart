import 'product.dart';

enum ProductSort {
  nameAsc('Name: A to Z'),
  priceAsc('Price: low to high'),
  priceDesc('Price: high to low'),
  newest('Newest first');

  final String label;
  const ProductSort(this.label);
}

class ProductFilter {
  static const double maxPriceLimit = 10000;
  static const int pageSize = 8;

  final String search;
  final String? categoryId;
  final double minPrice;
  final double maxPrice;
  final bool inStockOnly;
  final ProductSort sort;
  final int page;

  const ProductFilter({
    this.search = '',
    this.categoryId,
    this.minPrice = 0,
    this.maxPrice = maxPriceLimit,
    this.inStockOnly = false,
    this.sort = ProductSort.nameAsc,
    this.page = 0,
  });

  bool get isDefault =>
      search.isEmpty &&
      categoryId == null &&
      minPrice == 0 &&
      maxPrice == maxPriceLimit &&
      !inStockOnly &&
      sort == ProductSort.nameAsc;

  ProductFilter copyWith({
    String? search,
    String? categoryId,
    bool clearCategory = false,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    ProductSort? sort,
    int? page,
  }) {
    return ProductFilter(
      search: search ?? this.search,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sort: sort ?? this.sort,
      page: page ?? this.page,
    );
  }
}

class ProductPage {
  final List<Product> products;
  final bool hasMore;

  const ProductPage({required this.products, required this.hasMore});
}
