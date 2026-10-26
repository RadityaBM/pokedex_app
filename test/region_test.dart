import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/models/region.dart';

void main() {
  test('Region Kanto berisi 151 Pokémon', () {
    final kanto = Region.all.first;
    expect(kanto.name, 'Kanto');
    expect(kanto.count, 151);
  });

  test('Rentang id antar region berurutan tanpa celah', () {
    for (var i = 1; i < Region.all.length; i++) {
      expect(Region.all[i].startId, Region.all[i - 1].endId + 1);
    }
    expect(Region.all.length, 9);
  });

  test('Region.national mencakup seluruh region (1025 Pokémon)', () {
    final total = Region.all.fold<int>(0, (sum, r) => sum + r.count);
    expect(Region.national.count, 1025);
    expect(Region.national.count, total);
    expect(Region.national.startId, Region.all.first.startId);
    expect(Region.national.endId, Region.all.last.endId);
  });
}
