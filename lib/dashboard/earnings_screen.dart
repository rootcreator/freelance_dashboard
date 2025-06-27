import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../models/project_model.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final projectsRef = FirebaseFirestore.instance.collection('projects');

    return StreamBuilder<QuerySnapshot>(
      stream: projectsRef
          .where('status', isEqualTo: 'Completed')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final completedProjects = snapshot.data!.docs
            .map((doc) => ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .where((p) => p.deadline.year == selectedYear)
            .toList();

        final monthlyTotals = List.generate(12, (i) => 0.0);
        for (final p in completedProjects) {
          monthlyTotals[p.deadline.month - 1] += p.budget;
        }

        final total = completedProjects.fold(0.0, (sum, p) => sum + p.budget);

        final chartData = List.generate(12, (i) {
          return _EarningsData(DateFormat.MMM().format(DateTime(0, i + 1)), monthlyTotals[i]);
        });

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text("Total Earnings in $selectedYear", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text("\$${total.toStringAsFixed(2)}", style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.green)),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: charts.BarChart(
                  [
                    charts.Series<_EarningsData, String>(
                      id: 'Earnings',
                      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                      domainFn: (e, _) => e.month,
                      measureFn: (e, _) => e.amount,
                      data: chartData,
                    )
                  ],
                  animate: true,
                ),
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<int>(
                value: selectedYear,
                decoration: const InputDecoration(labelText: "Select Year"),
                items: List.generate(5, (i) {
                  final year = DateTime.now().year - i;
                  return DropdownMenuItem(value: year, child: Text('$year'));
                }),
                onChanged: (val) {
                  if (val != null) setState(() => selectedYear = val);
                },
              ),
              if (completedProjects.isNotEmpty) ...[
  const SizedBox(height: 20),
  Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Export CSV'),
          onPressed: () => ExportUtils.exportEarningsToCSV(completedProjects),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Export PDF'),
          onPressed: () => ExportUtils.exportEarningsToPDF(completedProjects),
        ),
      ),
    ],
  ),
]

            ],
          ),
        );
      },
    );
  }
}

class _EarningsData {
  final String month;
  final double amount;

  _EarningsData(this.month, this.amount);
}
