import 'pokemon_summary.dart';

class PokemonStat {
  final String name;
  final int value;

  const PokemonStat({required this.name, required this.value});

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['stat']['name'] as String,
      value: json['base_stat'] as int,
    );
  }
}

/// Model detail Pokémon dari endpoint: /pokemon/{id}
class PokemonDetail {
  final int id;
  final String name;
  final String imageUrl;
  final double heightM;
  final double weightKg;
  final int baseExperience;
  final List<String> types;
  final List<String> abilities;
  final List<PokemonStat> stats;

  const PokemonDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.heightM,
    required this.weightKg,
    required this.baseExperience,
    required this.types,
    required this.abilities,
    required this.stats,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    return PokemonDetail(
      id: id,
      name: json['name'] as String,
      imageUrl: PokemonSummary.artworkUrl(id),
      // API: height dalam desimeter, weight dalam hektogram
      heightM: (json['height'] as int) / 10,
      weightKg: (json['weight'] as int) / 10,
      baseExperience: (json['base_experience'] as int?) ?? 0,
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      abilities: (json['abilities'] as List)
          .map((a) => a['ability']['name'] as String)
          .toList(),
      stats: (json['stats'] as List)
          .map((s) => PokemonStat.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
