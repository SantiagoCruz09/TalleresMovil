import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/city.dart';

class CityService {
  final String baseUrl;
  CityService({required this.baseUrl});

  Future<List<City>> fetchCities() async {
    final url = Uri.parse('$baseUrl/api/v1/City');
    debugPrint('CityService: GET $url');
    final resp = await http.get(url);
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    try {
      final data = json.decode(resp.body);
      final list = (data is Map && data['data'] is List) ? data['data'] : (data is List ? data : []);
      final items = <City>[];
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          try {
            items.add(City.fromJson(e));
          } catch (err) {
            debugPrint('CityService: fallo al parsear item: $err');
          }
        } else {
          debugPrint('CityService: elemento ignorado no es Map: ${e.runtimeType}');
        }
      }
      debugPrint('CityService: items parseados=${items.length}');
      return items;
    } catch (err) {
      throw Exception('Error decoding cities JSON: $err');
    }
  }

  Future<City?> fetchCityById(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/City/$id');
    final resp = await http.get(url);
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    try {
      final data = json.decode(resp.body);
      final map = (data is Map && data['data'] is Map) ? data['data'] as Map<String, dynamic> : (data is Map<String, dynamic> ? data : null);
      if (map == null) throw Exception('No city object in response');
      return City.fromJson(map);
    } catch (err) {
      throw Exception('Error decoding city JSON: $err');
    }
  }
}
