import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetalleScreen extends StatelessWidget {
  final String mensaje;
  const DetalleScreen({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    // Log clara en consola cuando se recibe el parámetro
    debugPrint('DetalleScreen: parámetro recibido -> "$mensaje"');
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Mensaje recibido: $mensaje\n\n(Se registró en la consola)",
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: () => context.go('/'), child: const Text('Volver al Home')),
          ],
        ),
      ),
    );
  }
}
