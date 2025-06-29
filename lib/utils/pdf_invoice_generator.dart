import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/project_model.dart';

Future<void> generateInvoicePDF({
  required BuildContext context,
  required String freelancerName,
  required ProjectModel project,
  int dueInDays = 14,
}) async {
  final pdf = pw.Document();
  final date = DateTime.now();
  final dueDate = date.add(Duration(days: dueInDays));
  final formatter = DateFormat('yyyy-MM-dd');

  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 24),
            pw.Text('Freelancer: $freelancerName'),
            pw.Text('Client: ${project.client}'),
            pw.SizedBox(height: 16),
            pw.Text('Project: ${project.title}', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 16),
            pw.Text('Invoice Date: ${formatter.format(date)}'),
            pw.Text('Due Date: ${formatter.format(dueDate)}'),
            pw.SizedBox(height: 24),
            pw.Container(
              color: PdfColor.fromHex("#eeeeee"),
              padding: const pw.EdgeInsets.all(16),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total', style: pw.TextStyle(fontSize: 16)),
                  pw.Text('\$${project.budget.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18)),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: 14)),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
