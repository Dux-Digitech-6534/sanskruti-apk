class PurchaseRequestSummary {
  const PurchaseRequestSummary({
    required this.name,
    required this.site,
    required this.status,
    this.requiredDate,
    this.itemCount = 0,
  });

  final String name;
  final String site;
  final String status;
  final String? requiredDate;
  final int itemCount;

  factory PurchaseRequestSummary.fromJson(Map<String, dynamic> json) {
    final status =
        json['status']?.toString() ??
        json['docstatus']?.toString() ??
        'Pending';

    return PurchaseRequestSummary(
      name: json['name']?.toString() ?? '',
      site:
          json['site']?.toString() ??
          json['set_warehouse']?.toString() ??
          json['project']?.toString() ??
          '-',
      status: status,
      requiredDate:
          json['schedule_date']?.toString() ??
          json['required_by']?.toString() ??
          json['transaction_date']?.toString(),
      itemCount: int.tryParse(json['items_count']?.toString() ?? '') ?? 0,
    );
  }
}
