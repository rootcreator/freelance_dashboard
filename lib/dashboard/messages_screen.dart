import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import 'project_chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projectsRef = FirebaseFirestore.instance.collection('projects');

    return StreamBuilder<QuerySnapshot>(
      stream: projectsRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final projects = snapshot.data!.docs
            .map((doc) => ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];

            return Card(
              child: ListTile(
                title: Text(project.title),
                subtitle: Text('Client: ${project.client}'),
                trailing: const Icon(Icons.chat),
                onTap: () {
                  Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (_, __, ___) => TaskFormScreen(),
    transitionsBuilder: (_, anim, __, child) =>
      FadeTransition(opacity: anim, child: child),
  ),
);

                },
              ),
            );
          },
        );
      },
    );
  }
}
