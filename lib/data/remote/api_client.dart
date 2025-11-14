import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../models/task.dart';
import '../../models/task_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal();

  // Configurable API base URL (reemplazar con tu endpoint real)
  String baseUrl = 'http://localhost:3000/api';
  final Duration timeout = const Duration(seconds: 10);

  // Headers personalizados
  Map<String, String> _getHeaders(String requestId) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Request-ID': requestId,
      'Idempotency-Key': requestId,
    };
  }

  // ============ OPERACIONES CRUD ============

  Future<Task> getTask(String id, String requestId) async {
    try {
      debugPrint('[ApiClient] GET /tasks/$id');
      final response = await http
          .get(
            Uri.parse('$baseUrl/tasks/$id'),
            headers: _getHeaders(requestId),
          )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException(
          message: 'Tiempo de espera agotado al obtener tarea',
          originalException: 'HTTP GET timeout',
        );
      });

      return _handleResponse(response, requestId) as Task;
    } catch (e) {
      debugPrint('[ApiClient] Error en GET /tasks/$id: $e');
      rethrow;
    }
  }

  Future<List<Task>> getTasks(String requestId) async {
    try {
      debugPrint('[ApiClient] GET /tasks');
      final response = await http
          .get(
            Uri.parse('$baseUrl/tasks'),
            headers: _getHeaders(requestId),
          )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException(
          message: 'Tiempo de espera agotado al obtener tareas',
          originalException: 'HTTP GET timeout',
        );
      });

      final parsed = _handleResponse(response, requestId);
      if (parsed is List) {
        return parsed
            .map((item) => Task.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ApiClient] Error en GET /tasks: $e');
      rethrow;
    }
  }

  Future<Task> createTask(Task task, String requestId) async {
    try {
      debugPrint('[ApiClient] POST /tasks - ${task.title}');
      final response = await http
          .post(
            Uri.parse('$baseUrl/tasks'),
            headers: _getHeaders(requestId),
            body: jsonEncode(task.toJson()),
          )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException(
          message: 'Tiempo de espera agotado al crear tarea',
          originalException: 'HTTP POST timeout',
        );
      });

      final parsed = _handleResponse(response, requestId);
      return Task.fromJson(parsed as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[ApiClient] Error en POST /tasks: $e');
      rethrow;
    }
  }

  Future<Task> updateTask(Task task, String requestId) async {
    try {
      debugPrint('[ApiClient] PUT /tasks/${task.id}');
      final response = await http
          .put(
            Uri.parse('$baseUrl/tasks/${task.id}'),
            headers: _getHeaders(requestId),
            body: jsonEncode(task.toJson()),
          )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException(
          message: 'Tiempo de espera agotado al actualizar tarea',
          originalException: 'HTTP PUT timeout',
        );
      });

      final parsed = _handleResponse(response, requestId);
      return Task.fromJson(parsed as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[ApiClient] Error en PUT /tasks/${task.id}: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id, String requestId) async {
    try {
      debugPrint('[ApiClient] DELETE /tasks/$id');
      final response = await http
          .delete(
            Uri.parse('$baseUrl/tasks/$id'),
            headers: _getHeaders(requestId),
          )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException(
          message: 'Tiempo de espera agotado al eliminar tarea',
          originalException: 'HTTP DELETE timeout',
        );
      });

      _handleResponse(response, requestId);
    } catch (e) {
      debugPrint('[ApiClient] Error en DELETE /tasks/$id: $e');
      rethrow;
    }
  }

  // ============ MANEJO DE RESPUESTAS ============

  dynamic _handleResponse(http.Response response, String requestId) {
    debugPrint('[ApiClient] Response status: ${response.statusCode}');

    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return null;
        }
        return jsonDecode(response.body);
      } else if (response.statusCode == 408) {
        throw TimeoutException(
          message: 'Servidor no respondió a tiempo (408)',
          originalException: response.body,
        );
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final errorBody = _parseErrorBody(response.body);
        throw SyncException(
          message: errorBody,
          statusCode: response.statusCode,
          originalException: response.body,
        );
      } else if (response.statusCode >= 500) {
        throw SyncException(
          message: 'Error del servidor: ${response.statusCode}',
          statusCode: response.statusCode,
          originalException: response.body,
        );
      } else {
        throw SyncException(
          message: 'Error desconocido: ${response.statusCode}',
          statusCode: response.statusCode,
          originalException: response.body,
        );
      }
    } catch (e) {
      if (e is TaskException) {
        rethrow;
      }
      throw NetworkException(
        message: 'Error procesando respuesta: $e',
        originalException: e,
      );
    }
  }

  String _parseErrorBody(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map && json.containsKey('message')) {
        return json['message'] as String;
      }
      return body;
    } catch (_) {
      return body;
    }
  }

  // ============ UTILITARIOS ============

  void setBaseUrl(String url) {
    baseUrl = url;
    debugPrint('[ApiClient] Base URL actualizado a: $url');
  }
}
