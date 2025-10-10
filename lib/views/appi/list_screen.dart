import 'package:flutter/material.dart';
import '../../services/appi_service.dart';
import '../../models/appi_item.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/adaptive_network_image.dart';

class AppiListScreen extends StatefulWidget {
  final AppiService service;
  const AppiListScreen({super.key, required this.service});

  @override
  State<AppiListScreen> createState() => _AppiListScreenState();
}

class _AppiListScreenState extends State<AppiListScreen> {
  late Future<List<AppiItem>> _future;
  bool _showWithoutImage = false;

  @override
  void initState() {
    super.initState();
    debugPrint('APPI ListScreen: iniciando carga');
    _future = widget.service.fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado APPI'),
        actions: [
          IconButton(
            tooltip: 'Volver al Home',
            icon: const Icon(Icons.home),
            onPressed: () => context.goNamed('home'),
          ),
          IconButton(
            tooltip: 'Alternar mostrar elementos sin imagen',
            icon: Icon(_showWithoutImage ? Icons.image : Icons.image_not_supported),
            onPressed: () {
              setState(() => _showWithoutImage = !_showWithoutImage);
              final msg = _showWithoutImage ? 'Mostrando elementos sin imagen' : 'Ocultando elementos sin imagen';
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<AppiItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('APPI ListScreen: error al obtener lista: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No hay resultados'));
          final filtered = items.where((i) => _showWithoutImage || i.imageUrl != null).toList();
          debugPrint('APPI ListScreen: items totales=${items.length} filtrados=${filtered.length} showWithoutImage=$_showWithoutImage');
          if (filtered.isEmpty) return const Center(child: Text('No hay resultados que cumplan el filtro'));
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              // Log en consola por item
              debugPrint('APPI ListScreen: mostrando item index=$index id=${item.id}');
              return ListTile(
                leading: AdaptiveNetworkImage(
                  sources: [item.imageUrl,],
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: const SizedBox(width: 56, height: 56, child: Icon(Icons.broken_image, size: 20)),
                ),
                title: Text(item.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.artistDisplay != null) Text(item.artistDisplay!, style: const TextStyle(fontSize: 12)),
                    if (item.placeOfOrigin != null) Text(item.placeOfOrigin!, style: const TextStyle(fontSize: 12)),
                    if (item.dateDisplay != null) Text(item.dateDisplay!, style: const TextStyle(fontSize: 12)),
                    if (item.description != null) const SizedBox(height: 6),
                    if (item.description != null) Text(item.description!, maxLines: 4, overflow: TextOverflow.ellipsis),
                  ],
                ),
                isThreeLine: true,
                onTap: () => context.go('/appi/${Uri.encodeComponent(item.id)}', extra: item),
              );
            },
          );
        },
      ),
    );
  }
}
