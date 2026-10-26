import 'package:flutter/material.dart';

/// Daftar 18 tipe Pokémon (urutan tampil pada filter).
const List<String> allTypes = [
  'normal', 'fire', 'water', 'electric', 'grass', 'ice',
  'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug',
  'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy',
];

Color typeColor(String type) {
  switch (type) {
    case 'fire':
      return Colors.deepOrange;
    case 'water':
      return Colors.blue;
    case 'grass':
      return Colors.green;
    case 'electric':
      return Colors.amber.shade700;
    case 'psychic':
      return Colors.pink;
    case 'ice':
      return Colors.cyan;
    case 'dragon':
      return Colors.indigo;
    case 'dark':
      return Colors.brown;
    case 'fairy':
      return Colors.pinkAccent;
    case 'fighting':
      return Colors.red.shade800;
    case 'poison':
      return Colors.purple;
    case 'ground':
      return Colors.brown.shade400;
    case 'rock':
      return Colors.blueGrey;
    case 'ghost':
      return Colors.deepPurple;
    case 'bug':
      return Colors.lightGreen.shade700;
    case 'steel':
      return Colors.blueGrey.shade400;
    case 'flying':
      return Colors.lightBlue;
    default:
      return Colors.grey; // normal & lainnya
  }
}
