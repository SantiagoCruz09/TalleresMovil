import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/department_service.dart';
import '../../models/department.dart';

class DepartmentListScreen extends StatefulWidget {
  final DepartmentService service;
  const DepartmentListScreen({super.key, required this.service});

  @override
  State<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends State<DepartmentListScreen> {
  late Future<List<Department>> _future;
  late List<Department> _items;

  @override
  void initState() {
    super.initState();
    _items = [];
    debugPrint('DepartmentListScreen: init - solicitando departamentos');
    _future = widget.service.fetchDepartments();
  }

  Future<void> _refresh() async {
    setState(() => _future = widget.service.fetchDepartments());
    final items = await _future;
    setState(() => _items = items);
  }

  Widget _buildCard(Department d) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(child: Text((d.name ?? '?').substring(0, 1).toUpperCase())),
        title: Text(d.name ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (d.description != null) Text(d.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.people, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text('Población: ${d.population ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 12),
            Icon(Icons.map, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text('Superficie: ${d.surface ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
          ])
        ]),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/parcial/department/${d.id}', extra: d),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departamentos'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/parcial')),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Department>>(
          future: _future,
          builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _items.isEmpty) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) {
                debugPrint('DepartmentListScreen: error al obtener lista: ${snapshot.error}');
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final items = snapshot.data ?? _items;
              debugPrint('DepartmentListScreen: items obtenidos=${items.length}');
            if (items.isEmpty) return ListView(children: const [SizedBox(height: 120), Center(child: Text('No hay departamentos', style: TextStyle(fontSize: 16)))]);
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => _buildCard(items[index]),
            );
          },
        ),
      ),
    );
  }
}
