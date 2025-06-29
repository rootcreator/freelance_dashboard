import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import 'task_form_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('tasks');

    return Scaffold(

      body: StreamBuilder<QuerySnapshot>(
        stream: ref.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!.docs
              .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          final statuses = ['Pending', 'In Progress', 'Completed'];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: statuses.map((status) {
              final filtered = tasks.where((t) => t.status == status).toList();

              return ExpansionTile(
                title: Text(
                  '$status (${filtered.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: filtered.map((task) {
                  return ListTile(
                    leading: Checkbox(
                      value: task.status == 'Completed',
                      onChanged: (checked) {
                        ref.doc(task.id).update({
                          'status': checked! ? 'Completed' : 'Pending',
                        });
                      },
                    ),
                    title: Text(task.title),
                    onLongPress: () => _showOptions(context, task),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showOptions(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
