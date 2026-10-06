import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';

class PokemonDetailsPage extends StatelessWidget {
  final int pokemonId;

  const PokemonDetailsPage({
    super.key,
    required this.pokemonId,
  });

  // ==========================================================
  // TYPE COLORS
  // ==========================================================

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFFF7043);
      case 'water':
        return const Color(0xFF42A5F5);
      case 'grass':
        return const Color(0xFF66BB6A);
      case 'electric':
        return const Color(0xFFFFC107);
      case 'psychic':
        return const Color(0xFFEC407A);
      case 'ice':
        return const Color(0xFF26C6DA);
      case 'poison':
        return const Color(0xFFAB47BC);
      case 'ground':
        return const Color(0xFFB8864A);
      case 'rock':
        return const Color(0xFF8D7B55);
      case 'ghost':
        return const Color(0xFF7E57C2);
      case 'dragon':
        return const Color(0xFF5C6BC0);
      case 'flying':
        return const Color(0xFF7986CB);
      case 'bug':
        return const Color(0xFF8BC34A);
      case 'normal':
        return const Color(0xFF9E9E9E);
      case 'fighting':
        return const Color(0xFFD84335);
      case 'steel':
        return const Color(0xFF78909C);
      case 'dark':
        return const Color(0xFF5D5360);
      case 'fairy':
        return const Color(0xFFEC8FB0);
      default:
        return const Color(0xFF90A4AE);
    }
  }

  IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'grass':
        return Icons.eco_rounded;
      case 'electric':
        return Icons.bolt_rounded;
      case 'psychic':
        return Icons.auto_awesome_rounded;
      case 'ice':
        return Icons.ac_unit_rounded;
      case 'poison':
        return Icons.science_rounded;
      case 'ground':
        return Icons.landscape_rounded;
      case 'rock':
        return Icons.terrain_rounded;
      case 'ghost':
        return Icons.nightlight_round;
      case 'dragon':
        return Icons.auto_awesome_rounded;
      case 'flying':
        return Icons.air_rounded;
      case 'bug':
        return Icons.bug_report_rounded;
      case 'steel':
        return Icons.shield_rounded;
      case 'dark':
        return Icons.dark_mode_rounded;
      case 'fairy':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PokemonProvider>();

    final pokemon = provider.getPokemonById(pokemonId);

    if (pokemon == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Pokémon not found',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface,
            ),
          ),
        ),
      );
    }

    final bool isDark = provider.isDarkMode;

    final String primaryType =
        pokemon.types.isNotEmpty
            ? pokemon.types.first
            : 'Normal';

    final Color typeColor =
        getTypeColor(primaryType);

    final Color background = isDark
        ? const Color(0xFF080B12)
        : const Color(0xFFF3F5FA);

    final Color cardColor = isDark
        ? const Color(0xFF151923)
        : Colors.white;

    final Color textColor = isDark
        ? Colors.white
        : const Color(0xFF171A21);

    final Color mutedText = isDark
        ? Colors.white54
        : Colors.black45;

    return Scaffold(
      backgroundColor: background,

      body: Stack(
        children: [

          // ==================================================
          // BACKGROUND POKÉBALL PATTERN
          // ==================================================

          Positioned(
            top: -100,
            right: -90,
            child: _BackgroundPokeball(
              color: typeColor,
              size: 330,
              opacity: isDark ? 0.08 : 0.07,
            ),
          ),

          Positioned(
            bottom: 100,
            left: -160,
            child: _BackgroundPokeball(
              color: typeColor,
              size: 350,
              opacity: isDark ? 0.05 : 0.04,
            ),
          ),

          // ==================================================
          // MAIN CONTENT
          // ==================================================

          SafeArea(
            child: CustomScrollView(
              physics:
                  const BouncingScrollPhysics(),

              slivers: [

                // ==================================================
                // APP BAR
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      18,
                      15,
                      18,
                      0,
                    ),

                    child: Row(
                      children: [

                        _RoundButton(
                          icon:
                              Icons.arrow_back_rounded,

                          onTap: () {
                            Navigator.pop(context);
                          },

                          isDark: isDark,
                        ),

                        const Spacer(),

                        // POKÉDEX BRAND
                        Row(
                          children: [

                            Icon(
                              Icons.catching_pokemon,
                              color: typeColor,
                              size: 22,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              'POKÉDEX',

                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: 2,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // ID BADGE
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color:
                                typeColor.withValues(
                              alpha: 0.13,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),

                          child: Text(
                            '#${pokemon.id.toString().padLeft(3, '0')}',

                            style: TextStyle(
                              color: typeColor,
                              fontWeight:
                                  FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // HERO SECTION
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      18,
                      22,
                      18,
                      0,
                    ),

                    child: Container(
                      height: 420,

                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(38),

                        gradient: LinearGradient(
                          begin:
                              Alignment.topLeft,
                          end:
                              Alignment.bottomRight,

                          colors: [
                            typeColor.withValues(
                              alpha: isDark
                                  ? 0.30
                                  : 0.20,
                            ),

                            typeColor.withValues(
                              alpha: isDark
                                  ? 0.10
                                  : 0.06,
                            ),

                            cardColor,
                          ],
                        ),

                        border: Border.all(
                          color:
                              typeColor.withValues(
                            alpha:
                                isDark ? 0.25 : 0.12,
                          ),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color:
                                typeColor.withValues(
                              alpha: isDark
                                  ? 0.12
                                  : 0.08,
                            ),
                            blurRadius: 35,
                            offset:
                                const Offset(0, 18),
                          ),
                        ],
                      ),

                      child: Stack(
                        children: [

                          // TOP DECORATION
                          Positioned(
                            top: -80,
                            right: -60,

                            child:
                                _BackgroundPokeball(
                              color: typeColor,
                              size: 250,
                              opacity: 0.10,
                            ),
                          ),

                          // SMALL DOTS
                          Positioned(
                            top: 40,
                            left: 35,

                            child: _Dot(
                              color: typeColor,
                              size: 10,
                            ),
                          ),

                          Positioned(
                            top: 70,
                            left: 60,

                            child: _Dot(
                              color: typeColor,
                              size: 5,
                            ),
                          ),

                          Positioned(
                            top: 105,
                            right: 70,

                            child: _Dot(
                              color: typeColor,
                              size: 7,
                            ),
                          ),

                          // ==================================================
                          // IMAGE
                          // ==================================================

                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom: 35,
                              ),

                              child: Image.network(
                                pokemon.imageUrl,

                                width: 300,
                                height: 300,

                                fit: BoxFit.contain,

                                errorBuilder:
                                    (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                  return Icon(
                                    Icons
                                        .image_not_supported_rounded,
                                    size: 90,
                                    color:
                                        typeColor,
                                  );
                                },
                              ),
                            ),
                          ),

                          // ==================================================
                          // TYPE BADGES
                          // ==================================================

                          Positioned(
                            bottom: 22,
                            left: 0,
                            right: 0,

                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,

                              children:
                                  pokemon.types
                                      .map(
                                        (type) =>
                                            _TypeBadge(
                                          type: type,
                                          color:
                                              getTypeColor(
                                            type,
                                          ),
                                          icon:
                                              getTypeIcon(
                                            type,
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // NAME
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      27,
                      20,
                      0,
                    ),

                    child: Column(
                      children: [

                        Text(
                          pokemon.name,

                          textAlign:
                              TextAlign.center,

                          style: TextStyle(
                            fontSize: 40,
                            fontWeight:
                                FontWeight.w900,
                            letterSpacing: -1.5,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [

                            Container(
                              width: 7,
                              height: 7,

                              decoration:
                                  BoxDecoration(
                                color: typeColor,
                                shape:
                                    BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 7),

                            Text(
                              'POKÉMON #${pokemon.id.toString().padLeft(3, '0')}',

                              style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w800,
                                letterSpacing: 1.3,
                                color: mutedText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // INFORMATION SECTION
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      18,
                      30,
                      18,
                      40,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          'Pokémon Info',

                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.w900,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Basic information from your Pokédex.',

                          style: TextStyle(
                            fontSize: 13,
                            color: mutedText,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // INFO GRID
                        Row(
                          children: [

                            Expanded(
                              child: _InfoCard(
                                icon:
                                    Icons.tag_rounded,
                                title:
                                    'POKÉDEX ID',
                                value:
                                    '#${pokemon.id.toString().padLeft(3, '0')}',
                                color:
                                    typeColor,
                                isDark:
                                    isDark,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: _InfoCard(
                                icon: Icons
                                    .catching_pokemon_rounded,
                                title: 'NAME',
                                value:
                                    pokemon.name,
                                color:
                                    typeColor,
                                isDark:
                                    isDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // TYPE CARD
                        _LargeInfoCard(
                          icon:
                              Icons.category_rounded,

                          title: 'TYPE',

                          child: Row(
                            children:
                                pokemon.types
                                    .map(
                                      (type) =>
                                          _TypeBadge(
                                        type: type,
                                        color:
                                            getTypeColor(
                                          type,
                                        ),
                                        icon:
                                            getTypeIcon(
                                          type,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),

                          color: typeColor,

                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// BACKGROUND POKÉBALL
// ==========================================================

class _BackgroundPokeball
    extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _BackgroundPokeball({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,

      child: Container(
        width: size,
        height: size,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          border: Border.all(
            color: color,
            width: size * 0.035,
          ),
        ),

        child: Center(
          child: Container(
            width: size * 0.20,
            height: size * 0.20,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,

              border: Border.all(
                color: color,
                width: size * 0.025,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// DOT
// ==========================================================

class _Dot extends StatelessWidget {
  final Color color;
  final double size;

  const _Dot({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,

      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.35,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ==========================================================
// ROUND BUTTON
// ==========================================================

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _RoundButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? Colors.white.withValues(
              alpha: 0.08,
            )
          : Colors.white,

      borderRadius:
          BorderRadius.circular(16),

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(16),

        child: Padding(
          padding:
              const EdgeInsets.all(11),

          child: Icon(
            icon,
            size: 21,
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// TYPE BADGE
// ==========================================================

class _TypeBadge extends StatelessWidget {
  final String type;
  final Color color;
  final IconData icon;

  const _TypeBadge({
    required this.type,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(right: 7),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(30),

        boxShadow: [
          BoxShadow(
            color: color.withValues(
              alpha: 0.25,
            ),
            blurRadius: 8,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [

          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),

          const SizedBox(width: 5),

          Text(
            type.toUpperCase(),

            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// SMALL INFO CARD
// ==========================================================

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isDark;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF151923)
            : Colors.white,

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: color.withValues(
            alpha: 0.10,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.12,
              ),

              borderRadius:
                  BorderRadius.circular(13),
            ),

            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            title,

            style: TextStyle(
              fontSize: 9,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: 1,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(
                    alpha: 0.45,
                  ),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,

            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,

            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w900,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// LARGE INFO CARD
// ==========================================================

class _LargeInfoCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Color color;
  final bool isDark;

  const _LargeInfoCard({
    required this.icon,
    required this.title,
    required this.child,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF151923)
            : Colors.white,

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: color.withValues(
            alpha: 0.10,
          ),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.12,
              ),

              borderRadius:
                  BorderRadius.circular(13),
            ),

            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 13),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                title,

                style: TextStyle(
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(
                        alpha: 0.45,
                      ),
                ),
              ),

              const SizedBox(height: 7),

              child,
            ],
          ),
        ],
      ),
    );
  }
}