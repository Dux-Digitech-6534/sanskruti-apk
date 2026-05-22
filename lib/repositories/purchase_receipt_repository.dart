import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/purchase_receipt.dart';
import '../models/purchase_request_form_models.dart';

final purchaseReceiptRepositoryProvider = Provider<PurchaseReceiptRepository>((
  ref,
) {
  return PurchaseReceiptRepository(ref.watch(apiClientProvider));
});

class PurchaseReceiptRepository {
  const PurchaseReceiptRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PurchaseReceipt>> fetchPurchaseReceipts({
    required int limitStart,
    required int limitPageLength,
    String search = '',
  }) async {
    final filters = <List<String>>[];
    final trimmedSearch = search.trim();
    if (trimmedSearch.isNotEmpty) {
      filters.add(['name', 'like', '%$trimmedSearch%']);
    }

    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Purchase Receipt',
      queryParameters: {
        'fields': jsonEncode(['name', 'supplier', 'posting_date', 'status']),
        if (filters.isNotEmpty) 'filters': jsonEncode(filters),
        'order_by': 'modified desc',
        'limit_start': limitStart,
        'limit_page_length': limitPageLength,
      },
    );

    if (kDebugMode) {
      debugPrint('[PurchaseReceiptRepository] response: ${response.data}');
    }

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map(
          (item) => PurchaseReceipt.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<List<LookupOption>> fetchSuppliers({String search = ''}) async {
    final filters = <List<String>>[];
    final trimmedSearch = search.trim();
    if (trimmedSearch.isNotEmpty) {
      filters.add(['name', 'like', '%$trimmedSearch%']);
    }

    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Supplier',
      queryParameters: {
        'fields': jsonEncode(['name', 'supplier_name']),
        if (filters.isNotEmpty) 'filters': jsonEncode(filters),
        'order_by': 'supplier_name asc',
        'limit_page_length': 100,
      },
    );

    return _lookupList(response.data, labelKey: 'supplier_name');
  }

  Future<List<ItemLookupOption>> fetchItems({String search = ''}) async {
    final filters = <List<String>>[];
    final trimmedSearch = search.trim();
    if (trimmedSearch.isNotEmpty) {
      filters.add(['name', 'like', '%$trimmedSearch%']);
    }

    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Item',
      queryParameters: {
        'fields': jsonEncode(['name', 'item_name', 'stock_uom']),
        if (filters.isNotEmpty) 'filters': jsonEncode(filters),
        'order_by': 'modified desc',
        'limit_page_length': 100,
      },
    );

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map(
          (item) => ItemLookupOption.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  Future<List<PurchaseOrderReceiptOption>> fetchPurchaseOrders({
    String? supplier,
    String? itemCode,
    String search = '',
  }) async {
    final filters = <List<Object>>[
      ['status', '!=', 'Completed'],
      ['docstatus', '!=', '2'],
    ];
    final trimmedSupplier = supplier?.trim();
    final trimmedSearch = search.trim();

    if (trimmedSupplier != null && trimmedSupplier.isNotEmpty) {
      filters.add(['supplier', '=', trimmedSupplier]);
    }
    if (trimmedSearch.isNotEmpty) {
      filters.add(['name', 'like', '%$trimmedSearch%']);
    }

    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Purchase Order',
      queryParameters: {
        'fields': jsonEncode([
          'name',
          'supplier',
          'transaction_date',
          'status',
        ]),
        'filters': jsonEncode(filters),
        'order_by': 'modified desc',
        'limit_page_length': 50,
      },
    );

    if (kDebugMode) {
      debugPrint('[PurchaseReceiptRepository] PO list: ${response.data}');
    }

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! List) return const [];

    final result = <PurchaseOrderReceiptOption>[];
    for (final item in data.whereType<Map>()) {
      final summary = Map<String, dynamic>.from(item);
      final name = summary['name']?.toString() ?? '';
      if (name.isEmpty) continue;

      final detail = await fetchPurchaseOrderDetail(name);
      final matchingItems = detail.items.where((row) {
        if (itemCode == null || itemCode.trim().isEmpty) return true;
        return row.itemCode == itemCode;
      }).toList();
      if (matchingItems.isEmpty) continue;

      final pendingQty = matchingItems.fold<double>(
        0,
        (sum, row) => sum + row.pendingQty,
      );
      if (pendingQty <= 0) continue;

      result.add(
        PurchaseOrderReceiptOption(
          name: detail.name,
          supplier: detail.supplier,
          transactionDate: detail.transactionDate,
          status: detail.status,
          itemCode: itemCode ?? matchingItems.first.itemCode,
          itemName: matchingItems.first.itemName,
          uom: matchingItems.first.uom,
          pendingQty: pendingQty,
        ),
      );
    }

