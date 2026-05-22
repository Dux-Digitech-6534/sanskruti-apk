import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/purchase_request.dart';
import '../models/purchase_request_form_models.dart';

final purchaseRequestRepositoryProvider = Provider<PurchaseRequestRepository>((
  ref,
) {
  return PurchaseRequestRepository(ref.watch(apiClientProvider));
});

class PurchaseRequestRepository {
  const PurchaseRequestRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PurchaseRequest>> fetchMaterialRequests({
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
      '${ApiEndpoints.resource}/Material Request',
      queryParameters: {
        'fields': jsonEncode([
          'name',
          'status',
          'schedule_date',
          'transaction_date',
          'set_warehouse',
          'material_request_type',
        ]),
        if (filters.isNotEmpty) 'filters': jsonEncode(filters),
        'order_by': 'modified desc',
        'limit_start': limitStart,
        'limit_page_length': limitPageLength,
      },
    );

    if (kDebugMode) {
      debugPrint('[PurchaseRequestRepository] response: ${response.data}');
    }

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map(
          (item) => PurchaseRequest.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<MaterialRequestDetail> fetchMaterialRequestDetail(String name) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Material Request/${Uri.encodeComponent(name)}',
    );
    final data = response.data is Map ? response.data['data'] : null;
    if (data is! Map) throw Exception('Invalid Material Request response.');
    return MaterialRequestDetail.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<LookupOption>> fetchProjects() async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Project Master',
      queryParameters: {
        'fields': jsonEncode(['name']),
        'order_by': 'name asc',
        'limit_page_length': 100,
      },
    );
    if (kDebugMode) {
      debugPrint('Project list: ${response.data}');
    }
    return _lookupList(response.data);
  }

  Future<ProjectMasterDetail> fetchProjectMaster(String project) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Project Master/${Uri.encodeComponent(project)}',
    );
    if (kDebugMode) {
      debugPrint(
        '[PurchaseRequestRepository] project detail: ${response.data}',
      );
    }

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! Map) return const ProjectMasterDetail(storeName: '');
    return ProjectMasterDetail.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<LookupOption>> fetchCategories() async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Material Category',
      queryParameters: {
        'fields': jsonEncode(['name']),
        'order_by': 'name asc',
        'limit_page_length': 100,
      },
    );
    if (kDebugMode) {
      debugPrint('Category list: ${response.data}');
    }
    return _lookupList(response.data);
  }

  Future<List<LookupOption>> fetchWarehouses() async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Warehouse',
      queryParameters: {
        'fields': jsonEncode(['name']),
        'order_by': 'name asc',
        'limit_page_length': 100,
      },
    );
    if (kDebugMode) {
      debugPrint('Warehouse list: ${response.data}');
    }
    return _lookupList(response.data);
  }

  Future<List<ItemLookupOption>> fetchItemsByCategory({
    required String category,
    String search = '',
  }) async {
    final filters = <List<String>>[];
    filters.add(['custom_category', '=', category]);
    final trimmedSearch = search.trim();
    if (trimmedSearch.isNotEmpty) {
      filters.add(['name', 'like', '%$trimmedSearch%']);
    }

    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Item',
      queryParameters: {
        'fields': jsonEncode(['name', 'item_name', 'stock_uom']),
        'filters': jsonEncode(filters),
        'order_by': 'modified desc',
        'limit_page_length': 100,
      },
    );
    if (kDebugMode) {
      debugPrint(
        '[PurchaseRequestRepository] category items: ${response.data}',
      );
    }

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

  Future<ItemRequestDetail> fetchItemDetail(String itemCode) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Item/${Uri.encodeComponent(itemCode)}',
    );

    final data = response.data is Map ? response.data['data'] : null;
    if (data is! Map) {
      return ItemRequestDetail(itemCode: itemCode, stockUom: '', factor: 1);
    }

    final detail = Map<String, dynamic>.from(data);
    final stockUom = detail['stock_uom']?.toString() ?? '';
    final factor = await fetchConversionFactor(
      itemCode: itemCode,
      uom: stockUom,
    );
    return ItemRequestDetail(
      itemCode: itemCode,
      stockUom: stockUom,
      factor: factor,
    );
  }

  Future<double> fetchConversionFactor({
    required String itemCode,
    required String uom,
  }) async {
    if (uom.isEmpty) return 1;

    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/UOM Conversion Detail',
      queryParameters: {
        'fields': jsonEncode(['uom', 'conversion_factor', 'parent']),
        'filters': jsonEncode([
          ['parent', '=', itemCode],
          ['uom', '=', uom],
        ]),
        'limit_page_length': 100,
      },
    );

    final data = response.data is Map ? response.data['data'] : null;
    if (data is List && data.isNotEmpty && data.first is Map) {
      final value = (data.first as Map)['conversion_factor'];
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 1;
    }
    return 1;
  }

  Future<String> createMaterialRequest({
    required String project,
    required String warehouse,
    required String category,
    required List<MaterialRequestItemDraft> items,
  }) async {
    final body = {
      'doctype': 'Material Request',
      'purpose': 'Purchase',
      'material_request_type': 'Purchase',
      'custom_select_project_': project,
      'set_warehouse': warehouse,
      'material_category': category,
      'schedule_date': _apiDate(items.first.scheduleDate),
      'items': items
          .map(
            (item) => {
              'item_code': item.itemCode,
              'qty': item.qty,
              'schedule_date': _apiDate(item.scheduleDate),
              'uom': item.uom,
              'conversion_factor': item.conversionFactor,
              if (item.specification.trim().isNotEmpty)
                'custom_specification': item.specification.trim(),
              if (warehouse.isNotEmpty) 'warehouse': warehouse,
            },
          )
          .toList(),
    };

    if (kDebugMode) {
      debugPrint('[PurchaseRequestRepository] create body: $body');
    }

    final response = await _apiClient.post(
      '${ApiEndpoints.resource}/Material Request',
      data: body,
    );

    if (kDebugMode) {
      debugPrint(
        '[PurchaseRequestRepository] create response: ${response.data}',
      );
    }

    final data = response.data is Map ? response.data['data'] : null;
    if (data is Map && data['name'] != null) return data['name'].toString();
    return 'Material Request';
  }

  Future<void> submitMaterialRequest(String name) async {
    try {
      await _apiClient.put(
        '${ApiEndpoints.resource}/Material Request/${Uri.encodeComponent(name)}',
        data: {'docstatus': 1},
      );
    } on Object catch (error) {
      throw MaterialRequestSubmitException(error);
    }

    final detail = await fetchMaterialRequestDetail(name);
    if (detail.docstatus != 1) {
      throw MaterialRequestSubmitException('docstatus is ${detail.docstatus}');
    }
  }

  List<LookupOption> _lookupList(Object? responseData, {String? labelKey}) {
    final data = responseData is Map ? responseData['data'] : null;
    if (data is! List) return const [];
    final names = data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    if (labelKey == null) {
      return names.map((name) => LookupOption(id: name, label: name)).toList();
    }
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map((item) => LookupOption.fromJson(item, labelKey: labelKey))
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  String _apiDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class MaterialRequestItemDraft {
  const MaterialRequestItemDraft({
    required this.itemCode,
    required this.scheduleDate,
    required this.qty,
    required this.uom,
    required this.conversionFactor,
    required this.specification,
  });

  final String itemCode;
  final DateTime scheduleDate;
  final double qty;
  final String uom;
  final double conversionFactor;
  final String specification;
}

class ProjectMasterDetail {
  const ProjectMasterDetail({required this.storeName});

  final String storeName;

  factory ProjectMasterDetail.fromJson(Map<String, dynamic> json) {
    return ProjectMasterDetail(storeName: json['store_name']?.toString() ?? '');
  }
}

class ItemRequestDetail {
  const ItemRequestDetail({
    required this.itemCode,
    required this.stockUom,
    required this.factor,
  });

  final String itemCode;
  final String stockUom;
  final double factor;
}

class MaterialRequestDetail {
  const MaterialRequestDetail({
    required this.name,
    required this.status,
    required this.docstatus,
    required this.project,
    required this.warehouse,
    required this.category,
    required this.items,
  });

  final String name;
  final String status;
  final int docstatus;
  final String project;
  final String warehouse;
  final String category;
  final List<MaterialRequestDetailItem> items;

  bool get isDraft => docstatus == 0;

  factory MaterialRequestDetail.fromJson(Map<String, dynamic> json) {
    final fallbackStatus = _docStatusLabel(_toInt(json['docstatus']));
    final items = json['items'];
    return MaterialRequestDetail(
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? fallbackStatus,
      docstatus: _toInt(json['docstatus']),
      project: json['custom_select_project_']?.toString() ?? '-',
      warehouse: json['set_warehouse']?.toString() ?? '-',
      category:
          json['material_category']?.toString() ??
          json['custom_category']?.toString() ??
          '-',
      items: items is List
          ? items
                .whereType<Map>()
                .map(
                  (item) => MaterialRequestDetailItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((item) => item.itemCode.isNotEmpty)
                .toList()
          : const [],
    );
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _docStatusLabel(int docstatus) {
    return switch (docstatus) {
      0 => 'Draft',
      1 => 'Submitted',
      2 => 'Cancelled',
      _ => 'Draft',
    };
  }
}

class MaterialRequestSubmitException implements Exception {
  const MaterialRequestSubmitException(this.cause);

  final Object cause;

  @override
  String toString() {
    final detail = cause.toString().replaceFirst('Exception: ', '');
    if (detail.isEmpty) return 'Material Request created but submit failed';
    return 'Material Request created but submit failed: $detail';
  }
}

class MaterialRequestDetailItem {
  const MaterialRequestDetailItem({
    required this.itemCode,
    required this.itemName,
    required this.uom,
    required this.qty,
    required this.scheduleDate,
    required this.specification,
  });

  final String itemCode;
  final String itemName;
  final String uom;
  final double qty;
  final String scheduleDate;
  final String specification;

  factory MaterialRequestDetailItem.fromJson(Map<String, dynamic> json) {
    return MaterialRequestDetailItem(
      itemCode: json['item_code']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      uom: json['uom']?.toString() ?? '',
      qty: _toDouble(json['qty']),
      scheduleDate: json['schedule_date']?.toString() ?? '-',
      specification: json['custom_specification']?.toString() ?? '',
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
