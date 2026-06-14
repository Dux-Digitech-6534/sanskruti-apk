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
