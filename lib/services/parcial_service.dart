import 'dart:async';

import '../models/appi_item.dart';

/// Servicio scaffold para la futura API 'Parcial'.
class ParcialService {
  final String baseUrl;

  ParcialService({required this.baseUrl});

  /// Método placeholder que simula una llamada de red y devuelve una lista vacía.
  Future<List<AppiItem>> fetchItems({int page = 1, int limit = 12}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return <AppiItem>[];
  }

  /// Placeholder de detalle por id.
  Future<AppiItem?> fetchItemById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return null;
  }
}
