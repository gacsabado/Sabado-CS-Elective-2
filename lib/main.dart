import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/pokemon_provider.dart';
import 'screens/pokedex_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PokemonProvider(),
      child: const PokemonApp(),
    ),
  );
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PokemonProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokédex',

      themeMode: provider.isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEF5350),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111318),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEF5350),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      home: const PokedexScreen(),
    );
  }
}