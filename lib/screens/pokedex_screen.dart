import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pokemon_provider.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/type_filter_bar.dart';
import 'pokemon_details_page.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pokemonProvider.notifier).fetchPokemon();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pokemonProvider);
    final notifier = ref.read(pokemonProvider.notifier);
    final filteredList = state.filteredPokemon;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFEF5350),
          onRefresh: notifier.refreshPokemon,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ==========================================
              // HEADER
              // ==========================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF5350),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF5350)
                                  .withValues(alpha: 0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.catching_pokemon,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pokédex',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Explore the Pokémon world',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // FAVORITES TOGGLE
                      IconButton(
                        tooltip: 'Favorites Panel',
                        onPressed: notifier.toggleFavoritesPanel,
                        icon: Icon(
                          state.isFavoritesPanelOpen
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: const Color(0xFFEF5350),
                        ),
                      ),

                      // REFRESH BUTTON (Recalls existing fetch method)
                      IconButton(
                        tooltip: 'Refresh Pokémon',
                        onPressed: state.status == PokemonStatus.loading
                            ? null
                            : notifier.refreshPokemon,
                        icon: const Icon(Icons.refresh_rounded),
                      ),

                      // THEME TOGGLE
                      IconButton(
                        tooltip: state.isDarkMode
                            ? 'Light mode'
                            : 'Dark mode',
                        onPressed: notifier.toggleTheme,
                        icon: Icon(
                          state.isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: state.isDarkMode
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFF5C6BC0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // RETRACTABLE FAVORITES PANEL
              // ==========================================
              const SliverToBoxAdapter(
                child: FavoritesPanel(),
              ),

              // ==========================================
              // TYPE FILTER BAR
              // ==========================================
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: TypeFilterBar(),
                ),
              ),

              // ==========================================
              // SECTION HEADER
              // ==========================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      Text(
                        state.selectedType != null
                            ? '${state.selectedType} Pokémon'
                            : 'Pokémon',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF5350)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${filteredList.length} Pokémon',
                          style: const TextStyle(
                            color: Color(0xFFEF5350),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // LOADING STATE
              // ==========================================
              if (state.status == PokemonStatus.loading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFEF5350),
                    ),
                  ),
                )

              // ==========================================
              // ERROR STATE
              // ==========================================
              else if (state.status == PokemonStatus.error)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 65,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.25),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oops!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.errorMessage ??
                                'We could not load the Pokémon.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: notifier.fetchPokemon,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )

              // ==========================================
              // EMPTY STATE
              // ==========================================
              else if (filteredList.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.catching_pokemon,
                          size: 75,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.25),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Pokémon found',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color:
                                Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.selectedType != null
                              ? 'No Pokémon found matching "${state.selectedType}".'
                              : 'There are no Pokémon to display right now.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (state.selectedType != null)
                          ElevatedButton(
                            onPressed: notifier.clearTypeFilter,
                            child: const Text('Clear Type Filter'),
                          )
                        else
                          ElevatedButton(
                            onPressed: notifier.fetchPokemon,
                            child: const Text('Try Again'),
                          ),
                      ],
                    ),
                  ),
                )

              // ==========================================
              // SUCCESS / GRID STATE
              // ==========================================
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final pokemon = filteredList[index];

                        return PokemonCard(
                          pokemon: pokemon,
                          isDarkMode: state.isDarkMode,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PokemonDetailsPage(
                                  pokemonId: pokemon.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredList.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}