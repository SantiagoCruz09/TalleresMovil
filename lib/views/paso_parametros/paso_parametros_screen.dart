import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PasoParametrosScreen extends StatelessWidget {
  const PasoParametrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paso de Parámetros")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text("Ir con go()"),
              onPressed: () => context.go("/detalle/Hola desde go()"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text("Ir con push()"),
              onPressed: () => context.push("/detalle/Hola desde push()"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.swap_horiz),
              label: const Text("Ir con replace()"),
              onPressed: () => context.replace("/detalle/Hola desde replace()"),
            ),
          ],
        ),
      ),
    );
  }
}
