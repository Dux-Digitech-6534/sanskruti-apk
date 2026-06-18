import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/material_request_status.dart';
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
    String? project,
  }) async {
    final filters = <List<String>>[];
    final trimmedSearch = search.trim();
    final trimmedProject = project?.trim() ?? '';
    if (trimmedProject.isNotEmpty) {
      filters.add(['custom_select_project_', '=', trimmedProject]);
    }
    final itemSearchTerms = trimmedSearch.isEmpty
        ? const <String, List<String>>{}
        : await _fetchChildSearchTerms(
            childDoctype: 'Material Request Item',
            search: trimmedSearch,
          );
    final orFilters = <List<Object>>[];
    if (trimmedSearch.isNotEmpty) {
      orFilters.addAll([
        ['name', 'like', '%$trimmedSearch%'],
        ['custom_select_project_', 'like', '%$trimmedSearch%'],
        ['set_warehouse', 'like', '%$trimmedSearch%'],
      ]);
      if (itemSearchTerms.isNotEmpty) {
        orFilters.add(['name', 'in', itemSearchTerms.keys.toList()]);
      }
    }

    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Material Request',
      queryParameters: {
        'fields': jsonEncode([
          'name',
          'docstatus',
          'status',
          'schedule_date',
          'transaction_date',
          'set_warehouse',
          'custom_select_project_',
          'material_request_type',
          'custom_priority',
          'workflow_state',
          'custom_workflow_status',
          'per_ordered',
          'per_received',
        ]),
        if (filters.isNotEmpty) 'filters': jsonEncode(filters),
        if (orFilters.isNotEmpty) 'or_filters': jsonEncode(orFilters),
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

    return data.whereType<Map>().map((item) {
      final row = Map<String, dynamic>.from(item);
      row['_search_terms'] = itemSearchTerms[row['name']?.toString()] ?? [];
      return PurchaseRequest.fromJson(row);
    }).toList();
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

  Future<List<LookupOption>> fetchSubCategories({
    required String category,
  }) async {
    final trimmedCategory = category.trim();
    if (trimmedCategory.isEmpty) return const [];

    const attempts = [
      _SubCategoryLookupAttempt(
        doctype: 'Material Sub Category',
        categoryField: 'category',
      ),
      _SubCategoryLookupAttempt(
        doctype: 'Material Sub Category',
        categoryField: 'custom_category',
      ),
      _SubCategoryLookupAttempt(
        doctype: 'Material Sub Category',
        categoryField: 'material_category',
      ),
      _SubCategoryLookupAttempt(
        doctype: 'Material Subcategory',
        categoryField: 'category',
      ),
      _SubCategoryLookupAttempt(
        doctype: 'Material Subcategory',
        categoryField: 'custom_category',
      ),
      _SubCategoryLookupAttempt(
        doctype: 'Item Sub Category',
        categoryField: 'category',
      ),
      _SubCategoryLookupAttempt(
        doctype: 'Item Sub Category',
        categoryField: 'custom_category',
      ),
    ];

    for (final attempt in attempts) {
      try {
        final response = await _apiClient.get(
          '${ApiEndpoints.resource}/${Uri.encodeComponent(attempt.doctype)}',
          queryParameters: {
            'fields': jsonEncode(['name']),
            'filters': jsonEncode([
              [attempt.categoryField, '=', trimmedCategory],
            ]),
            'order_by': 'name asc',
            'limit_page_length': 100,
          },
        );
        final options = _lookupList(response.data);
        if (options.isNotEmpty) return options;
      } on Object {
        // Try the next likely ProcureFlow/Frappe field shape.
      }
    }

    return const [];
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
    String? subCategory,
    String search = '',
  }) async {
    final trimmedCategory = category.trim();
    final trimmedSubCategory = subCategory?.trim() ?? '';
    final trimmedSearch = search.trim();

    if (trimmedSubCategory.isNotEmpty) {
      final subCategoryItems = await _fetchItemsByFilterAttempts(
        category: trimmedCategory,
        subCategory: trimmedSubCategory,
        search: trimmedSearch,
      );
      return subCategoryItems;
    }

    return _fetchItemsByFilters(
      filters: [
        ['custom_category', '=', trimmedCategory],
      ],
      search: trimmedSearch,
    );
  }

  Future<List<ItemLookupOption>> _fetchItemsByFilterAttempts({
    required String category,
    required String subCategory,
    required String search,
  }) async {
    const attempts = [
      _ItemSubCategoryFilterAttempt(
        categoryField: 'custom_category',
        subCategoryField: 'custom_sub_category',
      ),
      _ItemSubCategoryFilterAttempt(
        categoryField: 'custom_category',
        subCategoryField: 'sub_category',
      ),
      _ItemSubCategoryFilterAttempt(
        categoryField: 'custom_category',
        subCategoryField: 'custom_subcategory',
      ),
      _ItemSubCategoryFilterAttempt(
        categoryField: 'custom_category',
        subCategoryField: 'item_sub_category',
      ),
      _ItemSubCategoryFilterAttempt(
        categoryField: 'custom_category',
        subCategoryField: 'material_sub_category',
      ),
    ];

    Object? lastError;
    for (final attempt in attempts) {
      try {
        return await _fetchItemsByFilters(
          filters: [
            [attempt.categoryField, '=', category],
            [attempt.subCategoryField, '=', subCategory],
          ],
          search: search,
        );
      } on Object catch (error) {
        lastError = error;
      }
    }

    if (lastError != null && kDebugMode) {
      debugPrint(
        '[PurchaseRequestRepository] sub category item lookup failed: '
        '$lastError',
      );
    }
    return const [];
  }

  Future<List<ItemLookupOption>> _fetchItemsByFilters({
    required List<List<String>> filters,
    required String search,
  }) async {
    final effectiveFilters = [...filters];
    if (search.isNotEmpty) {
      effectiveFilters.add(['name', 'like', '%$search%']);
    }
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Item',
      queryParameters: {
        'fields': jsonEncode(['name', 'item_name', 'stock_uom']),
        'filters': jsonEncode(effectiveFilters),
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
    String? subCategory,
    required DateTime scheduleDate,
    required String priority,
    required String remark,
    required List<MaterialRequestItemDraft> items,
  }) async {
    final body = {
      'doctype': 'Material Request',
      'purpose': 'Purchase',
      'material_request_type': 'Purchase',
      'custom_select_project_': project,
      'set_warehouse': warehouse,
      'material_category': category,
      'custom_category': category,
      if (subCategory?.trim().isNotEmpty == true)
        'custom_sub_category': subCategory!.trim(),
      'custom_priority': priority,
      if (remark.trim().isNotEmpty) 'custom_remark': remark.trim(),
      'schedule_date': _apiDate(scheduleDate),
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
              if (item.remark.trim().isNotEmpty)
                'custom_remark': item.remark.trim(),
              if (warehouse.isNotEmpty) 'warehouse': warehouse,
            },
          )
          .toList(),
    };

    if (kDebugMode) {
      debugPrint('[PurchaseRequestRepository] create body: $body');
    }

    final response = await _createMaterialRequestWithOptionalSubCategory(
      body: body,
      hasSubCategory: subCategory?.trim().isNotEmpty == true,
    );

    if (kDebugMode) {
      debugPrint(
        '[PurchaseRequestRepository] create response: ${response.data}',
      );
    }

    final data = response.data is Map ? response.data['data'] : null;
    if (data is Map && data['name'] != null) return data['name'].toString();
    throw Exception('Material Request created but could not be reloaded');
  }

  Future<Response<dynamic>> _createMaterialRequestWithOptionalSubCategory({
    required Map<String, Object> body,
    required bool hasSubCategory,
  }) async {
    try {
      return await _apiClient.post(
        '${ApiEndpoints.resource}/Material Request',
        data: body,
      );
    } on Object catch (error) {
      if (!hasSubCategory || !_looksLikeUnknownField(error)) rethrow;
      final fallbackBody = Map<String, Object>.from(body)
        ..remove('custom_sub_category');
      return _apiClient.post(
        '${ApiEndpoints.resource}/Material Request',
        data: fallbackBody,
      );
    }
  }

  bool _looksLikeUnknownField(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('custom_sub_category') ||
        message.contains('unknown') ||
        message.contains('field not permitted') ||
        message.contains('not found');
  }

  Future<UploadedMaterialAttachment> uploadMaterialAttachment({
    required String filePath,
    required String fileName,
    required String docName,
  }) async {
    if (docName.trim().isEmpty) {
      throw Exception('Material Request docname is required for attachment.');
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'doctype': 'Material Request',
      'docname': docName,
      'is_private': '1',
    });

    final response = await _apiClient.post(
      '/api/method/upload_file',
      data: formData,
    );

    final data = _uploadedFileData(response.data);
    final fileUrl = data['file_url']?.toString() ?? '';
    final uploadedName = data['file_name']?.toString() ?? fileName;
    if (fileUrl.isEmpty) throw Exception('Unable to upload file.');

    return UploadedMaterialAttachment(fileName: uploadedName, fileUrl: fileUrl);
  }

  Future<void> updateMaterialAttachment({
    required String name,
    required String fileUrl,
  }) async {
    await _apiClient.put(
      '${ApiEndpoints.resource}/Material Request/${Uri.encodeComponent(name)}',
      data: {'custom_add_receipt': fileUrl},
    );
  }

  Future<List<WorkflowAction>> fetchAllowedWorkflowActions(
    MaterialRequestDetail detail,
  ) async {
    final response = await _apiClient.post(
      '/api/method/frappe.model.workflow.get_transitions',
      data: {'doc': jsonEncode(detail.rawData)},
    );
    final message = _methodMessage(response.data);
    if (message is! List) return const [];
    return _uniqueWorkflowActions(
      message
          .whereType<Map>()
          .map(
            (item) => WorkflowAction.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((action) => action.action.trim().isNotEmpty)
          .toList(),
    );
  }

  Future<void> applyWorkflowAction({
    required MaterialRequestDetail detail,
    required String action,
    String? rejectionRemark,
  }) async {
    final remark = rejectionRemark?.trim() ?? '';
    var workflowDoc = Map<String, dynamic>.from(detail.rawData);
    if (_isRejectAction(action) && remark.isNotEmpty) {
      final fieldname = await _saveRejectionRemark(detail.name, remark);
      workflowDoc[fieldname] = remark;
    }

    await _apiClient.post(
      '/api/method/frappe.model.workflow.apply_workflow',
      data: {'doc': jsonEncode(workflowDoc), 'action': action},
    );
  }

  Future<String> _saveRejectionRemark(String name, String remark) async {
    final candidates = await _rejectionRemarkFieldCandidates();
    Object? lastError;
    for (final fieldname in candidates) {
      try {
        await _apiClient.put(
          '${ApiEndpoints.resource}/Material Request/${Uri.encodeComponent(name)}',
          data: {fieldname: remark},
        );
        return fieldname;
      } on Object catch (error) {
        lastError = error;
      }
    }
    throw Exception(
      'Unable to save rejection remark. ${lastError ?? 'Field not found.'}',
    );
  }

  Future<List<String>> _rejectionRemarkFieldCandidates() async {
    final discovered = <String>[];
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.resource}/Custom Field',
        queryParameters: {
          'fields': jsonEncode(['fieldname', 'label']),
          'filters': jsonEncode([
            ['dt', '=', 'Material Request'],
          ]),
          'limit_page_length': 200,
        },
      );
      final data = response.data is Map ? response.data['data'] : null;
      if (data is List) {
        for (final row in data.whereType<Map>()) {
          final label = row['label']?.toString().trim().toLowerCase() ?? '';
          final fieldname = row['fieldname']?.toString().trim() ?? '';
          if (fieldname.isEmpty) continue;
          final isRejectionField =
              label.contains('rejection') &&
              (label.contains('remark') || label.contains('reason'));
          if (isRejectionField) discovered.add(fieldname);
        }
      }
    } on Object {
      // Metadata access can be restricted; fall back to the common Frappe fieldname.
    }

    final candidates = [
      ...discovered,
      'custom_rejection_remark',
      'custom_rejection_reason',
      'rejection_remark',
    ];
    final unique = <String>{};
    return [
      for (final fieldname in candidates)
        if (unique.add(fieldname)) fieldname,
    ];
  }

  bool _isRejectAction(String action) {
    return action.trim().toLowerCase().contains('reject');
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

  Map<String, dynamic> _uploadedFileData(Object? responseData) {
    final root = responseData is Map ? responseData : const {};
    final message = root['message'];
    final data = message is Map ? message : root['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return const {};
  }

  Object? _methodMessage(Object? responseData) {
    final root = responseData is Map ? responseData : const {};
    return root['message'];
  }

  List<WorkflowAction> _uniqueWorkflowActions(List<WorkflowAction> actions) {
    final seen = <String>{};
    final unique = <WorkflowAction>[];
    for (final action in actions) {
      final name = action.action.trim();
      final key = name.toLowerCase();
      if (key.isEmpty || !seen.add(key)) continue;
      unique.add(action);
    }
    return unique;
  }
}

class _SubCategoryLookupAttempt {
  const _SubCategoryLookupAttempt({
    required this.doctype,
    required this.categoryField,
  });

  final String doctype;
  final String categoryField;
}

class _ItemSubCategoryFilterAttempt {
  const _ItemSubCategoryFilterAttempt({
    required this.categoryField,
    required this.subCategoryField,
  });

  final String categoryField;
  final String subCategoryField;
}

class MaterialRequestItemDraft {
  const MaterialRequestItemDraft({
    required this.itemCode,
    required this.scheduleDate,
    required this.qty,
    required this.uom,
    required this.conversionFactor,
    required this.specification,
    required this.remark,
  });

  final String itemCode;
  final DateTime scheduleDate;
  final double qty;
  final String uom;
  final double conversionFactor;
  final String specification;
  final String remark;
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
    required this.scheduleDate,
    required this.project,
    required this.warehouse,
    required this.category,
    required this.subCategory,
    required this.priority,
    required this.workflowState,
    required this.customWorkflowStatus,
    required this.perOrdered,
    required this.perReceived,
    required this.remark,
    required this.materialAttachmentUrl,
    required this.items,
    required this.rawData,
  });

  final String name;
  final String status;
  final int docstatus;
  final String scheduleDate;
  final String project;
  final String warehouse;
  final String category;
  final String subCategory;
  final String priority;
  final String workflowState;
  final String customWorkflowStatus;
  final double? perOrdered;
  final double? perReceived;
  final String remark;
  final String materialAttachmentUrl;
  final List<MaterialRequestDetailItem> items;
  final Map<String, dynamic> rawData;

  bool get isDraft => docstatus == 0;
  String get displayWorkflowState {
    return MaterialRequestStatus.fromErpFields(
      status: status,
      docstatus: docstatus,
      workflowState: workflowState,
      customWorkflowStatus: customWorkflowStatus,
      perOrdered: perOrdered,
      perReceived: perReceived,
    );
  }

  factory MaterialRequestDetail.fromJson(Map<String, dynamic> json) {
    final fallbackStatus = _docStatusLabel(_toInt(json['docstatus']));
    final items = json['items'];
    return MaterialRequestDetail(
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? fallbackStatus,
      docstatus: _toInt(json['docstatus']),
      scheduleDate:
          json['schedule_date']?.toString() ??
          json['transaction_date']?.toString() ??
          '',
      project: json['custom_select_project_']?.toString() ?? '-',
      warehouse: json['set_warehouse']?.toString() ?? '-',
      category:
          json['custom_category']?.toString() ??
          json['material_category']?.toString() ??
          '-',
      subCategory:
          json['custom_sub_category']?.toString() ??
          json['sub_category']?.toString() ??
          json['custom_subcategory']?.toString() ??
          json['item_sub_category']?.toString() ??
          json['material_sub_category']?.toString() ??
          '',
      priority: json['custom_priority']?.toString() ?? 'Medium',
      workflowState: json['workflow_state']?.toString() ?? '',
      customWorkflowStatus: json['custom_workflow_status']?.toString() ?? '',
      perOrdered: _nullableDouble(
        json['per_ordered'] ?? json['percent_ordered'],
      ),
      perReceived: _nullableDouble(
        json['per_received'] ?? json['percent_received'],
      ),
      remark:
          json['custom_rejection_remark']?.toString() ??
          json['custom_rejection_reason']?.toString() ??
          json['rejection_remark']?.toString() ??
          json['custom_remark']?.toString() ??
          '',
      materialAttachmentUrl:
          json['custom_add_receipt']?.toString() ??
          json['custom_material_attachment']?.toString() ??
          '',
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
      rawData: json,
    );
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _nullableDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
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

class WorkflowAction {
  const WorkflowAction({
    required this.action,
    required this.nextState,
    required this.allowed,
  });

  final String action;
  final String nextState;
  final String allowed;

  factory WorkflowAction.fromJson(Map<String, dynamic> json) {
    return WorkflowAction(
      action: json['action']?.toString() ?? '',
      nextState: json['next_state']?.toString() ?? '',
      allowed: json['allowed']?.toString() ?? '',
    );
  }
}

class UploadedMaterialAttachment {
  const UploadedMaterialAttachment({
    required this.fileName,
    required this.fileUrl,
  });

  final String fileName;
  final String fileUrl;
}

class MaterialRequestDetailItem {
  const MaterialRequestDetailItem({
    required this.itemCode,
    required this.itemName,
    required this.uom,
    required this.qty,
    required this.scheduleDate,
    required this.specification,
    required this.remark,
  });

  final String itemCode;
  final String itemName;
  final String uom;
  final double qty;
  final String scheduleDate;
  final String specification;
  final String remark;

  factory MaterialRequestDetailItem.fromJson(Map<String, dynamic> json) {
    return MaterialRequestDetailItem(
      itemCode: json['item_code']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      uom: json['uom']?.toString() ?? '',
      qty: _toDouble(json['qty']),
      scheduleDate: json['schedule_date']?.toString() ?? '-',
      specification: json['custom_specification']?.toString() ?? '',
      remark: json['custom_remark']?.toString() ?? '',
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
