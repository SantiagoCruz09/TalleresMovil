import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/department.dart';
import '../../services/department_service.dart';

class DepartmentDetailScreen extends StatefulWidget {
  final String id;
  final Department? item;
  final DepartmentService service;
  const DepartmentDetailScreen({super.key, required this.id, this.item, required this.service});

  @override
  State<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends State<DepartmentDetailScreen> {
  late Future<Department?> _future;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _future = Future.value(widget.item);
    } else {
      final id = int.tryParse(widget.id) ?? 0;
      _future = widget.service.fetchDepartmentById(id).then((v) => v);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle Departamento'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: FutureBuilder<Department?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final d = snapshot.data;
          if (d == null) return const Center(child: Text('No se encontró el departamento'));
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.name ?? 'Sin nombre', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (d.description != null) Text(d.description!),
              const SizedBox(height: 12),
              Text('Población: ${d.population ?? 'N/A'}'),
              Text('Superficie: ${d.surface ?? 'N/A'}'),
              Text('Prefijo telefónico: ${d.phonePrefix ?? 'N/A'}'),
            ]),
          );
        },
      ),
    );
  }
}
