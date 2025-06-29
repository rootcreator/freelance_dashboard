import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import 'project_form_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  void uploadAttachment(String projectId) {
    // Implement your upload logic here
  }

  @override
  Widget build(BuildContext context) {
    final projectsRef = FirebaseFirestore.instance.collection('projects');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: projectsRef.orderBy('deadline').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final projects = docs
              .map((doc) =>
              ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final p = projects[index];

              return Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(p.title),
                      subtitle: Text('Client: ${p.client}\nBudget: \$${p.budget.toStringAsFixed(2)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p.status,
                            style: TextStyle(
                              color: p.status == 'Completed'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          Text('${p.deadline.toLocal()}'.split(' ')[0]),
                        ],
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text("Upload Attachment"),
                          onPressed: () => uploadAttachment(p.id),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProjectFormScreen(project: p),
                                ),
                              );
                            } else if (value == 'delete') {
                              FirebaseFirestore.instance
                                  .collection('projects')
                                  .doc(p.id)
                                  .delete();
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProjectFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
