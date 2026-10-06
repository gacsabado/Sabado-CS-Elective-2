import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonService {
  static const String apiUrl =
      'https://pokeapi.co/api/v2/pokemon?limit=30';

  Future<List<Pokemon>> fetchPokemon() async {
    final response = await http.get(
      Uri.parse(apiUrl),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load Pokémon: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    final List<dynamic> results = data['results'] ?? [];

    final basicPokemon = results
        .map(
          (item) => Pokemon.fromListJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    final detailedPokemon = await Future.wait(
      basicPokemon.map(
        (pokemon) => _fetchPokemonDetails(pokemon.id),
      ),
    );

    return detailedPokemon;
  }

  Future<Pokemon> _fetchPokemonDetails(int id) async {
    final response = await http.get(
      Uri.parse(
        'https://pokeapi.co/api/v2/pokemon/$id',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load Pokémon #$id',
      );
    }

    final data = jsonDecode(response.body);

    return Pokemon.fromDetailJson(
      data as Map<String, dynamic>,
    );
  }
}