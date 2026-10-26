/// Model ringkas Pokémon dari endpoint daftar: /pokemon?limit=151
class PokemonSummary {
  final int id;
  final String name;
  final String imageUrl;

  const PokemonSummary({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory PokemonSummary.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    // Contoh url: https://pokeapi.co/api/v2/pokemon/25/
    final segments = url.split('/').where((s) => s.isNotEmpty).toList();
    final id = int.parse(segments.last);

    return PokemonSummary(
      id: id,
      name: json['name'] as String,
      imageUrl: artworkUrl(id),
    );
  }

  static String artworkUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}
