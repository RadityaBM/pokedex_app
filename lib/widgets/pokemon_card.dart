import 'package:flutter/material.dart';

import '../models/pokemon_summary.dart';
import '../utils/text_utils.dart';
import '../utils/type_color.dart';

class PokemonCard extends StatelessWidget {
  final PokemonSummary pokemon;
  final List<String> types;
  final VoidCallback onTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
    this.types = const [],
  });

  @override
  Widget build(BuildContext context) {
    final color = types.isNotEmpty ? typeColor(types.first) : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      color: color?.withAlpha(45),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '#${pokemon.id.toString().padLeft(3, '0')}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              Expanded(
                child: Hero(
                  tag: 'pokemon-${pokemon.id}',
                  child: Image.network(
                    pokemon.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 48),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                capitalize(pokemon.name),
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              if (types.isNotEmpty)
                Text(
                  types.map(capitalize).join(' · '),
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
