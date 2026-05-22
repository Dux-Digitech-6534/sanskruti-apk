import '../utils/formatters.dart';

class DocumentSummary {
  const DocumentSummary({required this.name, required this.data});

  final String name;
  final Map<String, dynamic> data;

  factory DocumentSummary.fromJson(Map<String, dynamic> json) {
    return DocumentSummary(
      name: (json['name'] ?? '').toString(),
      data: Map<String, dynamic>.from(json),
    );
  }

  String get status => (data['status'] ?? 'Draft').toString();
  String get owner => (data['owner'] ?? '').toString();
  String get modified =>
      Formatters.dateString((data['modified'] ?? '').toString());
  double get grandTotal =>
      double.tryParse((data['grand_total'] ?? data['total'] ?? 0).toString()) ??
      0;
}
