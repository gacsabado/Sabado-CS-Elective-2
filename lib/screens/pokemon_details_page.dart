import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';

class PokemonDetailsPage extends ConsumerStatefulWidget {
  final int pokemonId;

  const PokemonDetailsPage({
    super.key,
    required this.pokemonId,
  });

  @override
  ConsumerState<PokemonDetailsPage> createState() =>
      _PokemonDetailsPageState();
}

class _PokemonDetailsPageState extends ConsumerState<PokemonDetailsPage> {
  late TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

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
    final state = ref.watch(pokemonProvider);
    final notifier = ref.read(pokemonProvider.notifier);

    final pokemonList = state.pokemonList;
    final matching = pokemonList.where((p) => p.id == widget.pokemonId);
    final Pokemon? pokemon = matching.isNotEmpty ? matching.first : null;

    if (pokemon == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Pokémon not found',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      );
    }

    final bool isDark = state.isDarkMode;
    final bool isFav = notifier.isFavorite(pokemon.id);
    final String primaryType =
        pokemon.types.isNotEmpty ? pokemon.types.first : 'Normal';
    final Color typeColor = getTypeColor(primaryType);

    final Color background =
        isDark ? const Color(0xFF080B12) : const Color(0xFFF3F5FA);
    final Color cardColor =
        isDark ? const Color(0xFF151923) : Colors.white;
    final Color textColor =
        isDark ? Colors.white : const Color(0xFF171A21);
    final Color mutedText =
        isDark ? Colors.white54 : Colors.black45;

    if (_nicknameController.text.isEmpty && pokemon.nickname != null) {
      _nicknameController.text = pokemon.nickname!;
    }

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 15, 18, 0),
                    child: Row(
                      children: [
                        _RoundButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                          isDark: isDark,
                        ),
                        const Spacer(),

                        // FAVORITE HEART TOGGLE
                        _RoundButton(
                          icon: isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          iconColor: isFav
                              ? const Color(0xFFEF5350)
                              : null,
                          onTap: () {
                            notifier.toggleFavorite(pokemon.id);
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),

                        // ID BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '#${pokemon.id.toString().padLeft(3, '0')}',
                            style: TextStyle(
                              color: typeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // POKÉMON IMAGE CONTAINER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
                    child: Container(
                      height: 380,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(38),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            typeColor.withValues(
                              alpha: isDark ? 0.30 : 0.20,
                            ),
                            cardColor,
                          ],
                        ),
                        border: Border.all(
                          color: typeColor.withValues(
                            alpha: isDark ? 0.25 : 0.12,
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Image.network(
                              pokemon.imageUrl,
                              width: 280,
                              height: 280,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // NAME & NICKNAME DISPLAY
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      children: [
                        Text(
                          pokemon.nickname ?? pokemon.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            color: textColor,
                          ),
                        ),
                        if (pokemon.nickname != null)
                          Text(
                            'Original Name: ${pokemon.name}',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: mutedText,
                            ),
                          ),
                        const SizedBox(height: 5),
                        Text(
                          'POKÉMON #${pokemon.id.toString().padLeft(3, '0')}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // NICKNAME EDITOR SECTION
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 24, 18, 30),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: typeColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Custom Nickname Editor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _nicknameController,
                            decoration: InputDecoration(
                              hintText: 'Enter nickname...',
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF080B12)
                                  : const Color(0xFFF3F5FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    notifier.setNickname(
                                      pokemon.id,
                                      _nicknameController.text,
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Nickname saved!',
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFEF5350),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.save_rounded),
                                  label: const Text('Save'),
                                ),
                              ),
                              if (pokemon.nickname != null) ...[
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    notifier.removeNickname(pokemon.id);
                                    _nicknameController.clear();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Nickname removed!',
                                        ),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.delete_rounded),
                                  label: const Text('Remove'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
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

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final bool isDark;

  const _RoundButton({
    required this.icon,
    this.iconColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(
            icon,
            color: iconColor,
            size: 21,
          ),
        ),
      ),
    );
  }
}