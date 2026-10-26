import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokedex_app/models/encounter_group.dart';
import 'package:pokedex_app/models/evolution_link.dart';
import 'package:pokedex_app/models/pokemon_detail.dart';
import 'package:pokedex_app/models/pokemon_summary.dart';
import 'package:pokedex_app/models/species_info.dart';
import 'package:pokedex_app/services/pokemon_service.dart';

void main() {
  group('Model', () {
    test('PokemonSummary.fromJson mengambil id dari url', () {
      final p = PokemonSummary.fromJson({
        'name': 'pikachu',
        'url': 'https://pokeapi.co/api/v2/pokemon/25/',
      });
      expect(p.id, 25);
      expect(p.name, 'pikachu');
      expect(p.imageUrl.endsWith('/25.png'), true);
    });

    test('PokemonDetail.fromJson mengonversi satuan dan list', () {
      final d = PokemonDetail.fromJson({
        'id': 25,
        'name': 'pikachu',
        'height': 4,
        'weight': 60,
        'base_experience': 112,
        'types': [
          {'type': {'name': 'electric'}}
        ],
        'abilities': [
          {'ability': {'name': 'static'}}
        ],
        'stats': [
          {'base_stat': 35, 'stat': {'name': 'hp'}}
        ],
      });
      expect(d.heightM, 0.4);
      expect(d.weightKg, 6.0);
      expect(d.types, ['electric']);
      expect(d.stats.first.value, 35);
    });

    test('SpeciesInfo memilih teks bahasa Inggris dan membersihkan baris baru', () {
      final s = SpeciesInfo.fromJson({
        'flavor_text_entries': [
          {'flavor_text': 'Teks lain', 'language': {'name': 'ja'}},
          {'flavor_text': 'Line one\nline two\fend', 'language': {'name': 'en'}},
        ],
        'genera': [
          {'genus': 'Mouse Pokémon', 'language': {'name': 'en'}}
        ],
        'evolution_chain': {'url': 'https://pokeapi.co/api/v2/evolution-chain/10/'},
      });
      expect(s.description, 'Line one line two end');
      expect(s.genus, 'Mouse Pokémon');
      expect(s.evolutionChainUrl.contains('evolution-chain/10'), true);
    });

    test('EvolutionLink.fromChain meratakan rantai bersarang', () {
      final chain = {
        'species': {'name': 'charmander', 'url': 'https://pokeapi.co/api/v2/pokemon-species/4/'},
        'evolves_to': [
          {
            'species': {'name': 'charmeleon', 'url': 'https://pokeapi.co/api/v2/pokemon-species/5/'},
            'evolution_details': [
              {'min_level': 16, 'item': null, 'trigger': {'name': 'level-up'}}
            ],
            'evolves_to': [
              {
                'species': {'name': 'charizard', 'url': 'https://pokeapi.co/api/v2/pokemon-species/6/'},
                'evolution_details': [
                  {'min_level': 36, 'item': null, 'trigger': {'name': 'level-up'}}
                ],
                'evolves_to': [],
              }
            ],
          }
        ],
      };
      final links = EvolutionLink.fromChain(chain);
      expect(links.length, 2);
      expect(links[0].fromName, 'charmander');
      expect(links[0].toId, 5);
      expect(links[0].requirement, 'Level 16');
      expect(links[1].toName, 'charizard');
      expect(links[1].requirement, 'Level 36');
    });

    test('EvolutionLink: syarat item dan rantai tanpa evolusi', () {
      final links = EvolutionLink.fromChain({
        'species': {'name': 'pikachu', 'url': 'https://pokeapi.co/api/v2/pokemon-species/25/'},
        'evolves_to': [
          {
            'species': {'name': 'raichu', 'url': 'https://pokeapi.co/api/v2/pokemon-species/26/'},
            'evolution_details': [
              {'min_level': null, 'item': {'name': 'thunder-stone'}, 'trigger': {'name': 'use-item'}}
            ],
            'evolves_to': [],
          }
        ],
      });
      expect(links.single.requirement, 'Item: Thunder stone');

      final none = EvolutionLink.fromChain({
        'species': {'name': 'tauros', 'url': 'https://pokeapi.co/api/v2/pokemon-species/128/'},
        'evolves_to': [],
      });
      expect(none, isEmpty);
    });

    test('EncounterGroup mengelompokkan lokasi per versi game', () {
      final groups = EncounterGroup.fromJsonList([
        {
          'location_area': {'name': 'route-1-area'},
          'version_details': [
            {'version': {'name': 'red'}},
            {'version': {'name': 'blue'}},
          ],
        },
        {
          'location_area': {'name': 'viridian-forest-area'},
          'version_details': [
            {'version': {'name': 'red'}},
          ],
        },
      ]);
      expect(groups.length, 2);
      expect(groups.firstWhere((g) => g.version == 'red').locations.length, 2);
      expect(groups.firstWhere((g) => g.version == 'blue').locations.length, 1);
      expect(EncounterGroup.fromJsonList([]), isEmpty);
    });
  });

  group('Service', () {
    test('fetchPokemonList sukses (status 200)', () async {
      final client = MockClient((_) async => http.Response(
          jsonEncode({
            'results': [
              {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon/1/'}
            ]
          }),
          200));
      final list = await PokemonService(client: client).fetchPokemonList();
      expect(list.length, 1);
      expect(list.first.name, 'bulbasaur');
    });

    test('melempar PokemonException saat status bukan 200', () async {
      final client = MockClient((_) async => http.Response('Not found', 404));
      expect(
        () => PokemonService(client: client).fetchPokemonList(),
        throwsA(isA<PokemonException>()),
      );
    });

    test('melempar PokemonException saat JSON tidak valid', () async {
      final client = MockClient((_) async => http.Response('bukan json', 200));
      expect(
        () => PokemonService(client: client).fetchPokemonList(),
        throwsA(isA<PokemonException>()),
      );
    });

    test('fetchTypeMap membentuk peta id -> tipe', () async {
      final client = MockClient((request) async {
        final isFire = request.url.path.endsWith('/type/fire');
        return http.Response(
          jsonEncode({
            'pokemon': isFire
                ? [
                    {
                      'slot': 1,
                      'pokemon': {'name': 'charmander', 'url': 'https://pokeapi.co/api/v2/pokemon/4/'}
                    },
                    {
                      'slot': 1,
                      'pokemon': {'name': 'zzz-form', 'url': 'https://pokeapi.co/api/v2/pokemon/10001/'}
                    },
                  ]
                : []
          }),
          200,
        );
      });
      final map = await PokemonService(client: client).fetchTypeMap(maxId: 151);
      expect(map[4], ['fire']);
      expect(map.containsKey(10001), false); // bentuk khusus diabaikan
    });
  });
}
