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
    if (trimmedSearch.isNotEmpty) {
      filters.add(['name', 'like', '%$trimmedSearch%']);
    }

    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Purchase Order',
      queryParameters: {
        if (filters.isNotEmpty) 'filters': jsonEncode(filters),
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
        .map(
          (item) =>
              PurchaseOrderSummary.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.name.isNotEmpty)
        .toList();
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
  });

  final String name;
  final String supplier;
  final String status;
  final int docstatus;
  final double grandTotal;
  final String? transactionDate;

  factory PurchaseOrderSummary.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderSummary(
      name: json['name']?.toString() ?? '',
      supplier: json['supplier']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'Draft',
      docstatus: _toInt(json['docstatus']),
      grandTotal: _toDouble(json['grand_total']),
      transactionDate: json['transaction_date']?.toString(),
    );
  }
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
