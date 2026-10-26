String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// "thunder-stone" -> "Thunder stone"
String prettify(String s) => capitalize(s.replaceAll('-', ' '));

/// Mengambil id dari url PokeAPI, contoh: .../pokemon-species/25/ -> 25
int idFromUrl(String url) {
  final segments = url.split('/').where((s) => s.isNotEmpty).toList();
  return int.parse(segments.last);
}
