import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CicloVidaScreen extends StatefulWidget {
  const CicloVidaScreen({super.key});

  @override
  State<CicloVidaScreen> createState() => _CicloVidaScreenState();
}

class _CicloVidaScreenState extends State<CicloVidaScreen> {
  bool _showChild = true;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    print("CicloVidaScreen.initState(): se ejecuta una vez al crear el widget");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("CicloVidaScreen.didChangeDependencies(): cambian dependencias de contexto");
  }

  @override
  Widget build(BuildContext context) {
    print("CicloVidaScreen.build(): se ejecuta cada vez que el widget se construye");
    return Scaffold(
      appBar: AppBar(title: const Text("Ciclo de Vida")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen de cabecera profesional
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=1400&q=80&auto=format&fit=crop',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estado del Demo', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Counter: $_counter', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Forzar setState'),
                            onPressed: () {
                              setState(() {
                                _counter++;
                                print('setState(): contador incrementado a $_counter');
                              });
                            },
                          ),
                          ElevatedButton.icon(
                            icon: Icon(_showChild ? Icons.visibility_off : Icons.visibility),
                            label: Text(_showChild ? 'Ocultar Child' : 'Mostrar Child'),
                            onPressed: () {
                              setState(() {
                                _showChild = !_showChild;
                                print(_showChild
                                    ? 'Toggle: mostrando el child (se ejecutará initState del child)'
                                    : 'Toggle: ocultando el child (se ejecutará dispose del child)');
                              });
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.sync),
                            label: const Text('Simular didChangeDependencies'),
                            onPressed: () {
                              print('Simulación: didChangeDependencies() - acción manual');
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Push nueva pantalla'),
                            onPressed: () async {
                              print('Navegación: push a pantalla temporal');
                              await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                                return Scaffold(
                                  appBar: AppBar(title: const Text('Pantalla temporal')),
                                  body: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('Presiona atrás para volver'),
                                        const SizedBox(height: 12),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.arrow_back),
                                          label: const Text('Regresar (pop)'),
                                          onPressed: () => Navigator.of(context).pop(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }));
                              print('Regresó de la pantalla temporal');
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_back_ios),
                            label: const Text('Regresar (pop)'),
                            onPressed: () {
                              // Intentar cerrar la pantalla actual
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                                print('Acción: pop() ejecutado');
                              } else {
                                print('Acción: no hay pantalla anterior para pop()');
                              }
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.home),
                            label: const Text('Ir a Home'),
                            onPressed: () {
                              // Usar go_router si está disponible
                              try {
                                context.go('/');
                                print('Acción: context.go(/) ejecutado');
                              } catch (e) {
                                // fallback a Navigator
                                print('go_router no disponible, fallback a popUntil');
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_showChild) const LifecycleChild(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("CicloVidaScreen.dispose(): se ejecuta al destruir el widget");
    super.dispose();
  }
}

class LifecycleChild extends StatefulWidget {
  const LifecycleChild({Key? key}) : super(key: key);

  @override
  State<LifecycleChild> createState() => _LifecycleChildState();
}

class _LifecycleChildState extends State<LifecycleChild> {
  @override
  void initState() {
    super.initState();
    print('LifecycleChild.initState()');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('LifecycleChild.didChangeDependencies()');
  }

  @override
  void didUpdateWidget(covariant LifecycleChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('LifecycleChild.didUpdateWidget()');
  }

  @override
  Widget build(BuildContext context) {
    print('LifecycleChild.build()');
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=400&q=80&auto=format&fit=crop',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Soy un child con logs de ciclo de vida', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Ocúltame/muéstrame para ver initState/dispose'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    print('LifecycleChild.deactivate()');
  }

  @override
  void dispose() {
    print('LifecycleChild.dispose()');
    super.dispose();
  }
}
