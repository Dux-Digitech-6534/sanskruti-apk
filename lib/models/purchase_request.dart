import 'material_request_status.dart';

class PurchaseRequest {
  const PurchaseRequest({
    required this.name,
    required this.status,
    required this.docstatus,
    required this.site,
    this.requiredDate,
    this.requestType,
    this.priority,
    this.workflowState,
    this.customWorkflowStatus,
    this.perOrdered,
    this.perReceived,
    this.searchTerms = const [],
  });

  final String name;
  final String status;
  final int docstatus;
  final String site;
  final String? requiredDate;
  final String? requestType;
  final String? priority;
  final String? workflowState;
  final String? customWorkflowStatus;
  final double? perOrdered;
  final double? perReceived;
  final List<String> searchTerms;

  String get displayStatus => MaterialRequestStatus.fromErpFields(
    status: status,
    docstatus: docstatus,
    workflowState: workflowState,
    customWorkflowStatus: customWorkflowStatus,
    perOrdered: perOrdered,
    perReceived: perReceived,
  );

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) {
    return PurchaseRequest(
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      docstatus: _toInt(json['docstatus']),
      site:
          json['site']?.toString() ??
          json['project']?.toString() ??
          json['custom_select_project_']?.toString() ??
          json['set_warehouse']?.toString() ??
          '-',
      requiredDate:
          json['schedule_date']?.toString() ??
          json['required_by']?.toString() ??
          json['transaction_date']?.toString(),
      requestType: json['material_request_type']?.toString(),
      priority: json['custom_priority']?.toString(),
      workflowState: json['workflow_state']?.toString(),
      customWorkflowStatus: json['custom_workflow_status']?.toString(),
      perOrdered: _nullableDouble(
        json['per_ordered'] ?? json['percent_ordered'],
      ),
      perReceived: _nullableDouble(
        json['per_received'] ?? json['percent_received'],
      ),
      searchTerms: _searchTerms(json),
    );
  }
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

int _toInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double? _nullableDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
