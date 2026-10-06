class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  factory Pokemon.fromListJson(Map<String, dynamic> json) {
    final url = json['url'] as String;

    final id = int.parse(
      url.split('/').where((part) => part.isNotEmpty).last,
    );

    return Pokemon(
      id: id,
      name: _capitalize(json['name'] as String),
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      types: const [],
    );
  }

  factory Pokemon.fromDetailJson(Map<String, dynamic> json) {
    final rawTypes = json['types'];

    final List<String> types = rawTypes is List
        ? rawTypes
            .map<String>(
              (type) => _capitalize(
                type['type']['name'] as String,
              ),
            )
            .toList()
        : [];

    return Pokemon(
      id: json['id'] as int,
      name: _capitalize(json['name'] as String),
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${json['id']}.png',
      types: types,
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }
}