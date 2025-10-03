import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _running = false; // true cuando el timer está activo
  bool _paused = false; // true si se pausó

  // Intervalo de actualización: 100 ms para mayor fluidez
  static const int _tickMs = 100;

  void _start() {
    // iniciar desde 0
    _timer?.cancel();
    _elapsed = Duration.zero;
    _running = true;
    _paused = false;
    debugPrint('TimerScreen: iniciar cronómetro');
    _timer = Timer.periodic(const Duration(milliseconds: _tickMs), (t) {
      _tick();
    });
    setState(() {});
  }

  void _tick() {
    // actualizar elapsed de forma acumulativa
    _elapsed += Duration(milliseconds: _tickMs);
    if (mounted) setState(() {});
    debugPrint('TimerScreen: tick ${_elapsed.inMilliseconds} ms');
  }

  void _pause() {
    if (!_running) return;
    debugPrint('TimerScreen: pausar (elapsed=${_elapsed.inMilliseconds} ms)');
    _timer?.cancel();
    _timer = null;
    _running = false;
    _paused = true;
    if (mounted) setState(() {});
  }

  void _resume() {
    if (_running || !_paused) return;
    debugPrint('TimerScreen: reanudar (elapsed=${_elapsed.inMilliseconds} ms)');
    _running = true;
    _paused = false;
    _timer = Timer.periodic(const Duration(milliseconds: _tickMs), (t) => _tick());
    if (mounted) setState(() {});
  }

  void _reset() {
    debugPrint('TimerScreen: reiniciar cronómetro');
    _timer?.cancel();
    _timer = null;
    _elapsed = Duration.zero;
    _running = false;
    _paused = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    debugPrint('TimerScreen: dispose - cancelando timer');
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final centis = (d.inMilliseconds.remainder(1000) / 10).floor().toString().padLeft(2, '0');
    return '$minutes:$seconds.$centis';
  }

  @override
  Widget build(BuildContext context) {
    final display = _formatDuration(_elapsed);
    return Scaffold(
      appBar: AppBar(title: const Text('Cronómetro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Cronómetro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Center(
              child: Text(
                display,
                style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w700, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_running && !_paused)
                  ElevatedButton(onPressed: _start, child: const Text('Iniciar')),
                if (_running) ...[
                  ElevatedButton(onPressed: _pause, child: const Text('Pausar')),
                  const SizedBox(width: 12),
                ],
                if (_paused) ...[
                  ElevatedButton(onPressed: _resume, child: const Text('Reanudar')),
                  const SizedBox(width: 12),
                ],
                OutlinedButton(onPressed: _reset, child: const Text('Reiniciar')),
              ],
            ),
            const SizedBox(height: 12),
            Center(child: Text('Estado: ${_running ? 'En ejecución' : _paused ? 'Pausado' : 'Detenido'}')),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => context.go('/'), child: const Text('Volver al Home')),
          ],
        ),
      ),
    );
  }
}
