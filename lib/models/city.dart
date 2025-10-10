class City {
  final int? id;
  final String? name;
  final String? description;
  final int? departmentId;

  City({this.id, this.name, this.description, this.departmentId});

  factory City.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      if (v is num) return v.toInt();
      return null;
    }

    final deptId = json['departmentId'] ?? (json['department'] is Map ? json['department']['id'] : null);
    return City(
      id: parseInt(json['id']),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      departmentId: parseInt(deptId),
    );
  }
}
