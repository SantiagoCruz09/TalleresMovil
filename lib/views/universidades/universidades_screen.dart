import 'package:flutter/material.dart';
import '../../models/universidad.dart';
import '../../services/universidad_service.dart';
import 'package:go_router/go_router.dart';

class UniversidadesScreen extends StatelessWidget {
  const UniversidadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = UniversidadService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Universidades')),
      body: StreamBuilder<List<Universidad>>(
        stream: service.streamUniversidades(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final lista = snapshot.data ?? [];
          if (lista.isEmpty) {
            return const Center(child: Text('No hay universidades aún. Usa + para agregar.'));
          }
          return ListView.separated(
            itemCount: lista.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final u = lista[index];
              return ListTile(
                title: Text(u.nombre),
                subtitle: Text('NIT: ${u.nit}\n${u.direccion}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        context.push('/universidades/edit/${u.id}');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirmar'),
                            content: Text('Eliminar ${u.nombre}?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
                            ],
                          ),
                        );
                        if (ok == true && u.id != null) {
                          await service.deleteUniversidad(u.id!);
                          messenger.showSnackBar(const SnackBar(content: Text('Universidad eliminada')));
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context.push('/universidades/new');
        },
      ),
    );
  }
}
