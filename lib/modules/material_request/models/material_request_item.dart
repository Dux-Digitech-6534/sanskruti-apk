import 'package:flutter/material.dart';

class MaterialRequestItem {
  MaterialRequestItem({
    String itemCode = '',
    String itemName = '',
    double quantity = 1,
    String uom = 'Nos',
    String warehouse = '',
    String requiredBy = '',
  }) : itemCodeController = TextEditingController(text: itemCode),
       itemNameController = TextEditingController(text: itemName),
       quantityController = TextEditingController(text: quantity.toString()),
       uomController = TextEditingController(text: uom),
       warehouseController = TextEditingController(text: warehouse),
       requiredByController = TextEditingController(
         text: requiredBy.trim().isEmpty ? _todayApiDate() : requiredBy,
       );

  final TextEditingController itemCodeController;
  final TextEditingController itemNameController;
  final TextEditingController quantityController;
  final TextEditingController uomController;
  final TextEditingController warehouseController;
  final TextEditingController requiredByController;

  String get itemCode => itemCodeController.text.trim();
  String get itemName => itemNameController.text.trim();
  double get quantity => double.tryParse(quantityController.text) ?? 0;
  String get uom => uomController.text.trim();
  String get warehouse => warehouseController.text.trim();
  String get requiredBy => requiredByController.text.trim();

  Map<String, dynamic> toJson() => {
    'item_code': itemCode,
    'item_name': itemName,
    'qty': quantity,
    'uom': uom,
    'warehouse': warehouse,
    'schedule_date': requiredBy,
  };

  void dispose() {
    itemCodeController.dispose();
    itemNameController.dispose();
    quantityController.dispose();
    uomController.dispose();
    warehouseController.dispose();
    requiredByController.dispose();
  }
}

String _todayApiDate() {
  final today = DateTime.now();
  final month = today.month.toString().padLeft(2, '0');
  final day = today.day.toString().padLeft(2, '0');
  return '${today.year}-$month-$day';
}
