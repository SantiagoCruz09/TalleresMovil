import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/city.dart';
import '../../services/city_service.dart';

class CityDetailScreen extends StatefulWidget {
  final String id;
  final City? item;
  final CityService service;
  const CityDetailScreen({super.key, required this.id, this.item, required this.service});

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
  late Future<City?> _future;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _future = Future.value(widget.item);
    } else {
      final id = int.tryParse(widget.id) ?? 0;
      _future = widget.service.fetchCityById(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Ciudad'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: FutureBuilder<City?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final c = snapshot.data;
          if (c == null) return const Center(child: Text('No encontrado'));
          return Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(c.name ?? 'Sin nombre', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 8), if (c.description != null) Text(c.description!)]));
        },
      ),
    );
  }
}
