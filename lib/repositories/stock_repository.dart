import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepository(ref.watch(apiClientProvider));
});

class StockRepository {
  const StockRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<StockBin>> fetchStockBins() async {
    final response = await _apiClient.get(
      '${ApiEndpoints.resource}/Bin',
      queryParameters: {
        'fields': jsonEncode(['item_code', 'warehouse', 'actual_qty']),
        'order_by': 'modified desc',
        'limit_page_length': 50,
      },
    );
    final data = response.data is Map ? response.data['data'] : null;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => StockBin.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.itemCode.isNotEmpty)
        .toList();
  }
}

class StockBin {
  const StockBin({
    required this.itemCode,
    required this.warehouse,
    required this.actualQty,
  });

  final String itemCode;
  final String warehouse;
  final double actualQty;

  factory StockBin.fromJson(Map<String, dynamic> json) {
    return StockBin(
      itemCode: json['item_code']?.toString() ?? '',
      warehouse: json['warehouse']?.toString() ?? '-',
      actualQty: _toDouble(json['actual_qty']),
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
