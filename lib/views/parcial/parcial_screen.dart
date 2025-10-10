import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ParcialScreen extends StatelessWidget {
  const ParcialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcial'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Parcial - integraciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('Listado Departamentos (API-Colombia)'),
              onPressed: () => context.go('/parcial/departments'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.location_city),
              label: const Text('Listado Ciudades (API-Colombia)'),
              onPressed: () => context.go('/parcial/cities'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Listado Presidentes (API-Colombia)'),
              onPressed: () => context.go('/parcial/presidents'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.place),
              label: const Text('Listado Atracciones (API-Colombia)'),
              onPressed: () => context.go('/parcial/attractions'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.api),
              label: const Text('Listado APPI (Art Institute)'),
              onPressed: () => context.go('/appi'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Volver al Home'),
              onPressed: () => context.goNamed('home'),
            ),
          ],
        ),
      ),
    );
  }
}