    return result;
  }

  Future<List<PendingPurchaseOrder>> fetchPendingPurchaseOrders({
    String? supplier,
    List<String> poNames = const [],
    String search = '',
  }) async {
    final filters = <List<Object>>[
      ['docstatus', '=', '1'],
      ['status', '!=', 'Completed'],
    ];
    final trimmedSupplier = supplier?.trim();
    final trimmedSearch = search.trim();

    if (trimmedSupplier != null && trimmedSupplier.isNotEmpty) {
      filters.add(['supplier', '=', trimmedSupplier]);
    }
    if (poNames.isNotEmpty) {
      filters.add(['name', 'in', poNames]);
    }
    if (trimmedSearch.isNotEmpty) {
      filters.add(['name', 'like', '%$trimmedSearch%']);
    }

    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Purchase Order',
      queryParameters: {
        'fields': jsonEncode(['name', 'supplier', 'transaction_date']),
        'filters': jsonEncode(filters),
        'order_by': 'transaction_date desc, modified desc',
        'limit_page_length': poNames.isEmpty ? 100 : poNames.length,
      },
    );

    if (kDebugMode) {
      debugPrint(
        '[PurchaseReceiptRepository] pending PO list: ${response.data}',
      );
    }

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map(
          (item) =>
              PendingPurchaseOrder.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.name.isNotEmpty)
        .toList();
  }

  Future<List<String>> fetchPurchaseOrderNamesByItem(String itemCode) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Purchase Order Item',
      queryParameters: {
        'fields': jsonEncode(['parent']),
        'filters': jsonEncode([
          ['item_code', '=', itemCode],
        ]),
        'limit_page_length': 100,
      },
    );

    if (kDebugMode) {
      debugPrint(
        '[PurchaseReceiptRepository] PO item parent list: ${response.data}',
      );
    }

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! List) return const [];

    final parentNames = data
        .whereType<Map>()
        .map((item) => item['parent']?.toString() ?? '')
        .where((parent) => parent.isNotEmpty)
        .toSet()
        .toList();
    if (parentNames.isNotEmpty) return parentNames;

    final rowNames = data
        .whereType<Map>()
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    final fallbackParents = <String>{};
    for (final rowName in rowNames) {
      final parent = await _fetchPurchaseOrderItemParent(rowName);
      if (parent != null && parent.isNotEmpty) fallbackParents.add(parent);
    }
    return fallbackParents.toList();
  }

  Future<List<PurchaseOrderItemSelection>> fetchPurchaseOrderItemSelections({
    required String supplier,
  }) async {
    final pendingOrders = await fetchPendingPurchaseOrders(supplier: supplier);
    final poNames = pendingOrders.map((order) => order.name).toSet();
    if (poNames.isEmpty) return const [];

    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Purchase Order Item',
      queryParameters: {
        'fields': jsonEncode([
          'name',
          'parent',
          'item_code',
          'item_name',
          'qty',
          'received_qty',
          'rate',
        ]),
        'filters': jsonEncode([
          ['docstatus', '=', '1'],
          ['parent', 'in', poNames.toList()],
        ]),
        'order_by': 'modified desc',
        'limit_page_length': 500,
      },
    );

    if (kDebugMode) {
      debugPrint(
        '[PurchaseReceiptRepository] PO item selection list: ${response.data}',
      );
    }

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! List) return const [];

    final directRows = data
        .whereType<Map>()
        .map(
          (item) => PurchaseOrderItemSelection.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (item) =>
              item.purchaseOrder.isNotEmpty &&
              poNames.contains(item.purchaseOrder) &&
              item.pendingQty > 0,
        )
        .toList();
    if (directRows.isNotEmpty) return directRows;

    final rowNames = data
        .whereType<Map>()
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    final fallbackRows = <PurchaseOrderItemSelection>[];
    for (final rowName in rowNames) {
      final row = await _fetchPurchaseOrderItemSelection(rowName);
      if (row == null) continue;
      if (!poNames.contains(row.purchaseOrder) || row.pendingQty <= 0) continue;
      fallbackRows.add(row);
    }
    return fallbackRows;
  }

  Future<String?> _fetchPurchaseOrderItemParent(String rowName) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Purchase Order Item/${Uri.encodeComponent(rowName)}',
    );

    if (kDebugMode) {
      debugPrint(
        '[PurchaseReceiptRepository] PO item detail: ${response.data}',
      );
    }

    final data = response.data is Map ? response.data['data'] : null;
    if (data is Map) return data['parent']?.toString();
    return null;
  }

  Future<PurchaseOrderItemSelection?> _fetchPurchaseOrderItemSelection(
    String rowName,
  ) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Purchase Order Item/${Uri.encodeComponent(rowName)}',
    );

    if (kDebugMode) {
      debugPrint(
        '[PurchaseReceiptRepository] PO item selection detail: '
        '${response.data}',
      );
    }

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! Map) return null;
    return PurchaseOrderItemSelection.fromJson(Map<String, dynamic>.from(data));
  }

  Future<PurchaseOrderReceiptDetail> fetchPurchaseOrderDetail(
    String name,
  ) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Purchase Order/${Uri.encodeComponent(name)}',
    );

    if (kDebugMode) {
      debugPrint('[PurchaseReceiptRepository] PO detail: ${response.data}');
    }

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! Map) {
      throw Exception('Invalid Purchase Order response.');
    }

    return PurchaseOrderReceiptDetail.fromJson(Map<String, dynamic>.from(data));
  }

  Future<String> createPurchaseReceipt({
    required String supplier,
    required DateTime postingDate,
    required String itemCode,
    required double qty,
    required String purchaseOrder,
    required String remarks,
  }) async {
    final body = {
      'doctype': 'Purchase Receipt',
      'supplier': supplier,
      'posting_date': _apiDate(postingDate),
      if (remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
      'items': [
        {'item_code': itemCode, 'qty': qty, 'purchase_order': purchaseOrder},
      ],
    };

    if (kDebugMode) {
      debugPrint('[PurchaseReceiptRepository] create body: $body');
    }

    final response = await _apiClient.post(
      '${ApiEndpoints.resource}/Purchase Receipt',
      data: body,
    );

    if (kDebugMode) {
      debugPrint(
        '[PurchaseReceiptRepository] create response: ${response.data}',
      );
    }

    final data = response.data is Map ? response.data['data'] : null;
    if (data is Map && data['name'] != null) return data['name'].toString();
    return 'Purchase Receipt';
  }

  Future<String> createPurchaseReceiptFromPurchaseOrder({
    required String supplier,
    required DateTime postingDate,
    required String purchaseOrder,
    required List<PurchaseReceiptSubmitItem> items,
  }) async {
    final body = {
      'doctype': 'Purchase Receipt',
      'supplier': supplier,
      'posting_date': _apiDate(postingDate),
      'items': items
          .map(
            (item) => {
              'item_code': item.itemCode,
              'qty': item.qty,
              'warehouse': item.warehouse,
              'purchase_order': purchaseOrder,
              if (item.purchaseOrderItem.isNotEmpty)
                'purchase_order_item': item.purchaseOrderItem,
              if (item.rate > 0) 'rate': item.rate,
            },
          )
          .toList(),
    };

    if (kDebugMode) {
      debugPrint('[PurchaseReceiptRepository] create PO receipt body: $body');
    }

    final response = await _apiClient.post(
      '${ApiEndpoints.resource}/Purchase Receipt',
      data: body,
    );

    // ignore: avoid_print
    print('CREATE: ${response.data}');

    final data = response.data is Map ? response.data['data'] : null;
    if (data is Map && data['name'] != null) return data['name'].toString();
    return 'Purchase Receipt';
  }

  Future<void> submitPurchaseReceipt(String name) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.resource}/Purchase Receipt/${Uri.encodeComponent(name)}',
      data: {'docstatus': 1},
    );

    // ignore: avoid_print
    print('SUBMIT: ${response.data}');

    final detail = await fetchPurchaseReceiptDetail(name);
    if (!detail.isSubmitted) {
      throw Exception(
        'Purchase Receipt submit completed but docstatus is ${detail.docstatus}.',
      );
    }
  }

  Future<PurchaseReceiptDetail> fetchPurchaseReceiptDetail(String name) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Purchase Receipt/${Uri.encodeComponent(name)}',
    );
    final data = response.data is Map ? response.data['data'] : null;
    if (data is! Map) throw Exception('Invalid Purchase Receipt response.');

    final attachments = await fetchAttachments(name);
    return PurchaseReceiptDetail.fromJson(
      Map<String, dynamic>.from(data),
      attachments: attachments,
    );
  }

  Future<List<ReceiptAttachment>> fetchAttachments(String name) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/File',
      queryParameters: {
        'fields': jsonEncode(['file_name', 'file_url']),
        'filters': jsonEncode([
          ['attached_to_doctype', '=', 'Purchase Receipt'],
          ['attached_to_name', '=', name],
        ]),
        'order_by': 'creation desc',
        'limit_page_length': 20,
      },
    );

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map(
          (item) => ReceiptAttachment.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.fileName.isNotEmpty || item.fileUrl.isNotEmpty)
        .toList();
  }

  Future<UploadedAttachment> uploadAttachment({
    required String filePath,
    required String fileName,
    String? docName,
  }) async {
    if (docName == null || docName.isEmpty) {
      throw Exception('Purchase Receipt docname is required for attachment.');
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'doctype': 'Purchase Receipt',
      'docname': docName,
      'is_private': '1',
    });

    if (kDebugMode) {
      debugPrint('[PurchaseReceiptRepository] upload file: $fileName');
    }

    final response = await _apiClient.post(
      '/api/method/upload_file',
      data: formData,
    );

    // ignore: avoid_print
    print('UPLOAD: ${response.data}');

    final message = response.data is Map ? response.data['message'] : null;
    final data = message is Map
        ? message
        : response.data is Map
        ? response.data['data']
        : null;
    if (data is Map) {
      final fileUrl = data['file_url']?.toString() ?? '';
      final name = data['file_name']?.toString() ?? fileName;
      if (fileUrl.isNotEmpty) {
        return UploadedAttachment(fileName: name, fileUrl: fileUrl);
      }
    }
    throw Exception('Unable to upload file.');
  }

  List<LookupOption> _lookupList(Object? responseData, {String? labelKey}) {
    final data = responseData is Map ? responseData['data'] : null;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map(
          (item) => LookupOption.fromJson(
            Map<String, dynamic>.from(item),
            labelKey: labelKey,
          ),
        )
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  String _apiDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class PendingPurchaseOrder {
  const PendingPurchaseOrder({
    required this.name,
    required this.supplier,
    required this.transactionDate,
  });

  final String name;
  final String supplier;
  final String? transactionDate;

  factory PendingPurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PendingPurchaseOrder(
      name: json['name']?.toString() ?? '',
      supplier: json['supplier']?.toString() ?? '',
      transactionDate: json['transaction_date']?.toString(),
    );
  }
}

