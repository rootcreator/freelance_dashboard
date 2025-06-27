import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  String _status = 'Pending';
  final List<String> statusOptions = ['Pending', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title.text = widget.task!.title;
      _status = widget.task!.status;
    }
  }

  void save() async {
    if (_formKey.currentState!.validate()) {
      final task = TaskModel(
        id: widget.task?.id ?? '',
        title: _title.text,
        status: _status,
        projectId: null, // optional project link
        createdAt: widget.task?.createdAt ?? DateTime.now(),
      );

      final ref = FirebaseFirestore.instance.collection('tasks');

      if (widget.task == null) {
        await ref.add(task.toMap());
      } else {
        await ref.doc(task.id).update(task.toMap());
      } else {
        await addActivityLog("Task", "Task '${task.title}' created.");
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Task' : 'New Task')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Task Title'), validator: (v) => v!.isEmpty ? 'Required' : null),
              DropdownButtonFormField<String>(
                value: _status,
                items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _status = val!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: save, child: Text(isEdit ? 'Update Task' : 'Add Task')),
            ],
          ),
        ),
      ),
    );
  }
}
