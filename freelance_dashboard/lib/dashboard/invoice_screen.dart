import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import '../utils/pdf_invoice_generator.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  ProjectModel? selectedProject;
  final _freelancerName = TextEditingController(text: "Cesar Freelance");
  final _dueDays = TextEditingController(text: "14");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoice Generator")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('projects')
                  .where('status', isEqualTo: 'Completed')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final projects = snapshot.data!.docs.map((doc) {
                  return ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                return DropdownButtonFormField<ProjectModel>(
                  value: selectedProject,
                  items: projects.map((p) {
                    return DropdownMenuItem<ProjectModel>(
                      value: p,
                      child: Text(p.title),
                    );
                  }).toList(),
                  onChanged: (proj) => setState(() => selectedProject = proj),
                  decoration: const InputDecoration(labelText: 'Select Project'),
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _freelancerName,
              decoration: const InputDecoration(labelText: "Your Name"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dueDays,
              decoration: const InputDecoration(labelText: "Due in (days)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Generate Invoice"),
              onPressed: () {
                if (selectedProject != null) {
                  generateInvoicePDF(
                    context: context,
                    freelancerName: _freelancerName.text,
                    project: selectedProject!,
                    dueInDays: int.tryParse(_dueDays.text) ?? 14,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
