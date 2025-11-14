class Task {
  final String id;
  final String title;
  final String? description;
  final bool completed;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final bool deleted;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.completed,
    required this.updatedAt,
    this.dueDate,
    this.deleted = false,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      completed: (map['completed'] as int?) == 1,
      updatedAt: DateTime.parse(map['updated_at'] as String),
      description: map['description'] as String?,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      deleted: (map['deleted'] as int?) == 1,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      completed: json['completed'] as bool? ?? false,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      deleted: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'deleted': deleted ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'updatedAt': updatedAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? updatedAt,
    DateTime? dueDate,
    bool? deleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  String toString() => 'Task(id: $id, title: $title, completed: $completed)';
}
