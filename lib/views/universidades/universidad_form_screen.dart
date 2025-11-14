import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/universidad.dart';
import '../../services/universidad_service.dart';

class UniversidadFormScreen extends StatefulWidget {
  final String? id;
  const UniversidadFormScreen({super.key, this.id});

  @override
  State<UniversidadFormScreen> createState() => _UniversidadFormScreenState();
}

class _UniversidadFormScreenState extends State<UniversidadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nitCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _paginaCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final u = await UniversidadService.instance.getById(widget.id!);
      _nitCtrl.text = u.nit;
      _nombreCtrl.text = u.nombre;
      _direccionCtrl.text = u.direccion;
      _telefonoCtrl.text = u.telefono;
      _paginaCtrl.text = u.paginaWeb;
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text('Error cargando: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nitCtrl.dispose();
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _paginaCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final u = Universidad(
      id: widget.id,
      nit: _nitCtrl.text.trim(),
      nombre: _nombreCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      paginaWeb: _paginaCtrl.text.trim(),
    );
    try {
      if (widget.id == null) {
        await UniversidadService.instance.addUniversidad(u);
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(const SnackBar(content: Text('Universidad creada')));
        }
      } else {
        await UniversidadService.instance.updateUniversidad(u);
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(const SnackBar(content: Text('Universidad actualizada')));
        }
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(SnackBar(content: Text('Error guardando: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Universidad' : 'Nueva Universidad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nitCtrl,
                        decoration: const InputDecoration(labelText: 'NIT'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'NIT requerido' : null,
                      ),
                      TextFormField(
                        controller: _nombreCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Nombre requerido' : null,
                      ),
                      TextFormField(
                        controller: _direccionCtrl,
                        decoration: const InputDecoration(labelText: 'Dirección'),
                      ),
                      TextFormField(
                        controller: _telefonoCtrl,
                        decoration: const InputDecoration(labelText: 'Teléfono'),
                      ),
                      TextFormField(
                        controller: _paginaCtrl,
                        decoration: const InputDecoration(labelText: 'Página web'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: _save, child: Text(isEdit ? 'Actualizar' : 'Crear')),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
