import 'package:flutter/material.dart';

import '../models/evolution_link.dart';
import '../models/pokemon_summary.dart';
import '../models/species_info.dart';
import '../screens/detail_screen.dart';
import '../services/pokemon_service.dart';
import '../utils/text_utils.dart';
import 'error_view.dart';

/// Menampilkan deskripsi dan rantai evolusi (dua request berantai).
class SpeciesSection extends StatefulWidget {
  final PokemonService service;
  final int pokemonId;

  const SpeciesSection({
    super.key,
    required this.service,
    required this.pokemonId,
  });

  @override
  State<SpeciesSection> createState() => _SpeciesSectionState();
}

class _SpeciesSectionState extends State<SpeciesSection> {
  late Future<(SpeciesInfo, List<EvolutionLink>)> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.fetchSpeciesWithEvolution(widget.pokemonId);
  }

  void _reload() {
    setState(() {
      _future = widget.service.fetchSpeciesWithEvolution(widget.pokemonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(SpeciesInfo, List<EvolutionLink>)>(
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

        final (species, links) = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (species.genus.isNotEmpty)
              Center(
                child: Text(species.genus,
                    style: const TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.grey)),
              ),
            if (species.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(species.description, style: const TextStyle(height: 1.4)),
            ],
            const SizedBox(height: 16),
            const Text('Evolusi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (links.isEmpty)
              const Text('Pokémon ini tidak berevolusi.')
            else
              ...links.map(_evolutionRow),
          ],
        );
      },
    );
  }

  Widget _evolutionRow(EvolutionLink link) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _node(link.fromId, link.fromName),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.arrow_forward),
                if (link.requirement.isNotEmpty)
                  Text(
                    link.requirement,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
          _node(link.toId, link.toName),
        ],
      ),
    );
  }

  Widget _node(int id, String name) {
    return InkWell(
      onTap: id == widget.pokemonId
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(
                    summary: PokemonSummary(
                      id: id,
                      name: name,
                      imageUrl: PokemonSummary.artworkUrl(id),
                    ),
                  ),
                ),
              ),
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            Image.network(
              PokemonSummary.artworkUrl(id),
              height: 64,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 40),
            ),
            Text(capitalize(name),
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
