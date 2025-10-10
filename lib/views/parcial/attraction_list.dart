import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/touristic_attraction_service.dart';
import '../../models/touristic_attraction.dart';

class AttractionListScreen extends StatefulWidget {
  final TouristicAttractionService service;
  const AttractionListScreen({super.key, required this.service});

  @override
  State<AttractionListScreen> createState() => _AttractionListScreenState();
}

class _AttractionListScreenState extends State<AttractionListScreen> {
  late Future<List<TouristicAttraction>> _future;
  List<TouristicAttraction> _items = [];

  @override
  void initState() {
    super.initState();
    debugPrint('AttractionListScreen: init - solicitando atracciones');
    _future = widget.service.fetchAttractions();
  }

  Future<void> _refresh() async {
    setState(() => _future = widget.service.fetchAttractions());
    final items = await _future;
    setState(() => _items = items);
  }

  Widget _card(TouristicAttraction a) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(child: Text((a.name ?? '?')[0].toUpperCase())),
        title: Text(a.name ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (a.location != null) Text(a.location!, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          if (a.description != null) Text(a.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/parcial/attraction/${a.id}', extra: a),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atracciones Turísticas'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/parcial')),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<TouristicAttraction>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _items.isEmpty) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) {
              debugPrint('AttractionListScreen: error al obtener lista: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final items = snapshot.data ?? _items;
            debugPrint('AttractionListScreen: items=${items.length}');
            if (items.isEmpty) return ListView(children: const [SizedBox(height: 120), Center(child: Text('No hay atracciones', style: TextStyle(fontSize: 16)))]);
            return ListView.builder(itemCount: items.length, itemBuilder: (context, i) => _card(items[i]));
          },
        ),
      ),
    );
  }
}
