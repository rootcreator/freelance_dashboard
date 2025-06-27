class ProjectModel {
  final String id;
  final String title;
  final String client;
  final String status; // e.g. 'Pending', 'In Progress', 'Completed'
  final double budget;
  final DateTime deadline;
  final String notes;

  ProjectModel({
    required this.id,
    required this.title,
    required this.client,
    required this.status,
    required this.budget,
    required this.deadline,
    required this.notes,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> data, String id) {
    return ProjectModel(
      id: id,
      title: data['title'] ?? '',
      client: data['client'] ?? '',
      status: data['status'] ?? 'Pending',
      budget: (data['budget'] ?? 0).toDouble(),
      deadline: (data['deadline'] as Timestamp).toDate(),
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'client': client,
      'status': status,
      'budget': budget,
      'deadline': deadline,
      'notes': notes,
    };
  }
}
