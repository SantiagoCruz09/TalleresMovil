import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/appi_item.dart';

class AppiService {
  /// Base URL para la colección. Para Art Institute of Chicago usar:
  /// https://api.artic.edu/api/v1/artworks
  final String baseUrl;

  AppiService({required this.baseUrl});

  /// Obtiene la primera página de items. Puedes extender para paginación.
  Future<List<AppiItem>> fetchItems({int page = 1, int limit = 12}) async {
    final uri = Uri.parse('$baseUrl?page=$page&limit=$limit');
    debugPrint('APPI: solicitando lista page=$page limit=$limit -> $uri');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;
      final List data = decoded['data'] as List? ?? [];
      debugPrint('APPI: respuesta OK, items recibidos=${data.length}');
      final items = data.map((e) => AppiItem.fromJson(e as Map<String, dynamic>)).toList();
      for (var i = 0; i < items.length; i++) {
        debugPrint('APPI: item[${i}] id=${items[i].id} title=${items[i].title} imageId=${items[i].imageId}');
      }
      return items;
    } else {
      debugPrint('APPI: error en petición, status=${response.statusCode}');
      throw Exception('Error en la petición: ${response.statusCode}');
    }
  }

  /// Obtener detalle por id (usa endpoint /{id})
  Future<AppiItem> fetchItemById(String id) async {
    final uri = Uri.parse('$baseUrl/$id');
    debugPrint('APPI: solicitando detalle id=$id -> $uri');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> data = decoded['data'] as Map<String, dynamic>;
      debugPrint('APPI: detalle recibido id=$id');
      return AppiItem.fromJson(data);
    } else {
      debugPrint('APPI: error detalle id=$id status=${response.statusCode}');
      throw Exception('Error en la petición detallada: ${response.statusCode}');
    }
  }
}

