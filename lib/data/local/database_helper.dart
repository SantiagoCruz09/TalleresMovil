import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

import '../../models/task.dart';
import '../../models/queue_operation.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    debugPrint('[DatabaseHelper] Inicializando base de datos...');
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        debugPrint('[DatabaseHelper] onUpgrade from $oldVersion to $newVersion');
        if (oldVersion < 2) {
          try {
            await db.execute('ALTER TABLE tasks ADD COLUMN description TEXT');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE tasks ADD COLUMN due_date TEXT');
          } catch (_) {}
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('[DatabaseHelper] Creando tablas...');

    // Tabla de tareas
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        completed INTEGER DEFAULT 0,
        updated_at TEXT NOT NULL,
        due_date TEXT,
        deleted INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla de cola de sincronización
    await db.execute('''
      CREATE TABLE queue_operations (
        id TEXT PRIMARY KEY,
        entity TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        op TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        attempt_count INTEGER DEFAULT 0,
        last_error TEXT
      )
    ''');

    debugPrint('[DatabaseHelper] Tablas creadas exitosamente');
  }

  // ============ OPERACIONES DE TAREAS ============

  Future<List<Task>> getTasks() async {
    try {
      final db = await database;
      final maps = await db.query(
        'tasks',
        where: 'deleted = 0',
        orderBy: 'created_at DESC',
      );
      return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    } catch (e) {
      debugPrint('[DatabaseHelper] Error obteniendo tareas: $e');
      rethrow;
    }
  }

  Future<Task?> getTask(String id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'tasks',
        where: 'id = ? AND deleted = 0',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Task.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('[DatabaseHelper] Error obteniendo tarea $id: $e');
      rethrow;
    }
  }

  Future<String> createTask(Task task) async {
    try {
      final db = await database;
      await db.insert('tasks', {
        ...task.toMap(),
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('[DatabaseHelper] Tarea creada: ${task.id}');
      return task.id;
    } catch (e) {
      debugPrint('[DatabaseHelper] Error creando tarea: $e');
      rethrow;
    }
  }

  Future<int> updateTask(Task task) async {
    try {
      final db = await database;
      final result = await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
      debugPrint('[DatabaseHelper] Tarea actualizada: ${task.id}');
      return result;
    } catch (e) {
      debugPrint('[DatabaseHelper] Error actualizando tarea: $e');
      rethrow;
    }
  }

  Future<int> softDeleteTask(String id) async {
    try {
      final db = await database;
      final result = await db.update(
        'tasks',
        {
          'deleted': 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('[DatabaseHelper] Tarea eliminada (soft): $id');
      return result;
    } catch (e) {
      debugPrint('[DatabaseHelper] Error eliminando tarea: $e');
      rethrow;
    }
  }

  // ============ OPERACIONES DE COLA DE SINCRONIZACIÓN ============

  Future<String> addQueueOperation(QueueOperation operation) async {
    try {
      final db = await database;
      final map = operation.toMap();
      await db.insert('queue_operations', map);
      debugPrint('[DatabaseHelper] Operación encolada: ${operation.id}');
      return operation.id;
    } catch (e) {
      debugPrint('[DatabaseHelper] Error encolando operación: $e');
      rethrow;
    }
  }

  Future<List<QueueOperation>> getQueueOperations() async {
    try {
      final db = await database;
      final maps = await db.query(
        'queue_operations',
        orderBy: 'created_at ASC',
      );
      return List.generate(
        maps.length,
        (i) => QueueOperation.fromMap(maps[i]),
      );
    } catch (e) {
      debugPrint('[DatabaseHelper] Error obteniendo cola: $e');
      rethrow;
    }
  }

  Future<int> removeQueueOperation(String id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'queue_operations',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('[DatabaseHelper] Operación removida de cola: $id');
      return result;
    } catch (e) {
      debugPrint('[DatabaseHelper] Error removiendo operación: $e');
      rethrow;
    }
  }

  Future<int> updateQueueOperationError(
    String id,
    String errorMessage,
  ) async {
    try {
      final db = await database;
      // Primero obtener el count actual
      final maps = await db.query(
        'queue_operations',
        columns: ['attempt_count'],
        where: 'id = ?',
        whereArgs: [id],
      );
      int currentCount = 0;
      if (maps.isNotEmpty) {
        currentCount = (maps.first['attempt_count'] as int?) ?? 0;
      }
      
      final result = await db.update(
        'queue_operations',
        {
          'last_error': errorMessage,
          'attempt_count': currentCount + 1,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('[DatabaseHelper] Error registrado en operación: $id');
      return result;
    } catch (e) {
      debugPrint('[DatabaseHelper] Error actualizando operación: $e');
      rethrow;
    }
  }

  // ============ UTILIDADES ============

  Future<void> clearDatabase() async {
    try {
      final db = await database;
      await db.delete('queue_operations');
      await db.delete('tasks');
      debugPrint('[DatabaseHelper] Base de datos limpiada');
    } catch (e) {
      debugPrint('[DatabaseHelper] Error limpiando base de datos: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      debugPrint('[DatabaseHelper] Base de datos cerrada');
    }
  }
}
