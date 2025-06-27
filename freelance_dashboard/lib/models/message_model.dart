class MessageModel {
  final String id;
  final String projectId;
  final String content;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.projectId,
    required this.content,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> data, String id) {
    return MessageModel(
      id: id,
      projectId: data['projectId'],
      content: data['content'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
