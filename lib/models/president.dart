class President {
  final int? id;
  final String? name;
  final String? party;
  final String? startDate;

  President({this.id, this.name, this.party, this.startDate});

  factory President.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      if (v is num) return v.toInt();
      return null;
    }

    return President(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? json['fullName']?.toString(),
      party: json['party']?.toString() ?? json['politicalParty']?.toString(),
      startDate: json['startDate']?.toString() ?? json['start_date']?.toString(),
    );
  }
}
