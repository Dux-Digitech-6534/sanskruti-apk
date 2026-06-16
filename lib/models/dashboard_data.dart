import 'purchase_request_summary.dart';
import 'purchase_receipt.dart';

class DashboardData {
  const DashboardData({
    required this.totalMaterialRequestsCount,
    required this.pendingRequestsCount,
    required this.pendingPurchaseOrdersCount,
    required this.recentRequests,
    required this.recentReceipts,
    this.siteName,
  });

  final int totalMaterialRequestsCount;
  final int pendingRequestsCount;
  final int pendingPurchaseOrdersCount;
  final List<PurchaseRequestSummary> recentRequests;
  final List<PurchaseReceipt> recentReceipts;
  final String? siteName;

  factory DashboardData.empty() {
    return const DashboardData(
      pendingRequestsCount: 0,
      totalMaterialRequestsCount: 0,
      pendingPurchaseOrdersCount: 0,
      recentRequests: [],
      recentReceipts: [],
    );
  }

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final recent = json['recent_requests'];
    final recentReceipts = json['recent_receipts'];
    return DashboardData(
      pendingRequestsCount:
          int.tryParse(json['pending_requests_count']?.toString() ?? '') ?? 0,
      totalMaterialRequestsCount:
          int.tryParse(
            json['total_material_requests_count']?.toString() ?? '',
          ) ??
          0,
      pendingPurchaseOrdersCount:
          int.tryParse(
            json['pending_purchase_orders_count']?.toString() ?? '',
          ) ??
          0,
      siteName: json['site_name']?.toString(),
      recentRequests: recent is List
          ? recent
                .whereType<Map>()
                .map(
                  (item) => PurchaseRequestSummary.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      recentReceipts: recentReceipts is List
          ? recentReceipts
                .whereType<Map>()
                .map(
                  (item) =>
                      PurchaseReceipt.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
    );
  }
}
