import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/universidad.dart';

class UniversidadService {
  UniversidadService._();
  static final UniversidadService instance = UniversidadService._();

  final CollectionReference _col = FirebaseFirestore.instance.collection('universidades');

  Stream<List<Universidad>> streamUniversidades() {
    return _col.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Universidad.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<Universidad> getById(String id) async {
    final doc = await _col.doc(id).get();
    return Universidad.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<void> addUniversidad(Universidad u) async {
    await _col.add(u.toMap());
  }

  Future<void> updateUniversidad(Universidad u) async {
    if (u.id == null) throw ArgumentError('Universidad id es requerido para actualizar');
    await _col.doc(u.id).update(u.toMap());
  }

  Future<void> deleteUniversidad(String id) async {
    await _col.doc(id).delete();
  }
}
