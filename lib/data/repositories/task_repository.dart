import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../models/task.dart';
import '../../models/task_exception.dart';
import '../../models/queue_operation.dart';
import '../local/database_helper.dart';
import '../remote/api_client.dart';

class TaskRepository {
  static final TaskRepository _instance = TaskRepository._internal();

  factory TaskRepository() {
    return _instance;
  }

  TaskRepository._internal();

  final DatabaseHelper _db = DatabaseHelper();
  final ApiClient _api = ApiClient();
  final Connectivity _connectivity = Connectivity();
  final _uuid = const Uuid();

  // ============ OPERACIONES DE LECTURA (Offline-First) ============

  /// Obtiene tareas del repositorio local.
  /// Si está en línea, sincroniza en background.
  Future<List<Task>> getTasks() async {
    try {
      debugPrint('[TaskRepository] Obteniendo tareas...');
      // Leer del local inmediatamente
      final localTasks = await _db.getTasks();
      debugPrint('[TaskRepository] Tareas locales obtenidas: ${localTasks.length}');

      // Si está en línea, sincronizar en background
      final isOnline = await _isOnline();
      if (isOnline) {
        _syncTasksInBackground();
      }

      return localTasks;
    } catch (e) {
      debugPrint('[TaskRepository] Error obteniendo tareas: $e');
      rethrow;
    }
  }

  // ============ OPERACIONES DE ESCRITURA (Write-Through + Queue) ============

  /// Crea una tarea en local y la encola para sincronización.
  Future<Task> createTask(String title, {String? description, DateTime? dueDate}) async {
    try {
      if (title.trim().isEmpty) {
        throw ValidationException(
          message: 'El título no puede estar vacío',
          originalException: null,
        );
      }

      debugPrint('[TaskRepository] Creando tarea: $title');

      final taskId = _uuid.v4();
      final now = DateTime.now();
      final task = Task(
        id: taskId,
        title: title.trim(),
        description: description,
        completed: false,
        updatedAt: now,
        dueDate: dueDate,
      );

      // 1. Guardar en local
      await _db.createTask(task);
      debugPrint('[TaskRepository] Tarea guardada localmente: $taskId');

      // 2. Encolar para sincronizar
      final requestId = _uuid.v4();
      await _queueOperation(
        entity: 'task',
        entityId: taskId,
        operation: QueueOperationType.create,
        payload: task.toJson(),
        requestId: requestId,
      );

      // 3. Intentar sincronizar si está en línea
      final isOnline = await _isOnline();
      if (isOnline) {
        _syncQueueInBackground();
      }

      return task;
    } catch (e) {
      debugPrint('[TaskRepository] Error creando tarea: $e');
      rethrow;
    }
  }

  /// Actualiza una tarea en local y la encola para sincronización.
  Future<Task> updateTask(String id, String title, bool completed, {String? description, DateTime? dueDate}) async {
    try {
      if (title.trim().isEmpty) {
        throw ValidationException(
          message: 'El título no puede estar vacío',
          originalException: null,
        );
      }

      debugPrint('[TaskRepository] Actualizando tarea: $id');

      final existingTask = await _db.getTask(id);
      if (existingTask == null) {
        throw ValidationException(
          message: 'Tarea no encontrada: $id',
          originalException: null,
        );
      }

      final updatedTask = existingTask.copyWith(
        title: title.trim(),
        description: description ?? existingTask.description,
        completed: completed,
        updatedAt: DateTime.now(),
        dueDate: dueDate ?? existingTask.dueDate,
      );

      // 1. Actualizar en local
      await _db.updateTask(updatedTask);
      debugPrint('[TaskRepository] Tarea actualizada localmente: $id');

      // 2. Encolar para sincronizar
      final requestId = _uuid.v4();
      await _queueOperation(
        entity: 'task',
        entityId: id,
        operation: QueueOperationType.update,
        payload: updatedTask.toJson(),
        requestId: requestId,
      );

      // 3. Intentar sincronizar si está en línea
      final isOnline = await _isOnline();
      if (isOnline) {
        _syncQueueInBackground();
      }

      return updatedTask;
    } catch (e) {
      debugPrint('[TaskRepository] Error actualizando tarea: $e');
      rethrow;
    }
  }

