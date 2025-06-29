import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String status; // 'Pending', 'In Progress', 'Completed'
  final String? projectId;
  final DateTime createdAt;
  final String? description;

  TaskModel({
    required this.id,
    required this.title,
    required this.status,
    this.projectId,
    required this.createdAt,
    this.description,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data, String id) {
    return TaskModel(
      id: id,
      title: data['title'] ?? '',
      status: data['status'] ?? 'Pending',
      projectId: data['projectId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
      'projectId': projectId,
      'createdAt': createdAt,
      'description': description,
    };
  }
}
