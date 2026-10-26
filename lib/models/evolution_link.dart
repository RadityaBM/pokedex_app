import '../utils/text_utils.dart';

/// Satu langkah evolusi: [fromName] -> [toName] dengan syarat tertentu.
class EvolutionLink {
  final int fromId;
  final String fromName;
  final int toId;
  final String toName;
  final String requirement;

  const EvolutionLink({
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.requirement,
  });

  /// Mengubah struktur bersarang `chain` (endpoint /evolution-chain/{id})
  /// menjadi daftar langkah evolusi yang datar.
  static List<EvolutionLink> fromChain(Map<String, dynamic> chain) {
    final links = <EvolutionLink>[];

    void walk(Map<String, dynamic> node) {
      final from = node['species'] as Map<String, dynamic>;
      for (final next in node['evolves_to'] as List) {
        final nextMap = next as Map<String, dynamic>;
        final to = nextMap['species'] as Map<String, dynamic>;
        links.add(EvolutionLink(
          fromId: idFromUrl(from['url'] as String),
          fromName: from['name'] as String,
          toId: idFromUrl(to['url'] as String),
          toName: to['name'] as String,
          requirement: _requirement(nextMap['evolution_details'] as List),
        ));
        walk(nextMap); // rekursif untuk tahap evolusi berikutnya
      }
    }

    walk(chain);
    return links;
  }

  static String _requirement(List details) {
    if (details.isEmpty) return '';
    final d = details.first as Map<String, dynamic>;
    if (d['min_level'] != null) return 'Level ${d['min_level']}';
    if (d['item'] != null) return 'Item: ${prettify(d['item']['name'] as String)}';
    if (d['min_happiness'] != null) return 'Kebahagiaan ${d['min_happiness']}';
    final trigger = (d['trigger']?['name'] as String?) ?? '';
    switch (trigger) {
      case 'trade':
        return 'Tukar (trade)';
      case 'level-up':
        return 'Naik level';
      case 'use-item':
        return 'Pakai item';
      default:
        return prettify(trigger);
    }
  }
}
