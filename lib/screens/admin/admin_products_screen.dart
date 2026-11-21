import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/format.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/product_image.dart';
import '../../widgets/state_views.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() =>
      _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filter(List<Product> products) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return products;

    return products
      .where((p) =>
          p.name.toLowerCase().contains(query) ||
          p.series.toLowerCase().contains(query) ||
          p.categoryName.toLowerCase().contains(query))
      .toList();
  }

  Future<void> _delete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          'Are you sure you want to delete "${product.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(productActionsProvider).delete(product.id);
      if (!mounted) return;
      showMessage(context, '"${product.name}" deleted.');
    } catch (error) {
      if (!mounted) return;
      showMessage(context, 'Unable to delete: ${friendlyError(error)}',
          error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(adminProductsProvider);

    ref.watch(productRealtimeProvider);

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/admin/products'),
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(adminProductsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/products/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add product'),
      ),
      body: productsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          title: 'Could not load products',
          onRetry: () => ref.invalidate(adminProductsProvider),
        ),
        data: (all) {
          final products = _filter(all);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminProductsProvider);
              await ref.read(adminProductsProvider.future);
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Total products',
                            value: '${all.length}',
                            icon: Icons.inventory_2_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Low stock (5 or less)',
                            value:
                                '${all.where((p) => p.stockQuantity <= 5).length}',
                            icon: Icons.warning_amber_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Search by name, series or category...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              ),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (products.isEmpty)
                      EmptyView(
                        icon: Icons.inventory_2_outlined,
                        title: _query.isEmpty
                            ? 'No products yet'
                            : 'No matching products',
                        message: _query.isEmpty
                            ? 'Add your first product to get started.'
                            : 'Try searching with another name.',
                      )
                    else
                      for (final product in products)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ProductTile(
                            product: product,
                            onEdit: () => context
                                .push('/admin/products/${product.id}/edit'),
                            onDelete: () => _delete(product),
                          ),
                        ),
                    Text(
                      '${products.length} item${products.length == 1 ? '' : 's'}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: colors.primary, size: 25),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Admin product card with visible Edit and Delete buttons.
class _ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final lowStock = product.stockQuantity <= 5;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 76,
                    height: 82,
                    child: ProductImage(url: product.imageUrl, iconSize: 30),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (product.series.isNotEmpty || product.categoryName.isNotEmpty)
                        Text(
                          [product.categoryName, product.series]
                              .where((s) => s.isNotEmpty)
                              .join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        formatPrice(product.price),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Stock: ${product.stockQuantity}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              lowStock ? colors.error : colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(color: colors.error),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
