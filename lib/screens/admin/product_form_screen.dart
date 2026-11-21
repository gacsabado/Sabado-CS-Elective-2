import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/format.dart';
import '../../models/product.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/state_views.dart';

/// Add (productId == null) or edit (productId set) a product. Admin only:
/// the router blocks other roles and the database refuses their writes.
class ProductFormScreen extends ConsumerWidget {
  final String? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = productId;

    if (id == null) {
      return const _ProductForm(product: null);
    }

    final productAsync = ref.watch(productDetailProvider(id));

    return productAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Edit product')),
        body: const LoadingView(),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit product')),
        body: ErrorView(
          error: error,
          onRetry: () => ref.invalidate(productDetailProvider(id)),
        ),
      ),
      data: (product) => product == null
          ? Scaffold(
              appBar: AppBar(title: const Text('Edit product')),
              body: const EmptyView(
                icon: Icons.inventory_2_outlined,
                title: 'Product not found',
                message: 'It may have been deleted.',
              ),
            )
          : _ProductForm(product: product),
    );
  }
}

class _ProductForm extends ConsumerStatefulWidget {
  final Product? product;

  const _ProductForm({required this.product});

  @override
  ConsumerState<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _stock;

  String? _categoryId;
  Uint8List? _imageBytes;
  String? _imageName;
  String? _imageError;
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    // Edit form is pre-filled with the current values.
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p?.price.toString() ?? '');
    _stock = TextEditingController(text: p?.stockQuantity.toString() ?? '');
    _categoryId = p?.categoryId;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
        _imageError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _imageError = 'Unable to select image: $error');
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required.';
    return null;
  }

  // A number of zero or more.
  String? _validatePrice(String? value) {
    final price = double.tryParse(value?.trim() ?? '');
    if (price == null || !price.isFinite) return 'Enter a valid number.';
    if (price < 0) return 'Price cannot be negative.';
    if (price > 99999999.99) return 'Price is too large.';
    return null;
  }

  // A whole number of zero or more.
  String? _validateStock(String? value) {
    final stock = int.tryParse(value?.trim() ?? '');
    if (stock == null) return 'Enter a whole number.';
    if (stock < 0) return 'Stock cannot be negative.';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final hasImage = _imageBytes != null ||
        (widget.product?.imageUrl.isNotEmpty ?? false);

    if (!hasImage) {
      setState(() => _imageError = 'Please choose a product image.');
      return;
    }

    setState(() {
      _isSaving = true;
      _imageError = null;
    });

    try {
      await ref.read(productActionsProvider).save(
            Product(
              id: widget.product?.id ?? '',
              name: _name.text.trim(),
              description: _description.text.trim(),
              price: double.parse(_price.text.trim()),
              stockQuantity: int.parse(_stock.text.trim()),
              categoryId: _categoryId,
              imageUrl: widget.product?.imageUrl ?? '',
            ),
            imageBytes: _imageBytes,
            imageName: _imageName,
          );

      if (!mounted) return;

      showMessage(
        context,
        _isEditing ? 'Product updated.' : 'Product added.',
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showMessage(context, 'Unable to save: ${friendlyError(error)}',
          error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final categoriesAsync = ref.watch(categoriesProvider);
    final existingUrl = widget.product?.imageUrl ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit product' : 'Add product'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _price,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
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
                        controller: _stock,
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
                const SizedBox(height: 16),
                categoriesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) => Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Categories failed to load: ${friendlyError(error)}',
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref.invalidate(categoriesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                  data: (categories) {
                    if (categories.isEmpty) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.category_outlined),
                          title: const Text('No categories yet'),
                          subtitle: const Text('Create one before adding products.'),
                          trailing: TextButton(
                            onPressed: () => context.push('/admin/categories'),
                            child: const Text('Create'),
                          ),
                        ),
                      );
                    }

                    final selected = categories.any((c) => c.id == _categoryId)
                        ? _categoryId
                        : null;

                    return DropdownButtonFormField<String>(
                      initialValue: selected,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: [
                        for (final c in categories)
                          DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ],
                      onChanged: (value) => setState(() => _categoryId = value),
                      validator: (value) =>
                          value == null ? 'Choose a category.' : null,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text('Product image *',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _imageError != null
                          ? colors.error
                          : colors.outlineVariant,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _imageBytes != null
                      ? Image.memory(_imageBytes!, fit: BoxFit.contain)
                      : existingUrl.isNotEmpty
                          ? Image.network(
                              existingUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    size: 48),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.add_photo_alternate_outlined,
                                  size: 52),
                            ),
                ),
                if (_imageError != null) ...[
                  const SizedBox(height: 6),
                  Text(_imageError!, style: TextStyle(color: colors.error)),
                ],
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _pickImage,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(_imageBytes != null || existingUrl.isNotEmpty
                      ? 'Choose another image'
                      : 'Upload image from device'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Save changes' : 'Add product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
