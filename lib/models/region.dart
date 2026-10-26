/// Region/generasi Pokémon beserta rentang nomor Pokédex-nya.
class Region {
  final String name;
  final int generation;
  final int startId;
  final int endId;

  const Region({
    required this.name,
    required this.generation,
    required this.startId,
    required this.endId,
  });

  int get count => endId - startId + 1;

  /// Teks keterangan di menu. Generasi 0 dipakai untuk "Semua Region".
  String get subtitle => generation == 0
      ? 'Nasional · #$startId–#$endId'
      : 'Generasi $generation · #$startId–#$endId';

  /// Gabungan seluruh region (nomor Pokédex nasional 1–1025).
  static const Region national = Region(
    name: 'Semua Region',
    generation: 0,
    startId: 1,
    endId: 1025,
  );

  static const List<Region> all = [
    Region(name: 'Kanto', generation: 1, startId: 1, endId: 151),
    Region(name: 'Johto', generation: 2, startId: 152, endId: 251),
    Region(name: 'Hoenn', generation: 3, startId: 252, endId: 386),
    Region(name: 'Sinnoh', generation: 4, startId: 387, endId: 493),
    Region(name: 'Unova', generation: 5, startId: 494, endId: 649),
    Region(name: 'Kalos', generation: 6, startId: 650, endId: 721),
    Region(name: 'Alola', generation: 7, startId: 722, endId: 809),
    Region(name: 'Galar', generation: 8, startId: 810, endId: 905),
    Region(name: 'Paldea', generation: 9, startId: 906, endId: 1025),
  ];
}
