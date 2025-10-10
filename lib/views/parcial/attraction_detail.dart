import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/touristic_attraction.dart';
import '../../services/touristic_attraction_service.dart';

class AttractionDetailScreen extends StatefulWidget {
  final String id;
  final TouristicAttraction? item;
  final TouristicAttractionService service;
  const AttractionDetailScreen({super.key, required this.id, this.item, required this.service});

  @override
  State<AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  late Future<TouristicAttraction?> _future;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _future = Future.value(widget.item);
    } else {
      final id = int.tryParse(widget.id) ?? 0;
      _future = widget.service.fetchAttractionById(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Atracción'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: FutureBuilder<TouristicAttraction?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final a = snapshot.data;
          if (a == null) return const Center(child: Text('No encontrado'));
          return Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.name ?? 'Sin nombre', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 8), if (a.location != null) Text('Ubicación: ${a.location}'), if (a.description != null) Text(a.description!) ]));
        },
      ),
    );
  }
}
