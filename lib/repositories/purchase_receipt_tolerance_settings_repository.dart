import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';

final purchaseReceiptToleranceSettingsRepositoryProvider =
    Provider<PurchaseReceiptToleranceSettingsRepository>((ref) {
      return PurchaseReceiptToleranceSettingsRepository(
        ref.watch(apiClientProvider),
      );
    });

class PurchaseReceiptToleranceSettingsRepository {
  const PurchaseReceiptToleranceSettingsRepository(this._apiClient);

  static const doctype = 'Purchase Receipt Tolerance Settings';

  final ApiClient _apiClient;

  Future<ToleranceSettingsMeta?> fetchMeta() async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.resource}/DocType/${Uri.encodeComponent(doctype)}',
      );
      final data = response.data is Map ? response.data['data'] : null;
      if (data is! Map) return null;
      return ToleranceSettingsMeta.fromJson(Map<String, dynamic>.from(data));
    } on Object {
      return null;
    }
  }

  Future<List<ToleranceSettingsDocument>> fetchList({
    String search = '',
  }) async {
    final meta = await fetchMeta();
    if (meta?.isSingle == true) {
      final detail = await fetchDetail(doctype, meta: meta);
      return [detail];
    }

    try {
      return await _fetchListPage(search: search, meta: meta);
    } on Object catch (error) {
      if (meta != null) rethrow;
      try {
        final single = await fetchDetail(doctype);
        return [single];
      } on Object {
        throw error;
      }
    }
  }

  Future<int> fetchCount() async {
    try {
      final docs = await fetchList();
      return docs.length;
    } on Object {
      return 0;
    }
  }

  Future<PurchaseReceiptToleranceRule> fetchRule() async {
    try {
      final docs = await fetchList();
      if (docs.isEmpty) return PurchaseReceiptToleranceRule.zero();
      return PurchaseReceiptToleranceRule.fromJson(docs.first.values);
    } on Object {
      return PurchaseReceiptToleranceRule.zero();
    }
  }

  Future<ToleranceSettingsDocument> fetchDetail(
    String name, {
    ToleranceSettingsMeta? meta,
  }) async {
    final loadedMeta = meta ?? await fetchMeta();
    final docName = loadedMeta?.isSingle == true ? doctype : name;
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/$encodedDoctype/${Uri.encodeComponent(docName)}',
    );
    final data = response.data is Map ? response.data['data'] : null;
    if (data is! Map) {
      throw Exception('Invalid Purchase Receipt Tolerance Settings response.');
    }
    return ToleranceSettingsDocument.fromJson(Map<String, dynamic>.from(data));
  }

  Future<String> create(Map<String, Object?> values) async {
    final body = <String, Object?>{'doctype': doctype, ...values};
    final response = await _apiClient.post(
      '${ApiEndpoints.resource}/$encodedDoctype',
      data: body,
    );
    final data = response.data is Map ? response.data['data'] : null;
    if (data is Map && data['name'] != null) return data['name'].toString();
    return doctype;
  }

  Future<void> update(String name, Map<String, Object?> values) async {
    final meta = await fetchMeta();
    final docName = meta?.isSingle == true ? doctype : name;
    await _apiClient.put(
      '${ApiEndpoints.resource}/$encodedDoctype/${Uri.encodeComponent(docName)}',
      data: values,
    );
  }

  String get encodedDoctype => Uri.encodeComponent(doctype);

  Future<List<ToleranceSettingsDocument>> _fetchListPage({
    required String search,
    required ToleranceSettingsMeta? meta,
  }) async {
    final filters = <List<String>>[];
    final trimmedSearch = search.trim();
    if (trimmedSearch.isNotEmpty) {
      filters.add(['name', 'like', '%$trimmedSearch%']);
    }

    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/$encodedDoctype',
      queryParameters: {
        'fields': jsonEncode(_listFields(meta)),
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
          (item) => ToleranceSettingsDocument.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((item) => item.name.isNotEmpty)
        .toList();
  }

  List<String> _listFields(ToleranceSettingsMeta? meta) {
    final fields = <String>{'name', 'modified'};
    if (meta != null) {
      fields.addAll(meta.listFields.map((field) => field.fieldname));
      return fields.toList();
    }
    return const ['*'];
  }
}

class PurchaseReceiptToleranceRule {
  const PurchaseReceiptToleranceRule({
    required this.globalTolerancePercentage,
    required this.enableItemOverride,
    required this.itemOverrides,
  });

  final double globalTolerancePercentage;
  final bool enableItemOverride;
  final Map<String, double> itemOverrides;

  factory PurchaseReceiptToleranceRule.zero() {
    return const PurchaseReceiptToleranceRule(
      globalTolerancePercentage: 0,
      enableItemOverride: false,
      itemOverrides: {},
    );
  }

