import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import 'pokemon_card.dart';

class PokemonGrid extends StatelessWidget {
  final List<Pokemon> pokemon;

  const PokemonGrid({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: pokemon.length,
      itemBuilder: (context, index) {
        return PokemonCard(
          pokemon: pokemon[index],
        );
      },
    );
  }
}