class PurchaseReceipt {
  const PurchaseReceipt({
    required this.name,
    required this.supplier,
    required this.status,
    this.postingDate,
  });

  final String name;
  final String supplier;
  final String status;
  final String? postingDate;

  factory PurchaseReceipt.fromJson(Map<String, dynamic> json) {
    return PurchaseReceipt(
      name: json['name']?.toString() ?? '',
      supplier: json['supplier']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'Draft',
      postingDate: json['posting_date']?.toString(),
    );
  }
}
