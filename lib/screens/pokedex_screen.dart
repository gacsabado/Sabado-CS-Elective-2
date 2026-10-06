import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';

class PokedexScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const PokedexScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final PokemonService _pokemonService = PokemonService();

  late Future<List<Pokemon>> _pokemonFuture;

  @override
  void initState() {
    super.initState();
    _pokemonFuture = _pokemonService.fetchPokemon();
  }

  Future<void> _refreshPokemon() async {
    setState(() {
      _pokemonFuture = _pokemonService.fetchPokemon();
    });

    await _pokemonFuture;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final backgroundColor = isDark
        ? const Color(0xFF111318)
        : const Color(0xFFF7F8FC);

    final primaryText = isDark
        ? Colors.white
        : const Color(0xFF202124);

    final secondaryText = isDark
        ? Colors.white60
        : Colors.black54;

    final iconBackground = isDark
        ? const Color(0xFF1D2027)
        : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFEF5350),
          onRefresh: _refreshPokemon,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [

              // =========================
              // HEADER
              // =========================
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

                      // Pokéball icon
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

                      // Title
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
                                color: primaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Explore the Pokémon world',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Dark / Light mode
                      Material(
                        color: iconBackground,
                        borderRadius:
                            BorderRadius.circular(15),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(15),
                          onTap: widget.onThemeToggle,
                          child: Padding(
                            padding: const EdgeInsets.all(11),
                            child: Icon(
                              isDark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              color: isDark
                                  ? const Color(0xFFFFD54F)
                                  : const Color(0xFF5C6BC0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =========================
              // SECTION TITLE
              // =========================
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
                          color: primaryText,
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
                              .withValues(
                            alpha: isDark ? 0.18 : 0.1,
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '30 Pokémon',
                          style: TextStyle(
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

              // =========================
              // FUTURE BUILDER
              // =========================
              FutureBuilder<List<Pokemon>>(
                future: _pokemonFuture,
                builder: (context, snapshot) {

                  // =========================
                  // LOADING STATE
                  // =========================
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFEF5350),
                        ),
                      ),
                    );
                  }

                  // =========================
                  // ERROR STATE
                  // =========================
                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [

                              Icon(
                                Icons.cloud_off_rounded,
                                size: 65,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.black26,
                              ),

                              const SizedBox(height: 16),

                              Text(
                                'Oops!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: primaryText,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'We could not load the Pokémon.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: secondaryText,
                                ),
                              ),

                              const SizedBox(height: 20),

                              ElevatedButton(
                                onPressed: _refreshPokemon,
                                child: const Text(
                                  'Try Again',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  // Get data
                  final pokemon = snapshot.data ?? [];

                  // =========================
                  // EMPTY STATE
                  // =========================
                  if (pokemon.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [

                              Icon(
                                Icons.catching_pokemon,
                                size: 75,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.black26,
                              ),

                              const SizedBox(height: 16),

                              Text(
                                'No Pokémon found',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: primaryText,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'There are no Pokémon to display right now.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryText,
                                ),
                              ),

                              const SizedBox(height: 20),

                              ElevatedButton(
                                onPressed: _refreshPokemon,
                                child: const Text(
                                  'Try Again',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  // =========================
                  // SUCCESS STATE
                  // =========================
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      30,
                    ),
                    sliver: SliverGrid(
                      delegate:
                          SliverChildBuilderDelegate(
                        (context, index) {
                          return PokemonCard(
                            pokemon: pokemon[index],
                            isDarkMode: isDark,
                          );
                        },
                        childCount: pokemon.length,
                      ),

                      // 3 COLUMNS
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}