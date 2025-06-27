class ActivityModel {
  final String id;
  final String type; // e.g. "Task", "Project", "Invoice"
  final String message;
  final DateTime timestamp;

  ActivityModel({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> data, String id) {
    return ActivityModel(
      id: id,
      type: data['type'],
      message: data['message'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
