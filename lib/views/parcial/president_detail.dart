import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/president.dart';
import '../../services/president_service.dart';

class PresidentDetailScreen extends StatefulWidget {
  final String id;
  final President? item;
  final PresidentService service;
  const PresidentDetailScreen({super.key, required this.id, this.item, required this.service});

  @override
  State<PresidentDetailScreen> createState() => _PresidentDetailScreenState();
}

class _PresidentDetailScreenState extends State<PresidentDetailScreen> {
  late Future<President?> _future;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _future = Future.value(widget.item);
    } else {
      final id = int.tryParse(widget.id) ?? 0;
      _future = widget.service.fetchPresidentById(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Presidente'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: FutureBuilder<President?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final p = snapshot.data;
          if (p == null) return const Center(child: Text('No encontrado'));
          return Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name ?? 'Sin nombre', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 8), if (p.party != null) Text('Partido: ${p.party}'), if (p.startDate != null) Text('Inicio: ${p.startDate}') ]));
        },
      ),
    );
  }
}
