import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/state_views.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _CategoryDialog(initialName: category?.name),
    );

    if (name == null || !context.mounted) return;

    try {
      final actions = ref.read(categoryActionsProvider);
      if (category == null) {
        await actions.add(name);
      } else {
        await actions.rename(category.id, name);
      }
      if (!context.mounted) return;
      showMessage(context, category == null ? 'Category added.' : 'Category renamed.');
    } catch (error) {
      if (!context.mounted) return;
      showMessage(context, 'Unable to save: ${friendlyError(error)}',
          error: true);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Delete "${category.name}"? Products in this category will become '
          'uncategorized.',
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

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(categoryActionsProvider).delete(category.id);
      if (!context.mounted) return;
      showMessage(context, '"${category.name}" deleted.');
    } catch (error) {
      if (!context.mounted) return;
      showMessage(context, 'Unable to delete: ${friendlyError(error)}',
          error: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/admin/categories'),
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(categoriesProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add category'),
      ),
      body: categoriesAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          title: 'Could not load categories',
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyView(
              icon: Icons.category_outlined,
              title: 'No categories yet',
              message: 'Add a category, then assign products to it.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(categoriesProvider);
              await ref.read(categoriesProvider.future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final category = categories[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: Text(category.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              _edit(context, ref, category: category),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: Icon(Icons.delete_outline,
                              color: Theme.of(context).colorScheme.error),
                          onPressed: () => _delete(context, ref, category),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final String? initialName;

  const _CategoryDialog({this.initialName});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'Add category' : 'Edit category'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Category name *'),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Name is required.'
              : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
