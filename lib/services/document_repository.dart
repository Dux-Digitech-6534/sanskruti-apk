import 'dart:convert';

import '../core/app_constants.dart';
import '../core/models/document_summary.dart';
import 'api_client.dart';

class DocumentRepository {
  DocumentRepository(this._apiClient, this.doctype);

  final ApiClient _apiClient;
  final String doctype;

  String get _encodedDoctype => Uri.encodeComponent(doctype);

  Future<List<DocumentSummary>> list({
    String? search,
    int limit = 30,
    List<dynamic> extraFilters = const [],
    List<String> fields = const [
      'name',
      'status',
      'owner',
      'modified',
      'transaction_date',
      'schedule_date',
      'grand_total',
      'total',
    ],
  }) async {
    final filters = <dynamic>[...extraFilters];
    if (search != null && search.trim().isNotEmpty) {
      filters.add(['name', 'like', '%${search.trim()}%']);
    }
    final response = await _apiClient.dio.get(
      '${AppConstants.resourcePath}/$_encodedDoctype',
      queryParameters: {
        'fields': jsonEncode(fields),
        'limit_page_length': limit,
        'order_by': 'modified desc',
        if (filters.isNotEmpty) 'filters': jsonEncode(filters),
      },
    );
    final rows = (response.data['data'] as List? ?? const []);
    return rows
        .map((row) => DocumentSummary.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Map<String, dynamic>> getByName(String name) async {
    final response = await _apiClient.dio.get(
      '${AppConstants.resourcePath}/$_encodedDoctype/${Uri.encodeComponent(name)}',
    );
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(
      '${AppConstants.resourcePath}/$_encodedDoctype',
      data: {'doctype': doctype, ...data},
    );
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<Map<String, dynamic>> update(
    String name,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.dio.put(
      '${AppConstants.resourcePath}/$_encodedDoctype/${Uri.encodeComponent(name)}',
      data: data,
    );
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<Map<String, dynamic>> submitByAction(
    Map<String, dynamic> document,
    String action,
  ) async {
    final name = document['name']?.toString() ?? '';
    if (name.isEmpty) return const {};

    final normalizedAction = action.trim().toLowerCase();
    final payload = <String, dynamic>{
      if (normalizedAction == 'approve' || normalizedAction == 'submit')
        'docstatus': 1,
      if (normalizedAction == 'cancel') 'docstatus': 2,
    };
    if (payload.isEmpty) return document;

    return update(name, payload);
  }

  Future<List<Map<String, dynamic>>> searchLink({
    required String linkDoctype,
    required String query,
    String? referenceDoctype,
    int limit = 20,
  }) async {
    final response = await _apiClient.dio.get(
      '/api/method/frappe.desk.search.search_link',
      queryParameters: {
        'doctype': linkDoctype,
        'txt': query,
        'page_length': limit,
        'reference_doctype': referenceDoctype,
      },
    );
    final rows = response.data['message'] as List? ?? const [];
    return rows.map((row) => Map<String, dynamic>.from(row as Map)).toList();
  }
}
