import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/touristic_attraction.dart';

class TouristicAttractionService {
  final String baseUrl;
  TouristicAttractionService({required this.baseUrl});

  Future<List<TouristicAttraction>> fetchAttractions() async {
    final url = Uri.parse('$baseUrl/api/v1/TouristicAttraction');
    debugPrint('AttractionService: GET $url');
    final resp = await http.get(url);
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    try {
      final data = json.decode(resp.body);
      final list = (data is Map && data['data'] is List) ? data['data'] : (data is List ? data : []);
      final items = <TouristicAttraction>[];
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          try {
            items.add(TouristicAttraction.fromJson(e));
          } catch (err) {
            debugPrint('AttractionService: fallo al parsear item: $err');
          }
        } else {
          debugPrint('AttractionService: elemento ignorado no es Map: ${e.runtimeType}');
        }
      }
      debugPrint('AttractionService: items parseados=${items.length}');
      return items;
    } catch (err) {
      throw Exception('Error decoding attractions JSON: $err');
    }
  }

  Future<TouristicAttraction?> fetchAttractionById(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/TouristicAttraction/$id');
    final resp = await http.get(url);
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    try {
      final data = json.decode(resp.body);
      final map = (data is Map && data['data'] is Map) ? data['data'] as Map<String, dynamic> : (data is Map<String, dynamic> ? data : null);
      if (map == null) throw Exception('No attraction object in response');
      return TouristicAttraction.fromJson(map);
    } catch (err) {
      throw Exception('Error decoding attraction JSON: $err');
    }
  }
}