  /// Elimina una tarea (soft delete) y la encola para sincronización.
  Future<void> deleteTask(String id) async {
    try {
      debugPrint('[TaskRepository] Eliminando tarea: $id');

      final existingTask = await _db.getTask(id);
      if (existingTask == null) {
         throw ValidationException(
           message: 'Tarea no encontrada: $id',
           originalException: null,
         );
      }

      // 1. Soft delete en local
      await _db.softDeleteTask(id);
      debugPrint('[TaskRepository] Tarea eliminada localmente: $id');

      // 2. Encolar para sincronizar
      final requestId = _uuid.v4();
      await _queueOperation(
        entity: 'task',
        entityId: id,
        operation: QueueOperationType.delete,
        payload: {'id': id},
        requestId: requestId,
      );

      // 3. Intentar sincronizar si está en línea
      final isOnline = await _isOnline();
      if (isOnline) {
        _syncQueueInBackground();
      }
    } catch (e) {
      debugPrint('[TaskRepository] Error eliminando tarea: $e');
      rethrow;
    }
  }

  // ============ SINCRONIZACIÓN ============

  /// Sincroniza todas las operaciones pendientes en la cola.
  Future<void> syncQueue() async {
    try {
      final isOnline = await _isOnline();
      if (!isOnline) {
        debugPrint('[TaskRepository] No hay conexión. Sincronización pospuesta.');
        return;
      }

      debugPrint('[TaskRepository] Iniciando sincronización de cola...');
      final operations = await _db.getQueueOperations();
      debugPrint('[TaskRepository] ${operations.length} operaciones en cola');

      for (final op in operations) {
        await _processQueueOperation(op);
      }

      debugPrint('[TaskRepository] Sincronización completada');
    } catch (e) {
      debugPrint('[TaskRepository] Error sincronizando cola: $e');
      rethrow;
    }
  }

  /// Procesa una operación individual de la cola con reintentos.
  Future<void> _processQueueOperation(QueueOperation operation) async {
    try {
      debugPrint(
        '[TaskRepository] Procesando operación: ${operation.id} (${operation.operation.name})',
      );

      final maxAttempts = 3;
      if (operation.attemptCount >= maxAttempts) {
        debugPrint(
          '[TaskRepository] Operación excedió reintentos: ${operation.id}',
        );
        return;
      }

      final task = Task.fromJson(operation.payload);

      switch (operation.operation) {
        case QueueOperationType.create:
          await _api.createTask(task, operation.id);
          break;
        case QueueOperationType.update:
          await _api.updateTask(task, operation.id);
          break;
        case QueueOperationType.delete:
          await _api.deleteTask(task.id, operation.id);
          break;
      }

      // Si tuvo éxito, eliminar de la cola
      await _db.removeQueueOperation(operation.id);
      debugPrint('[TaskRepository] Operación completada y removida: ${operation.id}');
    } catch (e) {
      // Registrar el error y incrementar reintentos
      await _db.updateQueueOperationError(
        operation.id,
        e.toString(),
      );
      debugPrint('[TaskRepository] Error en operación ${operation.id}: $e');
      // No relanzar para continuar con siguientes operaciones
    }
  }

  // ============ UTILIDADES ============

  /// Encola una operación para sincronización posterior.
  Future<void> _queueOperation({
    required String entity,
    required String entityId,
    required QueueOperationType operation,
    required Map<String, dynamic> payload,
    required String requestId,
  }) async {
    try {
      final queueOp = QueueOperation(
        id: requestId,
        entity: entity,
        entityId: entityId,
        operation: operation,
        payload: payload,
        createdAt: DateTime.now(),
      );

      await _db.addQueueOperation(queueOp);
      debugPrint('[TaskRepository] Operación encolada: ${queueOp.id}');
    } catch (e) {
      debugPrint('[TaskRepository] Error encolando operación: $e');
      rethrow;
    }
  }

  /// Verifica si hay conexión a internet.
  Future<bool> _isOnline() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final online = result != ConnectivityResult.none;
      debugPrint('[TaskRepository] Estado de conexión: ${online ? 'En línea' : 'Sin conexión'}');
      return online;
    } catch (e) {
      debugPrint('[TaskRepository] Error verificando conexión: $e');
      return false;
    }
  }

  /// Sincroniza tareas en background (no bloquea al usuario).
  void _syncTasksInBackground() {
    debugPrint('[TaskRepository] Sincronizando tareas en background...');
    // Ejecutar de forma asíncrona sin esperar
    Future.microtask(() async {
      try {
        // Aquí iría lógica de refresh de API si necesario
        // Por ahora solo sincronizar la cola
        await syncQueue();
      } catch (e) {
        debugPrint('[TaskRepository] Error en sync de background: $e');
      }
    });
  }

  /// Sincroniza la cola en background.
  void _syncQueueInBackground() {
    debugPrint('[TaskRepository] Sincronizando cola en background...');
    Future.microtask(() async {
      try {
        await syncQueue();
      } catch (e) {
        debugPrint('[TaskRepository] Error en sync de cola en background: $e');
      }
    });
  }

  /// Limpia la base de datos (útil para pruebas).
  Future<void> clearDatabase() async {
    await _db.clearDatabase();
  }
}
