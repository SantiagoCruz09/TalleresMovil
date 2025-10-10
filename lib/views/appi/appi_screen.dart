import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppiScreen extends StatelessWidget {
  const AppiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('APPI')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pantalla APPI', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: () => context.go('/'), child: const Text('Volver al Home')),
          ],
        ),
      ),
    );
  }
}
