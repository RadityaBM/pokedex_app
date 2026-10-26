/// Lokasi ditemukannya Pokémon, dikelompokkan per versi game.
/// Data dari endpoint: /pokemon/{id}/encounters
class EncounterGroup {
  final String version;
  final List<String> locations;

  const EncounterGroup({required this.version, required this.locations});

  static List<EncounterGroup> fromJsonList(List data) {
    final map = <String, Set<String>>{};

    for (final entry in data) {
      final location = entry['location_area']['name'] as String;
      for (final v in entry['version_details'] as List) {
        final version = v['version']['name'] as String;
        map.putIfAbsent(version, () => <String>{}).add(location);
      }
    }

    final keys = map.keys.toList()..sort();
    return keys
        .map((k) => EncounterGroup(
              version: k,
              locations: map[k]!.toList()..sort(),
            ))
        .toList();
  }
}
