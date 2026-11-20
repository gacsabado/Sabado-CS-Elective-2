
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/admin_dashboard_provider.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() =>
      _AdminProductsScreenState();
}

class _AdminProductsScreenState
    extends ConsumerState<AdminProductsScreen> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  List<Product> get _filteredProducts {
    if (_searchQuery.trim().isEmpty) return _products;

    final query = _searchQuery.toLowerCase();

    return _products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.series.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await _supabase
          .from('products')
          .select()
          .order('name');

      final products = (response as List)
          .map((row) => Product.fromMap(row as Map<String, dynamic>))
          .toList();

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showProductForm({Product? product}) async {
    final result = await showDialog<Product>(
      context: context,
      builder: (_) => _ProductFormDialog(product: product),
    );

    if (result == null) return;

    try {
      final productNotifier = ref.read(productProvider.notifier);

      if (product == null) {
        // Add product through the shared Riverpod provider.
        await productNotifier.addProduct(result);
      } else {
        // Update product through the shared Riverpod provider.
        await productNotifier.updateProduct(result);
      }

      // Refresh the complete admin product list.
      await _loadProducts();

      // Refresh dashboard statistics.
      ref.invalidate(adminDashboardProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product == null
                ? 'Product added successfully.'
                : 'Product updated successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Unable to save product: $e');
    }
  }

  Future<void> _deleteProduct(Product product) async {
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
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Delete product through the shared Riverpod provider.
      await ref
          .read(productProvider.notifier)
          .deleteProduct(product.id);

      // Refresh the complete admin product list.
      await _loadProducts();

      // Refresh dashboard statistics.
      ref.invalidate(adminDashboardProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Unable to delete product: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final products = _filteredProducts;

    return Scaffold(
      drawer: const _ProductsAdminDrawer(
        currentRoute: '/admin/products',
      ),
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh products',
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add product'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                Text(
                  'Product catalog',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage your HIRONO products, pricing, and inventory.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Total products',
                        value: _products.length.toString(),
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Low stock',
                        value: _products
                            .where(
                              (product) => product.stockQuantity <= 5,
                            )
                            .length
                            .toString(),
                        icon: Icons.warning_amber_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products or series...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_error != null)
                  _ProductsError(
                    message: _error!,
                    onRetry: _loadProducts,
                  )
                else if (products.isEmpty)
                  _EmptyProducts(
                    hasSearch: _searchQuery.isNotEmpty,
                    onAdd: () => _showProductForm(),
                  )
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All products',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${products.length} item${products.length == 1 ? '' : 's'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...products.map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProductTile(
                        product: product,
                        onEdit: () =>
                            _showProductForm(product: product),
                        onDelete: () => _deleteProduct(product),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductsAdminDrawer extends StatelessWidget {
  final String currentRoute;

  const _ProductsAdminDrawer({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final selectedIndex = switch (currentRoute) {
      '/admin' => 1,
      '/admin/products' => 2,
      _ => 0,
    };

    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        Navigator.pop(context);

        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/admin');
            break;
          case 2:
            context.go('/admin/products');
            break;
          case 3:
            context.push('/profile');
            break;
        }
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HIRONO',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text('STORE MANAGEMENT'),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 8, 16, 8),
          child: Text(
            'MAIN MENU',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text('Home'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: Text('Dashboard'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2_rounded),
          label: Text('Products'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 24, 16, 8),
          child: Text(
            'COMING SOON',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.category_outlined, size: 22),
              SizedBox(width: 28),
              Text('Categories'),
              Spacer(),
              Text('Soon', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.receipt_long_outlined, size: 22),
              SizedBox(width: 28),
              Text('Orders'),
              Spacer(),
              Text('Soon', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 24, 16, 8),
          child: Text(
            'ACCOUNT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person_rounded),
          label: Text('My Profile'),
        ),
      ],
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 76,
                height: 82,
                color: colors.surfaceContainerHighest,
                child: product.imageUrl.isEmpty
                    ? Icon(
                        Icons.image_outlined,
                        color: colors.onSurfaceVariant,
                        size: 30,
                      )
                    : Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.broken_image_outlined,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
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
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (product.series.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      product.series,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '₱${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${product.stockQuantity}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: lowStock
                          ? colors.error
                          : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Product actions',
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onAdd;

  const _EmptyProducts({
    required this.hasSearch,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 52),
          const SizedBox(height: 14),
          Text(
            hasSearch ? 'No matching products' : 'No products yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            hasSearch
                ? 'Try searching with another product name.'
                : 'Add your first product to get started.',
            textAlign: TextAlign.center,
          ),
          if (!hasSearch) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add product'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProductsError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Could not load products.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  final Product? product;

  const _ProductFormDialog({this.product});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  final _imagePicker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _seriesController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageController;
  late final TextEditingController _descriptionController;

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isSaving = false;
  String? _imageError;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController = TextEditingController(
      text: product?.name ?? '',
    );
    _seriesController = TextEditingController(
      text: product?.series ?? '',
    );
    _priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: product?.stockQuantity.toString() ?? '0',
    );
    _imageController = TextEditingController(
      text: product?.imageUrl ?? '',
    );
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _seriesController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedImage == null) return;

      final bytes = await pickedImage.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = pickedImage.name;
        _imageError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _imageError = 'Unable to select image: $e';
      });
    }
  }

  String? _validatePrice(String? value) {
    final price = double.tryParse(value?.trim() ?? '');

    if (price == null) return 'Enter a valid price.';
    if (!price.isFinite || price <= 0) {
      return 'Price must be greater than 0.';
    }

    return null;
  }

  String? _validateStock(String? value) {
    final stock = int.tryParse(value?.trim() ?? '');

    if (stock == null) return 'Enter a whole number.';
    if (stock < 0) return 'Stock cannot be negative.';

    return null;
  }

  String _getExtension(String filename) {
    final parts = filename.split('.');
    if (parts.length < 2) return 'jpg';

    final extension = parts.last.toLowerCase();

    const allowedExtensions = [
      'jpg',
      'jpeg',
      'png',
      'webp',
      'gif',
    ];

    return allowedExtensions.contains(extension) ? extension : 'jpg';
  }

  String _getContentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  Future<String> _uploadImage() async {
    final bytes = _selectedImageBytes!;

    final extension = _getExtension(
      _selectedImageName ?? 'product.jpg',
    );

    final fileName =
        'product_${DateTime.now().microsecondsSinceEpoch}.$extension';

    final storagePath = fileName;

    await _supabase.storage
        .from('product-images')
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            contentType: _getContentType(extension),
            upsert: false,
          ),
        );

    return _supabase.storage
        .from('product-images')
        .getPublicUrl(storagePath);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _imageError = null;
    });

    try {
      String imageUrl = _imageController.text.trim();

      // Upload a newly selected image.
      // If no new image was selected, keep the existing image URL.
      if (_selectedImageBytes != null) {
        imageUrl = await _uploadImage();
      }

      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        series: _seriesController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: imageUrl,
        description: _descriptionController.text.trim(),
        stockQuantity: int.parse(_stockController.text.trim()),
      );

      if (!mounted) return;

      Navigator.pop(context, product);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _imageError = 'Unable to upload image: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit product' : 'Add product'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Product name *',
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Product name is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _seriesController,
                  decoration: const InputDecoration(
                    labelText: 'Series / category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Price (₱) *',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                        validator: _validatePrice,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stock *',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                        validator: _validateStock,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Product image',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _selectedImageBytes != null
                      ? Image.memory(
                          _selectedImageBytes!,
                          fit: BoxFit.contain,
                        )
                      : _imageController.text.trim().isNotEmpty
                          ? Image.network(
                              _imageController.text.trim(),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 48,
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 52,
                              ),
                            ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _pickImage,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: Text(
                      _selectedImageBytes != null
                          ? 'Choose another image'
                          : 'Upload image from device',
                    ),
                  ),
                ),
                if (_selectedImageName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _selectedImageName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Existing Supabase image URL (optional)',
                    prefixIcon: Icon(Icons.link_rounded),
                    helperText: 'A newly uploaded image takes priority.',
                  ),
                  validator: (value) {
                    final url = value?.trim() ?? '';

                    if (url.isEmpty || _selectedImageBytes != null) {
                      return null;
                    }

                    final uri = Uri.tryParse(url);

                    if (uri == null ||
                        !uri.hasScheme ||
                        uri.host.isEmpty ||
                        (uri.scheme != 'https' && uri.scheme != 'http')) {
                      return 'Enter a valid image URL.';
                    }

                    return null;
                  },
                ),
                if (_imageError != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _imageError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Save changes' : 'Add product'),
        ),
      ],
    );
  }
}
