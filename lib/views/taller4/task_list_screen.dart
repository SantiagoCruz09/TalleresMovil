import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import 'task_form_screen.dart';
import 'widgets/task_item.dart';
import 'widgets/sync_indicator.dart';
import 'widgets/filter_chips.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar tareas al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TaskProvider>().loadTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.primaryColor.withAlpha((0.06 * 255).round()),
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text('Mi Lista de Tareas'),
        elevation: 0,
        actions: [
          // Color selector
          PopupMenuButton<Color>(
            tooltip: 'Cambiar color de la página',
            icon: const Icon(Icons.palette),
            onSelected: (color) => context.read<ThemeProvider>().setColor(color),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: Colors.indigo,
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.indigo, radius: 10),
                    const SizedBox(width: 8),
                    const Text('Indigo'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: Colors.green,
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.green, radius: 10),
                    const SizedBox(width: 8),
                    const Text('Green'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: Colors.purple,
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.purple, radius: 10),
                    const SizedBox(width: 8),
                    const Text('Purple'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: Colors.orange,
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.orange, radius: 10),
                    const SizedBox(width: 8),
                    const Text('Orange'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: Colors.teal,
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.teal, radius: 10),
                    const SizedBox(width: 8),
                    const Text('Teal'),
                  ],
                ),
              ),
            ],
          ),

          Consumer<TaskProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    '${provider.pendingCount} pendientes',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de sincronización
          const SyncIndicator(),
          
          // Chips de filtro
          const FilterChips(),
          
          // Lista de tareas
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.tasks.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checklist_rtl,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay tareas',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crea una nueva tarea para comenzar',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                        ),
                      ],
                    ),
                  );
                }

                final filteredTasks = provider.filteredTasks;

                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay tareas en esta categoría',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return TaskItem(
                      task: task,
                      onEdit: () => _openTaskForm(context, task),
                      onDelete: () => _confirmDelete(context, task),
                      onToggle: () => _toggleTask(context, task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar tarea',
        onPressed: () => _openTaskForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openTaskForm(BuildContext context, Task? task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );
  }

  void _toggleTask(BuildContext context, Task task) {
    final provider = context.read<TaskProvider>();
    provider.updateTask(
      task.id,
      task.title,
      !task.completed,
      description: task.description,
      dueDate: task.dueDate,
    );
  }

  void _confirmDelete(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Deseas eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
