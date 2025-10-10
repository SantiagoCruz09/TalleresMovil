import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/adaptive_network_image.dart';
import '../../models/appi_item.dart';
import '../../services/appi_service.dart';

class AppiDetailScreen extends StatefulWidget {
  final String id;
  final AppiItem? item;
  final AppiService service;
  const AppiDetailScreen({super.key, required this.id, this.item, required this.service});

  @override
  State<AppiDetailScreen> createState() => _AppiDetailScreenState();
}

class _AppiDetailScreenState extends State<AppiDetailScreen> {
  late Future<AppiItem> _future;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _future = Future.value(widget.item!);
      debugPrint('APPI DetailScreen: usando item pasado por extra id=${widget.item!.id}');
    } else {
      debugPrint('APPI DetailScreen: solicitando detalle id=${widget.id}');
      _future = widget.service.fetchItemById(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              // Fallback: ir al listado APPI
              context.goNamed('appi');
            }
          },
        ),
      ),
      body: FutureBuilder<AppiItem>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final item = snapshot.data!;
          debugPrint('APPI DetailScreen: mostrando detalle id=${item.id}');
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdaptiveNetworkImage(
                  sources: [item.imageUrl],
                  height: 200,
                  placeholder: const SizedBox(height: 200, child: Center(child: Icon(Icons.broken_image, size: 48))),
                ),
                const SizedBox(height: 12),
                Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (item.artistDisplay != null) Text(item.artistDisplay!, style: const TextStyle(fontStyle: FontStyle.italic)),
                if (item.placeOfOrigin != null) Text(item.placeOfOrigin!),
                if (item.dateDisplay != null) Text(item.dateDisplay!),
                const SizedBox(height: 8),
                if (item.description != null) Text(item.description!),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      context.pop();
                    } else {
                      context.goNamed('appi');
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
