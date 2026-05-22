class PurchaseRequest {
  const PurchaseRequest({
    required this.name,
    required this.status,
    required this.site,
    this.requiredDate,
    this.requestType,
  });

  final String name;
  final String status;
  final String site;
  final String? requiredDate;
  final String? requestType;

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) {
    return PurchaseRequest(
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      site:
          json['site']?.toString() ?? json['set_warehouse']?.toString() ?? '-',
      requiredDate:
          json['schedule_date']?.toString() ??
          json['required_by']?.toString() ??
          json['transaction_date']?.toString(),
      requestType: json['material_request_type']?.toString(),
    );
  }
}
