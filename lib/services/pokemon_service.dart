import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/encounter_group.dart';
import '../models/evolution_link.dart';
import '../models/home_data.dart';
import '../models/pokemon_detail.dart';
import '../models/pokemon_summary.dart';
import '../models/region.dart';
import '../models/species_info.dart';
import '../utils/text_utils.dart';
import '../utils/type_color.dart';

class PokemonException implements Exception {
  final String message;
  const PokemonException(this.message);

  @override
  String toString() => message;
}

class PokemonService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  PokemonService({http.Client? client}) : _client = client ?? http.Client();

  // ---------- Halaman utama ----------

  Future<List<PokemonSummary>> fetchPokemonList(
      {int limit = 151, int offset = 0}) async {
    final data =
        await _getJson('$_baseUrl/pokemon?limit=$limit&offset=$offset') as Map;
    final results = data['results'] as List;
    return results
        .map((e) => PokemonSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Daftar Pokémon + peta tipe. Jika data tipe gagal dimuat, daftar tetap tampil.
  Future<HomeData> fetchHomeData(Region region) async {
    final pokemon = await fetchPokemonList(
      limit: region.count,
      offset: region.startId - 1,
    );
    final types =
        await fetchTypeMap(minId: region.startId, maxId: region.endId);
    return HomeData(pokemon: pokemon, types: types);
  }

  /// Mengambil 18 endpoint /type/{nama} secara paralel, lalu membentuk
  /// peta id Pokémon -> daftar tipe (urut berdasarkan slot).
  Future<Map<int, List<String>>> fetchTypeMap(
      {int minId = 1, required int maxId}) async {
    final slots = <int, List<MapEntry<int, String>>>{};

    await Future.wait(allTypes.map((type) async {
      try {
        final data = await _getJson('$_baseUrl/type/$type') as Map;
        for (final entry in data['pokemon'] as List) {
          final id = idFromUrl(entry['pokemon']['url'] as String);
          if (id < minId || id > maxId) continue; // di luar region / bentuk khusus
          slots
              .putIfAbsent(id, () => [])
              .add(MapEntry(entry['slot'] as int, type));
        }
      } catch (_) {
        // Kegagalan satu tipe tidak boleh menggagalkan seluruh halaman.
      }
    }));

    return slots.map((id, list) {
      list.sort((a, b) => a.key.compareTo(b.key));
      return MapEntry(id, list.map((e) => e.value).toList());
    });
  }

  // ---------- Halaman detail ----------

  Future<PokemonDetail> fetchPokemonDetail(int id) async {
    final data = await _getJson('$_baseUrl/pokemon/$id') as Map<String, dynamic>;
    return PokemonDetail.fromJson(data);
  }

  Future<SpeciesInfo> fetchSpecies(int id) async {
    final data =
        await _getJson('$_baseUrl/pokemon-species/$id') as Map<String, dynamic>;
    return SpeciesInfo.fromJson(data);
  }

  /// Dua request berantai: species -> evolution chain.
  Future<(SpeciesInfo, List<EvolutionLink>)> fetchSpeciesWithEvolution(
      int id) async {
    final species = await fetchSpecies(id);
    final chainData =
        await _getJson(species.evolutionChainUrl) as Map<String, dynamic>;
    final links =
        EvolutionLink.fromChain(chainData['chain'] as Map<String, dynamic>);
    return (species, links);
  }

  Future<List<EncounterGroup>> fetchEncounters(int id) async {
    final data = await _getJson('$_baseUrl/pokemon/$id/encounters') as List;
    return EncounterGroup.fromJsonList(data);
  }

  // ---------- Inti HTTP ----------

  Future<dynamic> _getJson(String url) async {
    try {
      final response = await _client.get(Uri.parse(url)).timeout(_timeout);

      if (response.statusCode != 200) {
        throw PokemonException(
            'Server mengembalikan status ${response.statusCode}.');
      }
      return jsonDecode(response.body);
    } on SocketException {
      throw const PokemonException('Tidak ada koneksi internet.');
    } on http.ClientException {
      throw const PokemonException('Tidak dapat terhubung ke server.');
    } on TimeoutException {
      throw const PokemonException('Permintaan melebihi batas waktu.');
    } on FormatException {
      throw const PokemonException('Format data dari server tidak valid.');
    } on TypeError {
      throw const PokemonException('Struktur data tidak sesuai harapan.');
    }
  }
}
