class TaskModel {
  final String id;
  final String title;
  final String status; // 'Pending', 'In Progress', 'Completed'
  final String? projectId;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.status,
    this.projectId,
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data, String id) {
    return TaskModel(
      id: id,
      title: data['title'] ?? '',
      status: data['status'] ?? 'Pending',
      projectId: data['projectId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
      'projectId': projectId,
      'createdAt': createdAt,
    };
  }
}
