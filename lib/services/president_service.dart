import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/president.dart';

class PresidentService {
  final String baseUrl;
  PresidentService({required this.baseUrl});

  Future<List<President>> fetchPresidents() async {
    final url = Uri.parse('$baseUrl/api/v1/President');
    debugPrint('PresidentService: GET $url');
    final resp = await http.get(url);
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    try {
      final data = json.decode(resp.body);
      final list = (data is Map && data['data'] is List) ? data['data'] : (data is List ? data : []);
      final items = <President>[];
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          try {
            items.add(President.fromJson(e));
          } catch (err) {
            debugPrint('PresidentService: fallo al parsear item: $err');
          }
        } else {
          debugPrint('PresidentService: elemento ignorado no es Map: ${e.runtimeType}');
        }
      }
      debugPrint('PresidentService: items parseados=${items.length}');
      return items;
    } catch (err) {
      throw Exception('Error decoding presidents JSON: $err');
    }
  }

  Future<President?> fetchPresidentById(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/President/$id');
    final resp = await http.get(url);
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    try {
      final data = json.decode(resp.body);
      final map = (data is Map && data['data'] is Map) ? data['data'] as Map<String, dynamic> : (data is Map<String, dynamic> ? data : null);
      if (map == null) throw Exception('No president object in response');
      return President.fromJson(map);
    } catch (err) {
      throw Exception('Error decoding president JSON: $err');
    }
  }
}
