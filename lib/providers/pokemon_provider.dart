import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

enum PokemonStatus {
  idle,
  loading,
  success,
  error,
}

class PokemonState {
  final List<Pokemon> rawPokemonList;
  final PokemonStatus status;
  final String? errorMessage;
  final Map<int, String> nicknames;
  final Set<int> favoriteIds;
  final String? selectedType;
  final bool isDarkMode;
  final bool isFavoritesPanelOpen;

  PokemonState({
    this.rawPokemonList = const [],
    this.status = PokemonStatus.idle,
    this.errorMessage,
    this.nicknames = const {},
    this.favoriteIds = const {},
    this.selectedType,
    this.isDarkMode = false,
    this.isFavoritesPanelOpen = false,
  });

  PokemonState copyWith({
    List<Pokemon>? rawPokemonList,
    PokemonStatus? status,
    String? errorMessage,
    Map<int, String>? nicknames,
    Set<int>? favoriteIds,
    String? selectedType,
    bool clearSelectedType = false,
    bool? isDarkMode,
    bool? isFavoritesPanelOpen,
  }) {
    return PokemonState(
      rawPokemonList: rawPokemonList ?? this.rawPokemonList,
      status: status ?? this.status,
      errorMessage: errorMessage,
      nicknames: nicknames ?? this.nicknames,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      selectedType: clearSelectedType
          ? null
          : (selectedType ?? this.selectedType),
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isFavoritesPanelOpen:
          isFavoritesPanelOpen ?? this.isFavoritesPanelOpen,
    );
  }

  /// Returns Pokémon enriched with custom nicknames
  List<Pokemon> get pokemonList {
    return rawPokemonList.map((p) {
      return p.copyWith(
        nickname: nicknames[p.id],
      );
    }).toList();
  }

  /// Returns Pokémon filtered by selected type
  List<Pokemon> get filteredPokemon {
    final list = pokemonList;
    if (selectedType == null || selectedType!.isEmpty) {
      return list;
    }
    return list.where((p) {
      return p.types.any(
        (t) => t.toLowerCase() == selectedType!.toLowerCase(),
      );
    }).toList();
  }

  /// Returns favorited Pokémon list
  List<Pokemon> get favoritePokemon {
    return pokemonList
        .where((p) => favoriteIds.contains(p.id))
        .toList();
  }
}

class PokemonNotifier extends Notifier<PokemonState> {
  final PokemonService _pokemonService = PokemonService();

  @override
  PokemonState build() {
    return PokemonState();
  }

  // =========================
  // API & REFRESH LOGIC
  // =========================

  Future<void> fetchPokemon() async {
    state = state.copyWith(
      status: PokemonStatus.loading,
      errorMessage: null,
    );

    try {
      final result = await _pokemonService.fetchPokemon();
      state = state.copyWith(
        rawPokemonList: result.take(30).toList(),
        status: PokemonStatus.success,
      );
    } catch (error) {
      state = state.copyWith(
        status: PokemonStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshPokemon() async {
    await fetchPokemon();
  }

  // =========================
  // NICKNAME EDITOR
  // =========================

  void setNickname(int pokemonId, String nickname) {
    final updated = Map<int, String>.from(state.nicknames);
    if (nickname.trim().isEmpty) {
      updated.remove(pokemonId);
    } else {
      updated[pokemonId] = nickname.trim();
    }
    state = state.copyWith(nicknames: updated);
  }

  void removeNickname(int pokemonId) {
    final updated = Map<int, String>.from(state.nicknames);
    updated.remove(pokemonId);
    state = state.copyWith(nicknames: updated);
  }

  // =========================
  // FAVORITES MANAGEMENT
  // =========================

  void toggleFavorite(int pokemonId) {
    final updated = Set<int>.from(state.favoriteIds);
    if (updated.contains(pokemonId)) {
      updated.remove(pokemonId);
    } else {
      updated.add(pokemonId);
    }
    state = state.copyWith(favoriteIds: updated);
  }

  bool isFavorite(int pokemonId) {
    return state.favoriteIds.contains(pokemonId);
  }

  // =========================
  // TYPE FILTERING
  // =========================

  void setTypeFilter(String? type) {
    if (state.selectedType == type) {
      state = state.copyWith(clearSelectedType: true);
    } else {
      state = state.copyWith(selectedType: type);
    }
  }

  void clearTypeFilter() {
    state = state.copyWith(clearSelectedType: true);
  }

  // =========================
  // UI & THEME TOGGLES
  // =========================

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void toggleFavoritesPanel() {
    state =
        state.copyWith(isFavoritesPanelOpen: !state.isFavoritesPanelOpen);
  }
}

final pokemonProvider =
    NotifierProvider<PokemonNotifier, PokemonState>(() {
  return PokemonNotifier();
});