class PurchaseReceipt {
  const PurchaseReceipt({
    required this.name,
    required this.supplier,
    required this.status,
    required this.docstatus,
    this.postingDate,
    this.searchTerms = const [],
  });

  final String name;
  final String supplier;
  final String status;
  final int docstatus;
  final String? postingDate;
  final List<String> searchTerms;

  String get displayStatus {
    final normalized = status.trim();
    final lower = normalized.toLowerCase();
    if (docstatus == 0) return 'Draft';
    if (docstatus == 2 || lower.contains('cancel')) return 'Cancelled';
    if (docstatus == 1 && (normalized.isEmpty || lower == 'submitted')) {
      return 'Completed';
    }
    return normalized.isEmpty ? _docStatusLabel(docstatus) : normalized;
  }

  factory PurchaseReceipt.fromJson(Map<String, dynamic> json) {
    return PurchaseReceipt(
      name: json['name']?.toString() ?? '',
      supplier: json['supplier']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'Draft',
      docstatus: _toInt(json['docstatus']),
      postingDate: json['posting_date']?.toString(),
      searchTerms: _searchTerms(json),
    );
  }
}

String _docStatusLabel(int docstatus) {
  return switch (docstatus) {
    0 => 'Draft',
    1 => 'Completed',
    2 => 'Cancelled',
    _ => 'Draft',
  };
}

int _toInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

List<String> _searchTerms(Map<String, dynamic> json) {
  final terms = <String>[];
  final rawTerms = json['_search_terms'];
  if (rawTerms is List) {
    terms.addAll(rawTerms.map((value) => value?.toString() ?? ''));
  }
  final items = json['items'];
  if (items is List) {
    for (final item in items.whereType<Map>()) {
      terms.addAll([
        item['item_code']?.toString() ?? '',
        item['item_name']?.toString() ?? '',
        item['description']?.toString() ?? '',
        item['warehouse']?.toString() ?? '',
        item['project']?.toString() ?? '',
      ]);
    }
  }
  return terms.where((term) => term.trim().isNotEmpty).toList();
}
