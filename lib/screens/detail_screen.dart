import 'package:flutter/material.dart';

import '../models/pokemon_detail.dart';
import '../models/pokemon_summary.dart';
import '../services/pokemon_service.dart';
import '../utils/text_utils.dart';
import '../utils/type_color.dart';
import '../widgets/encounter_section.dart';
import '../widgets/error_view.dart';
import '../widgets/species_section.dart';

class DetailScreen extends StatefulWidget {
  final PokemonSummary summary;

  /// Tipe dari halaman daftar (opsional), dipakai untuk mewarnai AppBar lebih awal.
  final List<String> types;

  const DetailScreen({
    super.key,
    required this.summary,
    this.types = const [],
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PokemonService _service = PokemonService();
  late Future<PokemonDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchPokemonDetail(widget.summary.id);
  }

  void _reload() {
    setState(() {
      _future = _service.fetchPokemonDetail(widget.summary.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor =
        widget.types.isNotEmpty ? typeColor(widget.types.first) : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text(capitalize(widget.summary.name)),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<PokemonDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: _reload,
            );
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _buildContent(PokemonDetail p) {
    final color = p.types.isNotEmpty ? typeColor(p.types.first) : Colors.grey;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withAlpha(110), color.withAlpha(0)],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'pokemon-${p.id}',
              child: Image.network(
                p.imageUrl,
                height: 220,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 80),
              ),
            ),
          ),
        ),
        Center(
          child: Text(
            '#${p.id.toString().padLeft(3, '0')}  ${capitalize(p.name)}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: p.types
              .map((t) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Chip(
                      label: Text(capitalize(t),
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: typeColor(t),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),

        // Deskripsi + evolusi (request berantai, FutureBuilder sendiri)
        SpeciesSection(service: _service, pokemonId: p.id),

        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _info('Tinggi', '${p.heightM} m'),
            _info('Berat', '${p.weightKg} kg'),
            _info('Base EXP', '${p.baseExperience}'),
          ],
        ),

        _title('Kemampuan'),
        Wrap(
          spacing: 8,
          children: p.abilities.map((a) => Chip(label: Text(prettify(a)))).toList(),
        ),

        _title('Base Stats'),
        ...p.stats.map(_statRow),

        _title('Lokasi Ditemukan'),
        // Lokasi per game (FutureBuilder sendiri)
        EncounterSection(service: _service, pokemonId: p.id),
      ],
    );
  }

  Widget _info(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _statRow(PokemonStat s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(prettify(s.name))),
          SizedBox(width: 36, child: Text('${s.value}')),
          Expanded(
            child: LinearProgressIndicator(
              value: (s.value / 255).clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              color: s.value >= 100 ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
