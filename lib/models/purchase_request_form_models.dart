class LookupOption {
  const LookupOption({required this.id, required this.label});

  final String id;
  final String label;

  factory LookupOption.fromJson(Map<String, dynamic> json, {String? labelKey}) {
    final id = json['name']?.toString() ?? '';
    final label = labelKey == null
        ? id
        : json[labelKey]?.toString().trim().isNotEmpty == true
        ? json[labelKey].toString()
        : id;
    return LookupOption(id: id, label: label);
  }
}

class ItemLookupOption extends LookupOption {
  const ItemLookupOption({
    required super.id,
    required super.label,
    required this.uom,
  });

  final String uom;

  factory ItemLookupOption.fromJson(Map<String, dynamic> json) {
    final id = json['name']?.toString() ?? '';
    final itemName = json['item_name']?.toString().trim();
    final label = itemName == null || itemName.isEmpty || itemName == id
        ? id
        : '$id - $itemName';
    return ItemLookupOption(
      id: id,
      label: label,
      uom: json['stock_uom']?.toString() ?? '',
    );
  }
}
