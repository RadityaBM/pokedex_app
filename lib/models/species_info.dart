/// Data dari endpoint: /pokemon-species/{id}
class SpeciesInfo {
  final String description;
  final String genus;
  final String evolutionChainUrl;

  const SpeciesInfo({
    required this.description,
    required this.genus,
    required this.evolutionChainUrl,
  });

  factory SpeciesInfo.fromJson(Map<String, dynamic> json) {
    // Ambil entri berbahasa Inggris (API tidak menyediakan bahasa Indonesia).
    String pickEnglish(List entries, String key) {
      for (final e in entries) {
        if (e['language']['name'] == 'en') {
          return (e[key] as String).replaceAll(RegExp(r'[\n\f]'), ' ');
        }
      }
      return '';
    }

    return SpeciesInfo(
      description: pickEnglish(json['flavor_text_entries'] as List, 'flavor_text'),
      genus: pickEnglish(json['genera'] as List, 'genus'),
      evolutionChainUrl: json['evolution_chain']['url'] as String,
    );
  }
}
