import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../constants/app_constants.dart';

class SearchableComboBox<T> extends StatelessWidget {
  const SearchableComboBox({
    required this.label,
    required this.value,
    required this.items,
    required this.itemValue,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    super.key,
  });

  final String label;
  final String? value;
  final List<T> items;
  final String Function(T item) itemValue;
  final String Function(T item) itemLabel;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedItem;
    final displayValue = selected == null ? '' : itemLabel(selected);
    final l10n = context.l10n;

    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        return TextFormField(
          key: ValueKey('$label-$value-$displayValue'),
          initialValue: displayValue,
          readOnly: true,
          enabled: enabled,
          onTap: enabled
              ? () async {
                  final selectedValue = await showModalBottomSheet<String>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (context) => _SearchablePickerSheet<T>(
                      title: label,
                      value: value,
                      items: items,
                      itemValue: itemValue,
                      itemLabel: itemLabel,
                    ),
                  );
                  if (selectedValue == null) return;
                  final nextValue = selectedValue.isEmpty
                      ? null
                      : selectedValue;
                  field.didChange(nextValue);
                  onChanged(nextValue);
                }
              : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: l10n.selectLabel(label),
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
            errorText: field.errorText,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (enabled && value != null && value!.isNotEmpty)
                  IconButton(
                    tooltip: l10n.clearLabel(label),
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      field.didChange(null);
                      onChanged(null);
                    },
                  ),
                const Icon(Icons.arrow_drop_down),
                const SizedBox(width: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  T? get _selectedItem {
    final currentValue = value;
    if (currentValue == null || currentValue.isEmpty) return null;
    for (final item in items) {
      if (itemValue(item) == currentValue) return item;
    }
    return null;
  }
}

class _SearchablePickerSheet<T> extends StatefulWidget {
  const _SearchablePickerSheet({
    required this.title,
    required this.value,
    required this.items,
    required this.itemValue,
    required this.itemLabel,
  });

  final String title;
  final String? value;
  final List<T> items;
  final String Function(T item) itemValue;
  final String Function(T item) itemLabel;

  @override
  State<_SearchablePickerSheet<T>> createState() =>
      _SearchablePickerSheetState<T>();
}

class _SearchablePickerSheetState<T> extends State<_SearchablePickerSheet<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) return true;
      return widget.itemValue(item).toLowerCase().contains(query) ||
          widget.itemLabel(item).toLowerCase().contains(query);
    }).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .82,
      minChildSize: .44,
      maxChildSize: .94,
      builder: (context, scrollController) {
        return Material(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (widget.value != null && widget.value!.isNotEmpty)
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(''),
                            child: Text(context.l10n.t('clear')),
                          ),
                        IconButton(
                          tooltip: context.l10n.t('close'),
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: context.l10n.searchLabel(widget.title),
                        prefixIcon: const Icon(Icons.search, size: 20),
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.t('no_matching_options'),
                          style: const TextStyle(color: AppColors.mutedText),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final itemValue = widget.itemValue(item);
                          final selected = itemValue == widget.value;
                          return ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            title: Text(
                              widget.itemLabel(item),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: selected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(itemValue),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
