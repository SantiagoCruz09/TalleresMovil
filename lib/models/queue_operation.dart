enum QueueOperationType {
  create,
  update,
  delete,
}

class QueueOperation {
  final String id;
  final String entity; // 'task'
  final String entityId; // task id
  final QueueOperationType operation;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  int attemptCount;
  String? lastError;

  QueueOperation({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    this.attemptCount = 0,
    this.lastError,
  });

  factory QueueOperation.fromMap(Map<String, dynamic> map) {
    return QueueOperation(
      id: map['id'] as String,
      entity: map['entity'] as String,
      entityId: map['entity_id'] as String,
      operation: QueueOperationType.values.firstWhere(
        (e) => e.name == map['op'] as String,
      ),
      payload: map['payload'] != null
          ? Map<String, dynamic>.from(
              (map['payload'] is String
                  ? Uri.decodeFull(map['payload'] as String)
                  : map['payload']) as Map<String, dynamic>)
          : {},
      createdAt: DateTime.parse(map['created_at'] as String),
      attemptCount: (map['attempt_count'] as int?) ?? 0,
      lastError: map['last_error'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity': entity,
      'entity_id': entityId,
      'op': operation.name,
      'payload': Uri.encodeComponent(payload.toString()),
      'created_at': createdAt.toIso8601String(),
      'attempt_count': attemptCount,
      'last_error': lastError,
    };
  }

  @override
  String toString() =>
      'QueueOperation(id: $id, entity: $entity, op: ${operation.name}, attempts: $attemptCount)';
}
