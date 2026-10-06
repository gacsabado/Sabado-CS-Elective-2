class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;

    final id = int.parse(
      url.split('/').where((part) => part.isNotEmpty).last,
    );

    return Pokemon(
      id: id,
      name: _capitalize(json['name']),
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
    );
  }

  static String _capitalize(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }
}