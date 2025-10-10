import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/city_service.dart';
import '../../models/city.dart';

class CityListScreen extends StatefulWidget {
  final CityService service;
  const CityListScreen({super.key, required this.service});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  late Future<List<City>> _future;
  List<City> _items = [];

  @override
  void initState() {
    super.initState();
    debugPrint('CityListScreen: init - solicitando ciudades');
    _future = widget.service.fetchCities();
  }

  Future<void> _refresh() async {
    setState(() => _future = widget.service.fetchCities());
    final items = await _future;
    setState(() => _items = items);
  }

  Widget _card(City c) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(child: Text((c.name ?? '?')[0].toUpperCase())),
        title: Text(c.name ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (c.description != null) Text(c.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text('Departamento: ${c.departmentId ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
        ]),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/parcial/city/${c.id}', extra: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ciudades'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/parcial')),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<City>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _items.isEmpty) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) {
              debugPrint('CityListScreen: error al obtener lista: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final items = snapshot.data ?? _items;
            debugPrint('CityListScreen: items=${items.length}');
            if (items.isEmpty) return ListView(children: const [SizedBox(height: 120), Center(child: Text('No hay ciudades', style: TextStyle(fontSize: 16)))]);
            return ListView.builder(itemCount: items.length, itemBuilder: (context, i) => _card(items[i]));
          },
        ),
      ),
    );
  }
}