class PurchaseOrderReceiptOption {
  const PurchaseOrderReceiptOption({
    required this.name,
    required this.supplier,
    required this.transactionDate,
    required this.status,
    required this.itemCode,
    required this.itemName,
    required this.uom,
    required this.pendingQty,
  });

  final String name;
  final String supplier;
  final String? transactionDate;
  final String status;
  final String itemCode;
  final String itemName;
  final String uom;
  final double pendingQty;
}

class PurchaseOrderItemSelection {
  const PurchaseOrderItemSelection({
    required this.rowName,
    required this.purchaseOrder,
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.receivedQty,
    required this.rate,
  });

  final String rowName;
  final String purchaseOrder;
  final String itemCode;
  final String itemName;
  final double qty;
  final double receivedQty;
  final double rate;

  double get pendingQty {
    final pending = qty - receivedQty;
    return pending > 0 ? pending : 0;
  }

  factory PurchaseOrderItemSelection.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItemSelection(
      rowName: json['name']?.toString() ?? '',
      purchaseOrder: json['parent']?.toString() ?? '',
      itemCode: json['item_code']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      qty: _toDouble(json['qty']),
      receivedQty: _toDouble(json['received_qty']),
      rate: _toDouble(json['rate']),
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PurchaseOrderReceiptDetail {
  const PurchaseOrderReceiptDetail({
    required this.name,
    required this.supplier,
    required this.transactionDate,
    required this.status,
    required this.items,
  });

  final String name;
  final String supplier;
  final String? transactionDate;
  final String status;
  final List<PurchaseOrderReceiptItem> items;

  factory PurchaseOrderReceiptDetail.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    return PurchaseOrderReceiptDetail(
      name: json['name']?.toString() ?? '',
      supplier: json['supplier']?.toString() ?? '',
      transactionDate: json['transaction_date']?.toString(),
      status: json['status']?.toString() ?? 'Draft',
      items: items is List
          ? items
                .whereType<Map>()
                .map(
                  (item) => PurchaseOrderReceiptItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((item) => item.itemCode.isNotEmpty)
                .toList()
          : const [],
    );
  }
}

class PurchaseOrderReceiptItem {
  const PurchaseOrderReceiptItem({
    required this.itemCode,
    required this.itemName,
    required this.uom,
    required this.qty,
    required this.receivedQty,
    required this.warehouse,
    required this.rowName,
    required this.rate,
  });

  final String itemCode;
  final String itemName;
  final String uom;
  final double qty;
  final double receivedQty;
  final String warehouse;
  final String rowName;
  final double rate;

  double get pendingQty {
    final pending = qty - receivedQty;
    return pending > 0 ? pending : 0;
  }

  factory PurchaseOrderReceiptItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderReceiptItem(
      itemCode: json['item_code']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      uom: json['uom']?.toString() ?? json['stock_uom']?.toString() ?? '',
      qty: _toDouble(json['qty']),
      receivedQty: _toDouble(json['received_qty']),
      warehouse: json['warehouse']?.toString() ?? '',
      rowName: json['name']?.toString() ?? '',
      rate: _toDouble(json['rate']),
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PurchaseReceiptSubmitItem {
  const PurchaseReceiptSubmitItem({
    required this.itemCode,
    required this.qty,
    required this.warehouse,
    required this.purchaseOrderItem,
    required this.rate,
  });

  final String itemCode;
  final double qty;
  final String warehouse;
  final String purchaseOrderItem;
  final double rate;
}

class PurchaseReceiptDetail {
  const PurchaseReceiptDetail({
    required this.name,
    required this.supplier,
    required this.status,
    required this.docstatus,
    required this.grandTotal,
    required this.items,
    required this.attachments,
    this.postingDate,
  });

  final String name;
  final String supplier;
  final String status;
  final int docstatus;
  final double grandTotal;
  final String? postingDate;
  final List<PurchaseReceiptDetailItem> items;
  final List<ReceiptAttachment> attachments;

  bool get isDraft => docstatus == 0;
  bool get isSubmitted => docstatus == 1;
  double get totalAmount =>
      items.fold<double>(0, (sum, item) => sum + item.amount);

  factory PurchaseReceiptDetail.fromJson(
    Map<String, dynamic> json, {
    List<ReceiptAttachment> attachments = const [],
  }) {
    final items = json['items'];
    final docstatus = _toInt(json['docstatus']);
    return PurchaseReceiptDetail(
      name: json['name']?.toString() ?? '',
      supplier: json['supplier']?.toString() ?? '-',
      status: json['status']?.toString() ?? _docStatusLabel(docstatus),
      docstatus: docstatus,
      grandTotal: _toDouble(json['grand_total'] ?? json['rounded_total']),
      postingDate: json['posting_date']?.toString(),
      items: items is List
          ? items
                .whereType<Map>()
                .map(
                  (item) => PurchaseReceiptDetailItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((item) => item.itemCode.isNotEmpty)
                .toList()
          : const [],
      attachments: attachments,
    );
  }
}

class PurchaseReceiptDetailItem {
  const PurchaseReceiptDetailItem({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.receivedQty,
    required this.warehouse,
    required this.uom,
    required this.rate,
    required this.amount,
  });

  final String itemCode;
  final String itemName;
  final double qty;
  final double receivedQty;
  final String warehouse;
  final String uom;
  final double rate;
  final double amount;

  factory PurchaseReceiptDetailItem.fromJson(Map<String, dynamic> json) {
    final qty = _toDouble(json['qty'] ?? json['accepted_qty']);
    final rate = _toDouble(json['rate'] ?? json['base_rate']);
    final amount = _toDouble(json['amount'] ?? json['base_amount']);
    return PurchaseReceiptDetailItem(
      itemCode: json['item_code']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      qty: qty,
      receivedQty: _toDouble(json['received_qty'] ?? json['qty']),
      warehouse:
          json['warehouse']?.toString() ??
          json['accepted_warehouse']?.toString() ??
          '-',
      uom: json['uom']?.toString() ?? json['stock_uom']?.toString() ?? '',
      rate: rate,
      amount: amount > 0 ? amount : qty * rate,
    );
  }
}

class ReceiptAttachment {
  const ReceiptAttachment({required this.fileName, required this.fileUrl});

  final String fileName;
  final String fileUrl;

  factory ReceiptAttachment.fromJson(Map<String, dynamic> json) {
    return ReceiptAttachment(
      fileName: json['file_name']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
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

class UploadedAttachment {
  const UploadedAttachment({required this.fileName, required this.fileUrl});

  final String fileName;
  final String fileUrl;
}
