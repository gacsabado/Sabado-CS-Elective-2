import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pokemon_provider.dart';

class TypeFilterBar extends ConsumerWidget {
  const TypeFilterBar({super.key});

  static const List<String> types = [
    'Fire',
    'Water',
    'Grass',
    'Electric',
    'Poison',
    'Flying',
    'Bug',
    'Normal',
    'Ground',
    'Rock',
    'Psychic',
    'Ice',
    'Dragon',
    'Ghost',
    'Steel',
    'Dark',
    'Fairy',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pokemonProvider);
    final notifier = ref.read(pokemonProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // CLEAR / ALL FILTER CHIP
          ChoiceChip(
            label: const Text('All'),
            selected: state.selectedType == null,
            selectedColor: const Color(0xFFEF5350),
            labelStyle: TextStyle(
              color: state.selectedType == null
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            onSelected: (_) => notifier.clearTypeFilter(),
          ),
          const SizedBox(width: 8),

          // TYPE CHIPS
          ...types.map((type) {
            final isSelected =
                state.selectedType?.toLowerCase() == type.toLowerCase();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(type),
                selected: isSelected,
                selectedColor: const Color(0xFFEF5350),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                onSelected: (_) => notifier.setTypeFilter(type),
              ),
            );
          }),
        ],
      ),
    );
  }
}