import 'dart:typed_data';
import 'dart:convert' show utf8;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/project_model.dart';

class ExportUtils {
  static Future<void> exportEarningsToCSV(List<ProjectModel> projects) async {
    final rows = [
      ['Title', 'Client', 'Budget', 'Deadline']
    ];

    for (var p in projects) {
      rows.add([
        p.title,
        p.client,
        p.budget.toString(),
        DateFormat('yyyy-MM-dd').format(p.deadline),
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);

    final bytes = Uint8List.fromList(utf8.encode(csvData));

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'earnings.csv',
    );
  }

  static Future<void> exportEarningsToPDF(List<ProjectModel> projects) async {
    final pdf = pw.Document();
    final date = DateFormat('yyyy-MM-dd');

    pdf.addPage(pw.Page(
      build: (context) {
        return pw.Column(
          children: [
            pw.Text("Earnings Report", style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['Title', 'Client', 'Budget', 'Deadline'],
              data: projects.map((p) => [
                p.title,
                p.client,
                '\$${p.budget.toStringAsFixed(2)}',
                date.format(p.deadline),
              ]).toList(),
            ),
          ],
        );
      },
    ));

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}