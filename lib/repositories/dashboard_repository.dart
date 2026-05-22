import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/dashboard_data.dart';
import '../models/purchase_receipt.dart';
import '../models/purchase_request_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(apiClientProvider));
});

final dashboardDataProvider = FutureProvider.autoDispose<DashboardData>((ref) {
  return ref.watch(dashboardRepositoryProvider).fetchDashboardData();
});

class DashboardRepository {
  const DashboardRepository(this._apiClient);

  static const _pageSize = 50;

  final ApiClient _apiClient;

  Future<DashboardData> fetchDashboardData() async {
    final pendingMaterialRequests = await _fetchPagedSummaries(
      doctype: 'Material Request',
      filters: const [
        ['status', '!=', 'Completed'],
      ],
    );
    final pendingPurchaseOrders = await _fetchPagedSummaries(
      doctype: 'Purchase Order',
      filters: const [
        ['status', '!=', 'Completed'],
      ],
    );
    final recentRequests = await fetchRecentMaterialRequests();
    final recentReceipts = await fetchRecentPurchaseReceipts();

    return DashboardData(
      pendingRequestsCount: pendingMaterialRequests
          .where(_isNotCompleted)
          .length,
      pendingPurchaseOrdersCount: pendingPurchaseOrders
          .where(_isNotCompleted)
          .length,
      recentRequests: recentRequests,
      recentReceipts: recentReceipts,
      siteName: recentRequests.isEmpty ? null : recentRequests.first.site,
    );
  }

  Future<List<PurchaseRequestSummary>> fetchRecentMaterialRequests() async {
    return _fetchPagedSummaries(doctype: 'Material Request', limit: 20);
  }

  Future<List<PurchaseReceipt>> fetchRecentPurchaseReceipts() async {
    final response = await _apiClient.get(
      _resourcePath('Purchase Receipt'),
      queryParameters: {
        'fields': jsonEncode(['name', 'supplier', 'posting_date', 'status']),
        'order_by': 'modified desc',
        'limit_page_length': 20,
      },
    );

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map(
          (item) => PurchaseReceipt.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.name.isNotEmpty)
        .toList();
  }

  Future<List<PurchaseRequestSummary>> _fetchPagedSummaries({
    required String doctype,
    List<List<Object>> filters = const [],
    int? limit,
  }) async {
    final summaries = <PurchaseRequestSummary>[];
    var start = 0;

    while (true) {
      final pageLength = limit == null
          ? _pageSize
          : (limit - summaries.length).clamp(0, _pageSize);
      if (pageLength == 0) break;

      final page = await _fetchSummaryPage(
        doctype: doctype,
        filters: filters,
        start: start,
        pageLength: pageLength,
      );
      summaries.addAll(page);

      if (page.length < pageLength || summaries.length == limit) break;
      start += pageLength;
    }

    return summaries;
  }

  Future<List<PurchaseRequestSummary>> _fetchSummaryPage({
    required String doctype,
    required List<List<Object>> filters,
    required int start,
    required int pageLength,
  }) async {
    final response = await _apiClient.get(
      _resourcePath(doctype),
      queryParameters: {
        'fields': jsonEncode(_fieldsFor(doctype)),
        if (filters.isNotEmpty) 'filters': jsonEncode(filters),
        'order_by': 'modified desc',
        'limit_start': start,
        'limit_page_length': pageLength,
      },
    );

    return _summaryListFromResponse(response.data);
  }

  List<PurchaseRequestSummary> _summaryListFromResponse(Object? responseData) {
    final data = responseData is Map ? responseData['data'] : null;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map(
          (item) =>
              PurchaseRequestSummary.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  bool _isNotCompleted(PurchaseRequestSummary request) {
    final status = request.status.trim().toLowerCase();
    return status.isEmpty || status != 'completed';
  }

  String _resourcePath(String doctype) {
    return '${ApiEndpoints.resource}/${Uri.encodeComponent(doctype)}';
  }

  List<String> _fieldsFor(String doctype) {
    if (doctype == 'Purchase Order') {
      return const ['name', 'status', 'transaction_date'];
    }

    return const [
      'name',
      'status',
      'schedule_date',
      'transaction_date',
      'set_warehouse',
      'material_request_type',
    ];
  }
}
