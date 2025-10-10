class Department {
  final int? id;
  final String? name;
  final String? description;
  final int? cityCapitalId;
  final double? surface;
  final double? population;
  final String? phonePrefix;
  final String? postalCode;

  Department({
    this.id,
    this.name,
    this.description,
    this.cityCapitalId,
    this.surface,
    this.population,
    this.phonePrefix,
    this.postalCode,
  });

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    if (v is num) return v.toInt();
    return null;
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    if (v is num) return v.toDouble();
    return null;
  }

  factory Department.fromJson(Map<String, dynamic> json) {
    // Some responses may nest fields or include objects; parse defensively
    return Department(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      cityCapitalId: _parseInt(json['cityCapitalId'] ?? json['cityCapital'] ?? (json['cityCapitalId'] is Map ? json['cityCapitalId']['id'] : null)),
      surface: _parseDouble(json['surface']),
      population: _parseDouble(json['population']),
      phonePrefix: json['phonePrefix']?.toString(),
      postalCode: json['postalCode']?.toString(),
    );
  }
}
