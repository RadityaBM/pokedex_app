import 'package:flutter/material.dart';

import '../models/encounter_group.dart';
import '../services/pokemon_service.dart';
import '../utils/text_utils.dart';
import 'error_view.dart';

/// Menampilkan lokasi ditemukannya Pokémon per versi game.
class EncounterSection extends StatefulWidget {
  final PokemonService service;
  final int pokemonId;

  const EncounterSection({
    super.key,
    required this.service,
    required this.pokemonId,
  });

  @override
  State<EncounterSection> createState() => _EncounterSectionState();
}

class _EncounterSectionState extends State<EncounterSection> {
  late Future<List<EncounterGroup>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.fetchEncounters(widget.pokemonId);
  }

  void _reload() {
    setState(() {
      _future = widget.service.fetchEncounters(widget.pokemonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EncounterGroup>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: snapshot.error.toString(),
            onRetry: _reload,
            compact: true,
          );
        }

        final groups = snapshot.data ?? [];
        if (groups.isEmpty) {
          return const Text(
            'Tidak ditemukan di alam liar pada game utama '
            '(bisa jadi hasil evolusi, hadiah, atau Pokémon legendaris).',
          );
        }

        return Column(
          children: groups
              .map((g) => ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text('Pokémon ${prettify(g.version)}'),
                    subtitle: Text('${g.locations.length} lokasi'),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 6,
                          children: g.locations
                              .map((l) => Chip(
                                    label: Text(prettify(l),
                                        style: const TextStyle(fontSize: 11)),
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ))
              .toList(),
        );
      },
    );
  }
}
