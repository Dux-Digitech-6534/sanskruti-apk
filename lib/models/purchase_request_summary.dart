import 'material_request_status.dart';

class PurchaseRequestSummary {
  const PurchaseRequestSummary({
    required this.name,
    required this.site,
    required this.status,
    required this.docstatus,
    this.requiredDate,
    this.priority,
    this.workflowState,
    this.customWorkflowStatus,
    this.perOrdered,
    this.perReceived,
    this.itemCount = 0,
  });

  final String name;
  final String site;
  final String status;
  final int docstatus;
  final String? requiredDate;
  final String? priority;
  final String? workflowState;
  final String? customWorkflowStatus;
  final double? perOrdered;
  final double? perReceived;
  final int itemCount;

  String get displayStatus => MaterialRequestStatus.fromErpFields(
    status: status,
    docstatus: docstatus,
    workflowState: workflowState,
    customWorkflowStatus: customWorkflowStatus,
    perOrdered: perOrdered,
    perReceived: perReceived,
  );

  factory PurchaseRequestSummary.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestSummary(
      name: json['name']?.toString() ?? '',
      site:
          json['site']?.toString() ??
          json['set_warehouse']?.toString() ??
          json['project']?.toString() ??
          '-',
      status: json['status']?.toString() ?? 'Pending',
      docstatus: _toInt(json['docstatus']),
      requiredDate:
          json['schedule_date']?.toString() ??
          json['required_by']?.toString() ??
          json['transaction_date']?.toString(),
      priority: json['custom_priority']?.toString(),
      workflowState: json['workflow_state']?.toString(),
      customWorkflowStatus: json['custom_workflow_status']?.toString(),
      perOrdered: _nullableDouble(
        json['per_ordered'] ?? json['percent_ordered'],
      ),
      perReceived: _nullableDouble(
        json['per_received'] ?? json['percent_received'],
      ),
      itemCount: int.tryParse(json['items_count']?.toString() ?? '') ?? 0,
    );
  }
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
