import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IsolateScreen extends StatefulWidget {
  const IsolateScreen({super.key});

  @override
  State<IsolateScreen> createState() => _IsolateScreenState();
}

class _IsolateScreenState extends State<IsolateScreen> {
  String _result = 'Sin resultado';
  bool _running = false;

  Future<void> _runIsolate() async {
    if (_running) return;
    setState(() => _running = true);
    debugPrint('IsolateScreen: starting compute');
    try {
      // compute() usa isolates internamente y es más eficiente para tareas puntuales
      final params = {'input': 'Entrada ligera', 'iterations': 10};
      final message = await compute(heavyComputation, params).timeout(const Duration(seconds: 30));
      debugPrint('IsolateScreen: received -> $message');
      if (mounted) setState(() => _result = message);
    } on TimeoutException catch (_) {
      debugPrint('IsolateScreen: timeout');
      if (mounted) setState(() => _result = 'Timeout al ejecutar la tarea');
    } catch (e, st) {
      debugPrint('IsolateScreen error: $e\n$st');
      if (mounted) setState(() => _result = 'Error: $e');
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Isolate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Demo de Isolate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _running
                  ? null
                  : () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ejecutando isolate...')),
                      );
                      await _runIsolate();
                    },
              child: _running
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ejecutar Isolate'),
            ),
            const SizedBox(height: 12),
            Text('Resultado: $_result'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => context.go('/'), child: const Text('Volver al Home')),
          ],
        ),
      ),
    );
  }
}

// ================= FUNCIONES FUERA DE LA CLASE =================

// Trabajo pesado: heavyComputation ahora recibe un Map {input, iterations}
String heavyComputation(Map<String, dynamic> params) {
  final input = params['input'] as String? ?? 'sin input';
  final iterations = params['iterations'] as int? ?? 1;

  var sum = 0;
  // Tamaño interno por iteración. Ajusta si necesitas tests más pesados.
  const inner = 100000; // 100k
  for (var iter = 0; iter < iterations; iter++) {
    for (var i = 0; i < inner; i++) {
      sum += i % 3;
    }
  }

  return 'Hecho: $input - iteraciones=$iterations - sum=$sum';
}

// Nota: se usa `compute()` para ejecutar `heavyComputation` en otro isolate.
