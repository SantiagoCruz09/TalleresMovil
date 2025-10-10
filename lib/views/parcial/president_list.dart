import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/president_service.dart';
import '../../models/president.dart';

class PresidentListScreen extends StatefulWidget {
  final PresidentService service;
  const PresidentListScreen({super.key, required this.service});

  @override
  State<PresidentListScreen> createState() => _PresidentListScreenState();
}

class _PresidentListScreenState extends State<PresidentListScreen> {
  late Future<List<President>> _future;
  List<President> _items = [];

  @override
  void initState() {
    super.initState();
    debugPrint('PresidentListScreen: init - solicitando presidentes');
    _future = widget.service.fetchPresidents();
  }

  Future<void> _refresh() async {
    setState(() => _future = widget.service.fetchPresidents());
    final items = await _future;
    setState(() => _items = items);
  }

  Widget _card(President p) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(child: Text(((p.name ?? '?')[0]).toUpperCase())),
        title: Text('${p.name ?? ''}'.trim(), style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (p.party != null) Text('Partido: ${p.party!}'),
          if (p.startDate != null) Text('Periodo inicio: ${p.startDate}', style: const TextStyle(fontSize: 12)),
        ]),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/parcial/president/${p.id}', extra: p),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presidentes'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/parcial')),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<President>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _items.isEmpty) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) {
              debugPrint('PresidentListScreen: error al obtener lista: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final items = snapshot.data ?? _items;
            debugPrint('PresidentListScreen: items=${items.length}');
            if (items.isEmpty) return ListView(children: const [SizedBox(height: 120), Center(child: Text('No hay presidentes', style: TextStyle(fontSize: 16)))]);
            return ListView.builder(itemCount: items.length, itemBuilder: (context, i) => _card(items[i]));
          },
        ),
      ),
    );
  }
}
