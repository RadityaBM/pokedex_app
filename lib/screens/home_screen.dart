import 'package:flutter/material.dart';

import '../models/home_data.dart';
import '../models/region.dart';
import '../services/pokemon_service.dart';
import '../utils/text_utils.dart';
import '../utils/type_color.dart';
import '../widgets/error_view.dart';
import '../widgets/pokemon_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PokemonService _service = PokemonService();
  late Future<HomeData> _future;
  Region _region = Region.all.first; // Kanto
  String _query = '';
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchHomeData(_region);
  }

  void _reload() {
    setState(() {
      _future = _service.fetchHomeData(_region);
    });
  }

  void _selectRegion(Region region) {
    Navigator.pop(context); // tutup drawer
    if (region == _region) return;
    setState(() {
      _region = region;
      _selectedType = null;
      _future = _service.fetchHomeData(region);
    });
  }

  void _showAbout() {
    Navigator.pop(context); // tutup drawer
    showAboutDialog(
      context: context,
      applicationName: 'Pokédex',
      applicationVersion: '1.0.0',
      applicationIcon:
          const Icon(Icons.catching_pokemon, color: Colors.red, size: 40),
      children: const [
        SizedBox(height: 8),
        Text('Aplikasi UTS Pemrograman Mobile (Praktikum G) yang dibuat '
            'dengan Flutter.\n\nSumber data: PokéAPI (pokeapi.co).'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex · ${_region.name}'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama Pokémon...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
          ),
          Expanded(
            child: FutureBuilder<HomeData>(
              future: _future,
              builder: (context, snapshot) {
                // 1. Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        Text('Memuat Pokémon ${_region.name}...'),
                      ],
                    ),
                  );
                }

                // 2. Error
                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: _reload,
                  );
                }

                // 3. Success
                return _buildSuccess(snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(color: Colors.red),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.catching_pokemon, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text('Pokédex',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                Text('Data dari PokéAPI',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Region / Generasi',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...[Region.national, ...Region.all].map((r) => ListTile(
                leading: Icon(
                  r == Region.national ? Icons.public : Icons.map_outlined,
                ),
                title: Text(r.name),
                subtitle: Text(r.subtitle),
                selected: r == _region,
                onTap: () => _selectRegion(r),
              )),
          const Divider(),
          SwitchListTile(
            secondary: Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
            title: const Text('Mode gelap'),
            value: widget.isDark,
            onChanged: (_) => widget.onToggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            onTap: _showAbout,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(HomeData data) {
    final availableTypes = allTypes
        .where((t) => data.types.values.any((list) => list.contains(t)))
        .toList();

    final list = data.pokemon.where((p) {
      final matchName = p.name.toLowerCase().contains(_query.toLowerCase());
      final matchType = _selectedType == null ||
          (data.types[p.id]?.contains(_selectedType) ?? false);
      return matchName && matchType;
    }).toList();

    return Column(
      children: [
        if (availableTypes.isNotEmpty) _typeFilter(availableTypes),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('Pokémon tidak ditemukan.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final pokemon = list[index];
                    final types = data.types[pokemon.id] ?? const <String>[];
                    return PokemonCard(
                      pokemon: pokemon,
                      types: types,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailScreen(summary: pokemon, types: types),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _typeFilter(List<String> types) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: const Text('Semua'),
              selected: _selectedType == null,
              onSelected: (_) => setState(() => _selectedType = null),
            ),
          ),
          ...types.map((t) {
            final selected = _selectedType == t;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(
                  capitalize(t),
                  style: TextStyle(color: selected ? Colors.white : null),
                ),
                selected: selected,
                selectedColor: typeColor(t),
                checkmarkColor: Colors.white,
                onSelected: (_) =>
                    setState(() => _selectedType = selected ? null : t),
              ),
            );
          }),
        ],
      ),
    );
  }
}
