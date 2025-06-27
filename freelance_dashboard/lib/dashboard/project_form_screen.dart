import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';



class ProjectFormScreen extends StatefulWidget {
  final ProjectModel? project;

  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _client = TextEditingController();
  final _budget = TextEditingController();
  final _notes = TextEditingController();
  DateTime _deadline = DateTime.now();
  String _status = 'Pending';

  final List<String> statusOptions = ['Pending', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      final p = widget.project!;
      _title.text = p.title;
      _client.text = p.client;
      _budget.text = p.budget.toString();
      _notes.text = p.notes;
      _deadline = p.deadline;
      _status = p.status;
    }
  }

  void saveProject() async {
    if (_formKey.currentState!.validate()) {
      final project = ProjectModel(
        id: widget.project?.id ?? '',
        title: _title.text,
        client: _client.text,
        status: _status,
        budget: double.tryParse(_budget.text) ?? 0,
        deadline: _deadline,
        notes: _notes.text,
      );

      final ref = FirebaseFirestore.instance.collection('projects');

      if (widget.project == null) {
        await ref.add(project.toMap());
      } else {
        await ref.doc(project.id).update(project.toMap());
      } else {
        await addActivityLog("Task", "Task '${task.title}' created.");
      }

      Navigator.pop(context);
    }
  }

  Future<void> uploadAttachment(String projectId) async {
  final result = await FilePicker.platform.pickFiles();
  if (result != null && result.files.single.path != null) {
    final path = result.files.single.path!;
    final fileName = result.files.single.name;
    final ref = FirebaseStorage.instance.ref('attachments/$projectId/$fileName');
    await ref.putFile(File(path));
  }
}

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.project != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Project' : 'Add Project')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Project Title'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _client, decoration: const InputDecoration(labelText: 'Client Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _budget, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Budget'), validator: (v) => v!.isEmpty ? 'Required' : null),
              DropdownButtonFormField<String>(
                value: _status,
                items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _status = val!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              ListTile(
                title: const Text("Deadline"),
                subtitle: Text("${_deadline.toLocal()}".split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: _deadline, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime(2100));
                  if (picked != null) setState(() => _deadline = picked);
                },
              ),
              TextFormField(controller: _notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: saveProject, child: Text(isEdit ? 'Update Project' : 'Add Project')),
            ],
          ),
        ),
      ),
    );
  }
}
