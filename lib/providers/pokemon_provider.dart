import 'package:flutter/foundation.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

enum PokemonStatus {
  idle,
  loading,
  success,
  error,
}

class PokemonProvider extends ChangeNotifier {
  final PokemonService _pokemonService = PokemonService();

  List<Pokemon> _pokemon = [];

  PokemonStatus _status = PokemonStatus.idle;

  String? _errorMessage;

  bool _isDarkMode = false;

  // =========================
  // GETTERS
  // =========================

  List<Pokemon> get pokemon => _pokemon;

  PokemonStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isDarkMode => _isDarkMode;

  int get pokemonCount => _pokemon.length;

  // =========================
  // API CALL
  // =========================

  Future<void> fetchPokemon() async {
    _status = PokemonStatus.loading;
    _errorMessage = null;

    notifyListeners();

    try {
      final result = await _pokemonService.fetchPokemon();

      // Make sure we only display 30 Pokémon.
      _pokemon = result.take(30).toList();

      if (_pokemon.isEmpty) {
        _status = PokemonStatus.success;
      } else {
        _status = PokemonStatus.success;
      }
    } catch (error) {
      _status = PokemonStatus.error;
      _errorMessage = error.toString();
    }

    notifyListeners();
  }

  // =========================
  // REFRESH
  // =========================

  Future<void> refreshPokemon() async {
    await fetchPokemon();
  }

  // =========================
  // THEME
  // =========================

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;

    notifyListeners();
  }

  // =========================
  // GET POKEMON BY ID
  // =========================

  Pokemon? getPokemonById(int id) {
    for (final pokemon in _pokemon) {
      if (pokemon.id == id) {
        return pokemon;
      }
    }

    return null;
  }
}