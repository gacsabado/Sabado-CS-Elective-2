import 'package:flutter/material.dart';

import '../models/pokemon.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final bool isDarkMode;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.isDarkMode,
  });

  Color _getCardColor() {
    if (pokemon.types.isEmpty) {
      return isDarkMode
          ? const Color(0xFF252830)
          : const Color(0xFFE8F5E9);
    }

    switch (pokemon.types.first.toLowerCase()) {
      case 'fire':
        return isDarkMode
            ? const Color(0xFF42221C)
            : const Color(0xFFFFE4DC);

      case 'water':
        return isDarkMode
            ? const Color(0xFF192F46)
            : const Color(0xFFE0F2FF);

      case 'grass':
        return isDarkMode
            ? const Color(0xFF1D3825)
            : const Color(0xFFE4F5E7);

      case 'electric':
        return isDarkMode
            ? const Color(0xFF403717)
            : const Color(0xFFFFF4C7);

      case 'psychic':
        return isDarkMode
            ? const Color(0xFF402333)
            : const Color(0xFFFFE4EF);

      case 'ice':
        return isDarkMode
            ? const Color(0xFF1C3740)
            : const Color(0xFFE1F7FA);

      case 'poison':
        return isDarkMode
            ? const Color(0xFF342044)
            : const Color(0xFFF0E1FA);

      case 'ground':
        return isDarkMode
            ? const Color(0xFF3D321F)
            : const Color(0xFFF5E8C8);

      case 'rock':
        return isDarkMode
            ? const Color(0xFF363329)
            : const Color(0xFFEDE8D9);

      case 'ghost':
        return isDarkMode
            ? const Color(0xFF29223C)
            : const Color(0xFFE9E2FA);

      case 'dragon':
        return isDarkMode
            ? const Color(0xFF202B4C)
            : const Color(0xFFE2E8FF);

      default:
        return isDarkMode
            ? const Color(0xFF252830)
            : const Color(0xFFE8F5E9);
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFE85D3F);

      case 'water':
        return const Color(0xFF4D8FE7);

      case 'grass':
        return const Color(0xFF62B56B);

      case 'electric':
        return const Color(0xFFE8B92E);

      case 'psychic':
        return const Color(0xFFD85C87);

      case 'ice':
        return const Color(0xFF55B8C7);

      case 'poison':
        return const Color(0xFF9654B5);

      case 'ground':
        return const Color(0xFFB38A4C);

      case 'rock':
        return const Color(0xFF8B7D5A);

      case 'ghost':
        return const Color(0xFF7056A3);

      case 'dragon':
        return const Color(0xFF5369C5);

      case 'flying':
        return const Color(0xFF7F8FD0);

      case 'bug':
        return const Color(0xFF82A83D);

      case 'normal':
        return const Color(0xFF999999);

      case 'fighting':
        return const Color(0xFFB54A3E);

      case 'steel':
        return const Color(0xFF71829B);

      case 'dark':
        return const Color(0xFF55505A);

      case 'fairy':
        return const Color(0xFFD88BB2);

      default:
        return const Color(0xFF888888);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department;

      case 'water':
        return Icons.water_drop;

      case 'grass':
        return Icons.eco;

      case 'electric':
        return Icons.bolt;

      case 'ice':
        return Icons.ac_unit;

      case 'poison':
        return Icons.science;

      case 'psychic':
        return Icons.auto_awesome;

      case 'ground':
        return Icons.landscape;

      case 'rock':
        return Icons.terrain;

      case 'ghost':
        return Icons.nightlight;

      case 'dragon':
        return Icons.auto_awesome;

      case 'flying':
        return Icons.air;

      case 'bug':
        return Icons.bug_report;

      case 'steel':
        return Icons.shield;

      case 'dark':
        return Icons.dark_mode;

      case 'fairy':
        return Icons.auto_awesome;

      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDarkMode ? Colors.white : const Color(0xFF202124);

    final idColor =
        isDarkMode ? Colors.white54 : Colors.black45;

    return Container(
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDarkMode ? 0.25 : 0.06,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [

            // Large decorative circle
            Positioned(
              right: -35,
              top: -35,
              child: Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: isDarkMode ? 0.06 : 0.45,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Small decorative circle
            Positioned(
              right: 25,
              top: 75,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: isDarkMode ? 0.07 : 0.3,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Decorative Pokéball
            Positioned(
              right: 18,
              top: 18,
              child: Opacity(
                opacity: 0.13,
                child: Icon(
                  Icons.catching_pokemon,
                  size: 78,
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // ID
                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: idColor,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Name
                  Text(
                    pokemon.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Type badges
                  if (pokemon.types.isNotEmpty)
                    Row(
                      children: pokemon.types
                          .map(
                            (type) => Padding(
                              padding:
                                  const EdgeInsets.only(
                                right: 5,
                              ),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(type),
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getTypeIcon(type),
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      type,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                  // Pokémon image
                  Expanded(
                    child: Center(
                      child: Image.network(
                        pokemon.imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder:
                            (context, child, progress) {
                          if (progress == null) {
                            return child;
                          }

                          return const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFEF5350),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) {
                          return Icon(
                            Icons
                                .image_not_supported_outlined,
                            size: 45,
                            color: isDarkMode
                                ? Colors.white24
                                : Colors.black26,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}