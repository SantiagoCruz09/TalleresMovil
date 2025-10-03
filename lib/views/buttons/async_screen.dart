import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AsyncScreen extends StatefulWidget {
  const AsyncScreen({super.key});

  @override
  State<AsyncScreen> createState() => _AsyncScreenState();
}

class _AsyncScreenState extends State<AsyncScreen> {
  String _status = 'Inactivo';
  bool _running = false;

  Future<void> _doAsyncWork() async {
    if (_running) return;
    setState(() {
      _running = true;
      _status = 'Cargando...';
    });
    debugPrint('AsyncScreen: antes de la tarea async (inicio)');
    try {
      // Simulamos trabajo asíncrono con logs dentro del proceso
      debugPrint('AsyncScreen: dentro de Future.delayed (durante)');
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('AsyncScreen: tarea completada (después)');
      setState(() => _status = 'Éxito');
    } catch (e, s) {
      debugPrint('AsyncScreen: error $e\n$s');
      setState(() => _status = 'Error');
    } finally {
      setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Async')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Demo de Async/Await', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Estado: $_status'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _running ? null : _doAsyncWork,
              child: _running ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Iniciar tarea async'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => context.go('/'), child: const Text('Volver al Home')),
          ],
        ),
      ),
    );
  }
}
