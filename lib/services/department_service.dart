import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/department.dart';

class DepartmentService {
  final String baseUrl;

  DepartmentService({required this.baseUrl});

  Future<List<Department>> fetchDepartments() async {
    final uri = Uri.parse('$baseUrl/api/v1/Department');
    debugPrint('DepartmentService: GET $uri');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      try {
        final decoded = json.decode(res.body);
        // Respuesta puede ser { data: [...] } o una lista directa
        final List<dynamic> list = (decoded is Map && decoded['data'] is List) ? decoded['data'] : (decoded is List ? decoded : []);
        final items = <Department>[];
        for (final e in list) {
          if (e is Map<String, dynamic>) {
            try {
              items.add(Department.fromJson(e));
            } catch (err) {
              debugPrint('DepartmentService: fallo al parsear item: $err');
            }
          } else {
            debugPrint('DepartmentService: elemento ignorado no es Map: ${e.runtimeType}');
          }
        }
        debugPrint('DepartmentService: items parseados=${items.length}');
        return items;
      } catch (err) {
        throw Exception('Error decoding departments JSON: $err');
      }
    } else {
      throw Exception('Error fetching departments: ${res.statusCode}');
    }
  }

  Future<Department> fetchDepartmentById(int id) async {
    final uri = Uri.parse('$baseUrl/api/v1/Department/$id');
    debugPrint('DepartmentService: GET $uri');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      try {
        final decoded = json.decode(res.body);
        final Map<String, dynamic>? map = (decoded is Map && decoded['data'] is Map)
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map<String, dynamic> ? decoded : null);
        if (map == null) throw Exception('No department object in response');
        return Department.fromJson(map);
      } catch (err) {
        throw Exception('Error decoding department JSON: $err');
      }
    } else {
      throw Exception('Error fetching department $id: ${res.statusCode}');
    }
  }
}