  factory PurchaseReceiptToleranceRule.fromJson(Map<String, dynamic> json) {
    final table = json['item_override_table'];
    final overrides = <String, double>{};
    if (table is List) {
      for (final row in table.whereType<Map>()) {
        final item = row['item']?.toString().trim() ?? '';
        if (item.isEmpty) continue;
        overrides[item] = _toDouble(row['override_percentage']);
      }
    }

    return PurchaseReceiptToleranceRule(
      globalTolerancePercentage: _toDouble(json['global_tolerance_percentage']),
      enableItemOverride: _toBool(json['enable_item_override']),
      itemOverrides: overrides,
    );
  }

  double percentageFor(String itemCode) {
    if (enableItemOverride && itemOverrides.containsKey(itemCode)) {
      return itemOverrides[itemCode] ?? 0;
    }
    return globalTolerancePercentage;
  }
}

class ToleranceSettingsMeta {
  const ToleranceSettingsMeta({
    required this.name,
    required this.isSingle,
    required this.fields,
  });

  final String name;
  final bool isSingle;
  final List<ToleranceSettingsField> fields;

  List<ToleranceSettingsField> get listFields {
    return fields
        .where((field) => field.isReadableValue)
        .take(4)
        .toList(growable: false);
  }

  List<ToleranceSettingsField> get editableFields {
    return fields
        .where((field) => field.isEditableValue)
        .toList(growable: false);
  }

  factory ToleranceSettingsMeta.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'];
    return ToleranceSettingsMeta(
      name:
          json['name']?.toString() ??
          PurchaseReceiptToleranceSettingsRepository.doctype,
      isSingle: _toBool(json['issingle'] ?? json['is_single']),
      fields: rawFields is List
          ? rawFields
                .whereType<Map>()
                .map(
                  (item) => ToleranceSettingsField.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((field) => field.fieldname.isNotEmpty)
                .toList()
          : const [],
    );
  }
}

class ToleranceSettingsField {
  const ToleranceSettingsField({
    required this.fieldname,
    required this.label,
    required this.fieldtype,
    required this.options,
    required this.required,
    required this.readOnly,
    required this.hidden,
  });

  final String fieldname;
  final String label;
  final String fieldtype;
  final String options;
  final bool required;
  final bool readOnly;
  final bool hidden;

  bool get isReadableValue {
    return !hidden && !_layoutFieldTypes.contains(fieldtype);
  }

  bool get isEditableValue {
    return isReadableValue &&
        !readOnly &&
        !_systemFields.contains(fieldname) &&
        !_unsupportedEditableFieldTypes.contains(fieldtype);
  }

  List<String> get selectOptions {
    return options
        .split('\n')
        .map((option) => option.trim())
        .where((option) => option.isNotEmpty)
        .toList();
  }

  factory ToleranceSettingsField.fromJson(Map<String, dynamic> json) {
    final fieldname = json['fieldname']?.toString() ?? '';
    final label = json['label']?.toString().trim();
    return ToleranceSettingsField(
      fieldname: fieldname,
      label: label == null || label.isEmpty ? _titleCase(fieldname) : label,
      fieldtype: json['fieldtype']?.toString() ?? 'Data',
      options: json['options']?.toString() ?? '',
      required: _toBool(json['reqd']),
      readOnly: _toBool(json['read_only']),
      hidden: _toBool(json['hidden']),
    );
  }
}

class ToleranceSettingsDocument {
  const ToleranceSettingsDocument({required this.name, required this.values});

  final String name;
  final Map<String, dynamic> values;

  factory ToleranceSettingsDocument.fromJson(Map<String, dynamic> json) {
    return ToleranceSettingsDocument(
      name:
          json['name']?.toString() ??
          PurchaseReceiptToleranceSettingsRepository.doctype,
      values: json,
    );
  }

  String displayValue(ToleranceSettingsField field) {
    final value = values[field.fieldname];
    if (value == null || value.toString().trim().isEmpty) return '-';
    return value.toString();
  }
}

const _layoutFieldTypes = {
  'Section Break',
  'Column Break',
  'Tab Break',
  'HTML',
  'Button',
};

const _unsupportedEditableFieldTypes = {
  ..._layoutFieldTypes,
  'Table',
  'Table MultiSelect',
  'Image',
  'Attach',
  'Attach Image',
  'Code',
  'Fold',
  'Heading',
};

const _systemFields = {
  'name',
  'owner',
  'creation',
  'modified',
  'modified_by',
  'docstatus',
  'idx',
  'doctype',
};

bool _toBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase().trim() ?? '';
  return text == '1' || text == 'true' || text == 'yes';
}

double _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _titleCase(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
