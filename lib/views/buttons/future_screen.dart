import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FutureScreen extends StatefulWidget {
  const FutureScreen({super.key});

  @override
  State<FutureScreen> createState() => _FutureScreenState();
}

class _FutureScreenState extends State<FutureScreen> {
  bool _loading = false;
  String _status = 'Inactivo';

  Future<String> _fakeNetworkCall({bool fail = false}) async {
    debugPrint('FutureScreen: dentro de _fakeNetworkCall (durante)');
    await Future.delayed(const Duration(seconds: 2));
    if (fail) {
      debugPrint('FutureScreen: _fakeNetworkCall lanzando excepción (simulada)');
      throw Exception('Error simulado en _fakeNetworkCall');
    }
    debugPrint('FutureScreen: finalizando _fakeNetworkCall (antes de retornar)');
    return 'Resultado de Future';
  }

  Future<void> _run({bool forceError = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _status = 'Cargando...';
    });
    debugPrint('FutureScreen: antes de llamar al Future (inicio)');
    try {
      final result = await _fakeNetworkCall(fail: forceError);
      debugPrint('FutureScreen: resultado -> $result (después)');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
        setState(() => _status = 'Éxito');
      }
    } catch (e, s) {
      debugPrint('FutureScreen: error $e\n$s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _status = 'Error');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Future')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Demo de Future', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Estado: $_status'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : () => _run(forceError: false),
              child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Ejecutar Future'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loading ? null : () => _run(forceError: true),
              child: const Text('Forzar error (simulado)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/'),
              child: const Text('Volver al Home'),
            ),
          ],
        ),
      ),
    );
  }
}
