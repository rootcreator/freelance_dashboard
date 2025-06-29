import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Welcome back, ${user?.email ?? 'User'}!",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildStatsCards(context),
            const SizedBox(height: 30),
            _buildRecentTasks(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        FirebaseFirestore.instance.collection('projects').get(),
        FirebaseFirestore.instance.collection('tasks').get(),
        FirebaseFirestore.instance.collection('projects').where('status', isEqualTo: 'Completed').get(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (_) => const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(child: SizedBox(height: 80)),
              ),
            )),
          );
        }

        final allProjectDocs = snapshot.data![0].docs;
        final taskDocs = snapshot.data![1].docs;
        final completedProjectDocs = snapshot.data![2].docs;

        final projects = allProjectDocs
            .map((doc) => ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        final completedProjects = completedProjectDocs
            .map((doc) => ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        final totalEarnings = completedProjects.fold<double>(
          0,
              (sum, project) => sum + project.budget,
        );

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Row(
            key: ValueKey('${projects.length}${taskDocs.length}$totalEarnings'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatCard(label: 'Projects', value: projects.length.toString(), icon: Icons.work),
              _StatCard(label: 'Tasks', value: taskDocs.length.toString(), icon: Icons.check_circle),
              _StatCard(label: 'Earnings', value: "\$${totalEarnings.toStringAsFixed(0)}", icon: Icons.attach_money),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentTasks() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Recent Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              CircularProgressIndicator(),
            ],
          );
        }

        final tasks = snapshot.data!.docs
            .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recent Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...tasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;

              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(offset: Offset(0, (1 - value) * 20), child: child),
                ),
                child: ListTile(
                  leading: const Icon(Icons.task_alt),
                  title: Text(task.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${task.status} • ${DateFormat.yMd().format(task.createdAt)}"),
                      if (task.description != null && task.description!.isNotEmpty)
                        Text(task.description!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),

                ),
              );
            }),
          ],
        );
      },
    );
  }

}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Container(
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
