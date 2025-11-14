import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({
    super.key,
    this.task,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isCompleted;
  DateTime? _dueDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  _titleController = TextEditingController(text: widget.task?.title ?? '');
  _descriptionController = TextEditingController(text: widget.task?.description ?? '');
  _isCompleted = widget.task?.completed ?? false;
  _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Editar tarea' : 'Nueva tarea'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de título
            Text(
              'Título de la tarea',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Escribe el título de tu tarea...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.task_alt),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 1,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            // Campo de descripción
            Text(
              'Descripción (opcional)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Agregar más detalles...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 3,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            // Selector de fecha
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? 'Sin fecha límite'
                        : 'Vence: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _isSubmitting ? null : _pickDueDate,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Seleccionar fecha'),
                ),
                if (_dueDate != null)
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _dueDate = null;
                            });
                          },
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Checkbox para marcar como completada (solo en edición)
            if (isEditMode) ...[
              CheckboxListTile(
                title: const Text('Marcar como completada'),
                value: _isCompleted,
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                      setState(() {
                        _isCompleted = value ?? false;
                      });
                    },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
            ],

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                        : Text(isEditMode ? 'Actualizar' : 'Crear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showErrorSnackbar('Por favor ingresa un título');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = context.read<TaskProvider>();

      if (widget.task != null) {
        // Editar tarea existente
        await provider.updateTask(
          widget.task!.id,
          title,
          _isCompleted,
          description: _descriptionController.text.trim(),
          dueDate: _dueDate,
        );
      } else {
        // Crear nueva tarea
        await provider.addTask(
          title,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dueDate: _dueDate,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        _showSuccessSnackbar(
          widget.task != null ? 'Tarea actualizada' : 'Tarea creada',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial = _dueDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
