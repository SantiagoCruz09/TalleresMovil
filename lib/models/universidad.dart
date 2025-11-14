class Universidad {
  final String? id;
  final String nit;
  final String nombre;
  final String direccion;
  final String telefono;
  final String paginaWeb;

  Universidad({
    this.id,
    required this.nit,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.paginaWeb,
  });

  factory Universidad.fromMap(String id, Map<String, dynamic> map) {
    return Universidad(
      id: id,
      nit: map['nit'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      direccion: map['direccion'] as String? ?? '',
      telefono: map['telefono'] as String? ?? '',
      paginaWeb: map['pagina_web'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nit': nit,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'pagina_web': paginaWeb,
    };
  }
}
