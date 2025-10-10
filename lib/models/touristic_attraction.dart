class TouristicAttraction {
  final int? id;
  final String? name;
  final String? description;
  final String? location;

  TouristicAttraction({this.id, this.name, this.description, this.location});

  factory TouristicAttraction.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      if (v is num) return v.toInt();
      return null;
    }

    String? parseLocation(dynamic v) {
      if (v == null) return null;
      if (v is String) return v;
      if (v is Map && v['name'] != null) return v['name'].toString();
      return v.toString();
    }

    return TouristicAttraction(
      id: parseInt(json['id']),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      location: parseLocation(json['location'] ?? json['place']),
    );
  }
}
