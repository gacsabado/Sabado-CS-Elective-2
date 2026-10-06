import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import 'pokemon_card.dart';

class PokemonGrid extends StatelessWidget {
  final List<Pokemon> pokemon;
  final bool isDarkMode;

  const PokemonGrid({
    super.key,
    required this.pokemon,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        30,
      ),
      itemCount: pokemon.length,
      gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.72,
    ),
      itemBuilder: (context, index) {
        return PokemonCard(
          pokemon: pokemon[index],
          isDarkMode: isDarkMode,
        );
      },
    );
  }
}