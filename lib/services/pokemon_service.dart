import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonService {
  static const String apiUrl =
      'https://pokeapi.co/api/v2/pokemon?limit=30';

  Future<List<Pokemon>> fetchPokemon() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load Pokémon');
    }

    final data = jsonDecode(response.body);

    final List results = data['results'];

    return results
        .map((pokemon) => Pokemon.fromJson(pokemon))
        .toList();
  }
}