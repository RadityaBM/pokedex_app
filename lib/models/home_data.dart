import 'pokemon_summary.dart';

/// Gabungan data halaman utama: daftar Pokémon + peta tipe (id -> daftar tipe).
class HomeData {
  final List<PokemonSummary> pokemon;
  final Map<int, List<String>> types;

  const HomeData({required this.pokemon, required this.types});
}
