import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/task.dart';
import '../models/task_exception.dart';
import '../data/repositories/task_repository.dart';
import 'dart:math';

enum TaskFilter {
  all,
  pending,
  completed,
}

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class TaskProvider extends ChangeNotifier {
  static final TaskProvider _instance = TaskProvider._internal();

  factory TaskProvider() {
    return _instance;
  }

  TaskProvider._internal() {
    _repository = TaskRepository();
    _connectivity = Connectivity();
    _listenToConnectivity();
  }

  late final TaskRepository _repository;
  late final Connectivity _connectivity;

  // ============ ESTADO ============

  List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  SyncStatus _syncStatus = SyncStatus.idle;
  String? _errorMessage;
  bool _isLoading = false;

  // ============ GETTERS ============

  List<Task> get tasks => _tasks;

  List<Task> get filteredTasks {
    switch (_filter) {
      case TaskFilter.all:
        return _tasks;
      case TaskFilter.pending:
        return _tasks.where((t) => !t.completed).toList();
      case TaskFilter.completed:
        return _tasks.where((t) => t.completed).toList();
    }
  }

  TaskFilter get filter => _filter;
  SyncStatus get syncStatus => _syncStatus;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  int get pendingCount => _tasks.where((t) => !t.completed).length;
  int get completedCount => _tasks.where((t) => t.completed).length;

  // ============ MÉTODOS DE CARGA ============

  Future<void> loadTasks() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _tasks = await _repository.getTasks();
      debugPrint('[TaskProvider] ${_tasks.length} tareas cargadas');

      notifyListeners();
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('[TaskProvider] Error cargando tareas: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ MÉTODOS DE CRUD ============

  Future<void> addTask(String title, {String? description, DateTime? dueDate}) async {
    try {
      _errorMessage = null;
      // Crear un task temporal y mostrarlo inmediatamente
      final tempId = 'tmp-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';
      final now = DateTime.now();
      final tempTask = Task(
        id: tempId,
        title: title.trim(),
        description: description,
        completed: false,
        updatedAt: now,
        dueDate: dueDate,
      );

      _tasks.insert(0, tempTask);
      debugPrint('[TaskProvider] Tarea temporal agregada: $tempId');
      notifyListeners();

      // Sincronizar en background: crear en repo y reemplazar la tarea temporal por la real
  Future.microtask(() async {
        try {
          final created = await _repository.createTask(title, description: description, dueDate: dueDate);
          final idx = _tasks.indexWhere((t) => t.id == tempId);
          if (idx != -1) {
            _tasks[idx] = created;
            debugPrint('[TaskProvider] Tarea temporal reemplazada por persistida: ${created.id}');
            notifyListeners();
          } else {
            // si ya no existe, insertar al inicio
            _tasks.insert(0, created);
            notifyListeners();
          }
        } catch (e) {
          debugPrint('[TaskProvider] Error sincronizando creación: $e');
        }
  });
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('[TaskProvider] Error agregando tarea: $e');
      notifyListeners();
    }
  }

  Future<void> updateTask(String id, String title, bool completed, {String? description, DateTime? dueDate}) async {
    try {
      _errorMessage = null;
      // Actualizar localmente de forma optimista
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        final existing = _tasks[index];
        final updated = existing.copyWith(
          title: title.trim(),
          description: description ?? existing.description,
          completed: completed,
          updatedAt: DateTime.now(),
          dueDate: dueDate ?? existing.dueDate,
        );
        _tasks[index] = updated;
        notifyListeners();
      }

      // Si la tarea es temporal, no intentar actualizar en el repo
      if (id.startsWith('tmp-')) return;

      // Sincronizar en background
  Future.microtask(() async {
        try {
          final updatedTask = await _repository.updateTask(id, title, completed, description: description, dueDate: dueDate);
          final idx2 = _tasks.indexWhere((t) => t.id == id);
          if (idx2 != -1) {
            _tasks[idx2] = updatedTask;
            notifyListeners();
          }
        } catch (e) {
          debugPrint('[TaskProvider] Error sincronizando actualización: $e');
        }
  });
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('[TaskProvider] Error actualizando tarea: $e');
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      _errorMessage = null;
      // Remover localmente inmediatamente
      _tasks.removeWhere((t) => t.id == id);
      debugPrint('[TaskProvider] Tarea eliminada localmente: $id');
      notifyListeners();

      // Si era temporal no sincronizamos con el repo
      if (id.startsWith('tmp-')) return;

      // Sincronizar eliminación en background
  Future.microtask(() async {
        try {
          await _repository.deleteTask(id);
          debugPrint('[TaskProvider] Tarea eliminada en repo: $id');
        } catch (e) {
          debugPrint('[TaskProvider] Error sincronizando eliminación: $e');
        }
  });
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('[TaskProvider] Error eliminando tarea: $e');
      notifyListeners();
    }
  }

  // ============ MÉTODOS DE FILTRO ============

  void setFilter(TaskFilter filter) {
    _filter = filter;
    debugPrint('[TaskProvider] Filtro cambiado a: ${filter.name}');
    notifyListeners();
  }

  // ============ MÉTODOS DE SINCRONIZACIÓN ============

  Future<void> sync() async {
    try {
      _syncStatus = SyncStatus.syncing;
      _errorMessage = null;
      notifyListeners();

      await _repository.syncQueue();
      
      // Recargar tareas después de sincronizar
      _tasks = await _repository.getTasks();

      _syncStatus = SyncStatus.success;
      debugPrint('[TaskProvider] Sincronización completada');
      notifyListeners();

      // Mostrar success por poco tiempo
      await Future.delayed(const Duration(seconds: 2));
      _syncStatus = SyncStatus.idle;
      notifyListeners();
    } catch (e) {
      _syncStatus = SyncStatus.error;
      _errorMessage = _getErrorMessage(e);
      debugPrint('[TaskProvider] Error sincronizando: $e');
      notifyListeners();
    }
  }

  // ============ MONITOREO DE CONEXIÓN ============

  void _listenToConnectivity() {
    _connectivity.onConnectivityChanged.listen((result) {
      final isOnline = result != ConnectivityResult.none;
      debugPrint('[TaskProvider] Conectividad cambió: ${isOnline ? 'En línea' : 'Sin conexión'}');

      // Si reconectó, sincronizar
      if (isOnline && _syncStatus != SyncStatus.syncing) {
        debugPrint('[TaskProvider] Reconexión detectada. Sincronizando...');
        sync();
      }
    });
  }

  // ============ UTILIDADES ============

  String _getErrorMessage(dynamic exception) {
    if (exception is TaskException) {
      return exception.message;
    }
    return 'Error desconocido: $exception';
  }

  Future<void> clearDatabase() async {
    await _repository.clearDatabase();
    _tasks.clear();
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('[TaskProvider] Provider eliminado');
  }
}
