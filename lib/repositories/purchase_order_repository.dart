import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';

final purchaseOrderRepositoryProvider = Provider<PurchaseOrderRepository>((
  ref,
) {
  return PurchaseOrderRepository(ref.watch(apiClientProvider));
});

class PurchaseOrderRepository {
  const PurchaseOrderRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PurchaseOrderSummary>> fetchPurchaseOrders({
    String search = '',
  }) async {
    final filters = <List<String>>[];
    final trimmedSearch = search.trim();
    final itemSearchTerms = trimmedSearch.isEmpty
        ? const <String, List<String>>{}
        : await _fetchChildSearchTerms(
            childDoctype: 'Purchase Order Item',
            search: trimmedSearch,
          );
    final orFilters = <List<Object>>[];
    if (trimmedSearch.isNotEmpty) {
      orFilters.addAll([
        ['name', 'like', '%$trimmedSearch%'],
        ['supplier', 'like', '%$trimmedSearch%'],
      ]);
      if (itemSearchTerms.isNotEmpty) {
        orFilters.add(['name', 'in', itemSearchTerms.keys.toList()]);
      }
    }

    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Purchase Order',
      queryParameters: {
        if (filters.isNotEmpty) 'filters': jsonEncode(filters),
        if (orFilters.isNotEmpty) 'or_filters': jsonEncode(orFilters),
        'fields': jsonEncode([
          'name',
          'supplier',
          'transaction_date',
          'status',
          'docstatus',
          'grand_total',
        ]),
        'order_by': 'transaction_date desc, modified desc',
        'limit_page_length': 100,
      },
    );

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) {
          final row = Map<String, dynamic>.from(item);
          row['_search_terms'] = itemSearchTerms[row['name']?.toString()] ?? [];
          return PurchaseOrderSummary.fromJson(row);
        })
        .where((item) => item.name.isNotEmpty)
        .toList();
  }

  Future<Map<String, List<String>>> _fetchChildSearchTerms({
    required String childDoctype,
    required String search,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.resource}/$childDoctype',
        queryParameters: {
          'fields': jsonEncode([
            'parent',
            'item_code',
            'item_name',
            'description',
            'warehouse',
            'project',
          ]),
          'or_filters': jsonEncode([
            ['item_code', 'like', '%$search%'],
            ['item_name', 'like', '%$search%'],
            ['description', 'like', '%$search%'],
            ['warehouse', 'like', '%$search%'],
            ['project', 'like', '%$search%'],
          ]),
          'limit_page_length': 500,
        },
      );

      final data = response.data is Map ? response.data['data'] : null;
      if (data is! List) return const {};
      final result = <String, List<String>>{};
      for (final item in data.whereType<Map>()) {
        final parent = item['parent']?.toString() ?? '';
        if (parent.isEmpty) continue;
        result.putIfAbsent(parent, () => <String>[]).addAll([
          item['item_code']?.toString() ?? '',
          item['item_name']?.toString() ?? '',
          item['description']?.toString() ?? '',
          item['warehouse']?.toString() ?? '',
          item['project']?.toString() ?? '',
        ]);
      }
      return result;
    } on Object catch (_) {
      return const {};
    }
  }

  Future<PurchaseOrderDetail> fetchPurchaseOrderDetail(String name) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Purchase Order/${Uri.encodeComponent(name)}',
    );
    final data = response.data is Map ? response.data['data'] : null;
    if (data is! Map) throw Exception('Invalid Purchase Order response.');
    return PurchaseOrderDetail.fromJson(Map<String, dynamic>.from(data));
  }
}

class PurchaseOrderSummary {
  const PurchaseOrderSummary({
    required this.name,
    required this.supplier,
    required this.status,
    required this.docstatus,
    required this.grandTotal,
    this.transactionDate,
    this.searchTerms = const [],
  });

  final String name;
  final String supplier;
  final String status;
  final int docstatus;
  final double grandTotal;
  final String? transactionDate;
  final List<String> searchTerms;

  factory PurchaseOrderSummary.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderSummary(
      name: json['name']?.toString() ?? '',
      supplier: json['supplier']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'Draft',
      docstatus: _toInt(json['docstatus']),
      grandTotal: _toDouble(json['grand_total']),
      transactionDate: json['transaction_date']?.toString(),
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

class PurchaseOrderDetail {
  const PurchaseOrderDetail({
    required this.name,
    required this.supplier,
    required this.status,
    required this.docstatus,
    required this.grandTotal,
    required this.items,
    this.transactionDate,
    this.scheduleDate,
  });

  final String name;
  final String supplier;
  final String status;
  final int docstatus;
  final double grandTotal;
  final String? transactionDate;
  final String? scheduleDate;
  final List<PurchaseOrderDetailItem> items;

  factory PurchaseOrderDetail.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    final docstatus = _toInt(json['docstatus']);
    return PurchaseOrderDetail(
      name: json['name']?.toString() ?? '',
      supplier: json['supplier']?.toString() ?? '-',
      status: json['status']?.toString() ?? _docStatusLabel(docstatus),
      docstatus: docstatus,
      grandTotal: _toDouble(json['grand_total'] ?? json['rounded_total']),
      transactionDate: json['transaction_date']?.toString(),
      scheduleDate: json['schedule_date']?.toString(),
      items: items is List
          ? items
                .whereType<Map>()
                .map(
                  (item) => PurchaseOrderDetailItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((item) => item.itemCode.isNotEmpty)
                .toList()
          : const [],
    );
  }
}

class PurchaseOrderDetailItem {
  const PurchaseOrderDetailItem({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.receivedQty,
    required this.rate,
    required this.amount,
    required this.uom,
    required this.warehouse,
    this.scheduleDate,
  });

  final String itemCode;
  final String itemName;
  final double qty;
  final double receivedQty;
  final double rate;
  final double amount;
  final String uom;
  final String warehouse;
  final String? scheduleDate;

  factory PurchaseOrderDetailItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderDetailItem(
      itemCode: json['item_code']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      qty: _toDouble(json['qty']),
      receivedQty: _toDouble(json['received_qty']),
      rate: _toDouble(json['rate']),
      amount: _toDouble(json['amount']),
      uom: json['uom']?.toString() ?? json['stock_uom']?.toString() ?? '',
      warehouse: json['warehouse']?.toString() ?? '-',
      scheduleDate: json['schedule_date']?.toString(),
    );
  }
}

int _toInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _docStatusLabel(int docstatus) {
  return switch (docstatus) {
    0 => 'Draft',
    1 => 'Submitted',
    2 => 'Cancelled',
    _ => 'Draft',
  };
}
