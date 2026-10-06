import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_details_page.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({
    super.key,
  });

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PokemonProvider>().fetchPokemon();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PokemonProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFEF5350),
          onRefresh: provider.refreshPokemon,

          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            slivers: [

              // ==========================================
              // HEADER
              // ==========================================

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    20,
                  ),

                  child: Row(
                    children: [

                      Container(
                        width: 56,
                        height: 56,

                        decoration: BoxDecoration(
                          color: const Color(0xFFEF5350),
                          borderRadius:
                              BorderRadius.circular(18),

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
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

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

                      // REFRESH
                      IconButton(
                        tooltip: 'Refresh Pokémon',

                        onPressed:
                            provider.status ==
                                    PokemonStatus.loading
                                ? null
                                : provider.refreshPokemon,

                        icon: const Icon(
                          Icons.refresh_rounded,
                        ),
                      ),

                      // THEME
                      IconButton(
                        tooltip: provider.isDarkMode
                            ? 'Light mode'
                            : 'Dark mode',

                        onPressed:
                            provider.toggleTheme,

                        icon: Icon(
                          provider.isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,

                          color: provider.isDarkMode
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFF5C6BC0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // SECTION HEADER
              // ==========================================

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    16,
                  ),

                  child: Row(
                    children: [

                      Text(
                        'Pokémon',

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface,
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: const Color(0xFFEF5350)
                              .withValues(alpha: 0.1),

                          borderRadius:
                              BorderRadius.circular(20),
                        ),

                        child: Text(
                          '${provider.pokemonCount} Pokémon',

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
              // LOADING
              // ==========================================

              if (provider.status ==
                  PokemonStatus.loading)

                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFEF5350),
                    ),
                  ),
                )

              // ==========================================
              // ERROR
              // ==========================================

              else if (provider.status ==
                  PokemonStatus.error)

                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(30),

                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

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
                              fontWeight:
                                  FontWeight.w800,

                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
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
                            onPressed:
                                provider.fetchPokemon,

                            child: const Text(
                              'Try Again',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )

              // ==========================================
              // EMPTY
              // ==========================================

              else if (provider.pokemon.isEmpty)

                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

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
                            fontWeight:
                                FontWeight.w800,

                            color: Theme.of(context)
                                .colorScheme
                                .onSurface,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'There are no Pokémon to display right now.',

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
                          onPressed:
                              provider.fetchPokemon,

                          child: const Text(
                            'Try Again',
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // ==========================================
              // SUCCESS / GRID
              // ==========================================

              else

                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    30,
                  ),

                  sliver: SliverGrid(
                    delegate:
                        SliverChildBuilderDelegate(
                      (context, index) {
                        final pokemon =
                            provider.pokemon[index];

                        return PokemonCard(
                          pokemon: pokemon,
                          isDarkMode: provider.isDarkMode,
                          // CLICK POKEMON
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PokemonDetailsPage(
                                  pokemonId:
                                      pokemon.id,
                                ),
                              ),
                            );
                          },
                        );
                      },

                      childCount:
                          provider.pokemon.length,
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