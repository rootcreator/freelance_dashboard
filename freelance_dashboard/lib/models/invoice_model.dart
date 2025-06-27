class InvoiceModel {
  final String invoiceId;
  final String freelancerName;
  final String clientName;
  final String projectTitle;
  final double amount;
  final DateTime issuedDate;
  final DateTime dueDate;

  InvoiceModel({
    required this.invoiceId,
    required this.freelancerName,
    required this.clientName,
    required this.projectTitle,
    required this.amount,
    required this.issuedDate,
    required this.dueDate,
  });
}
