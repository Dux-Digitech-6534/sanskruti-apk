import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';

class ListFilterButton extends StatelessWidget {
  const ListFilterButton({
    required this.fromDate,
    required this.toDate,
    required this.onChanged,
    this.label = 'Date',
    super.key,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final String label;
  final void Function(DateTime? from, DateTime? to) onChanged;

  @override
  Widget build(BuildContext context) {
    final hasFilter = fromDate != null || toDate != null;
    return OutlinedButton.icon(
      icon: Icon(hasFilter ? Icons.filter_alt : Icons.filter_alt_outlined),
      label: Text(_label(context)),
      onPressed: () async {
        final result = await showModalBottomSheet<_DateRange>(
          context: context,
          builder: (context) => _DateFilterSheet(
            label: label,
            initialFrom: fromDate,
            initialTo: toDate,
          ),
        );
        if (result == null) return;
        onChanged(result.from, result.to);
      },
    );
  }

  String _label(BuildContext context) {
    final l10n = context.l10n;
    if (fromDate == null && toDate == null) return label;
    if (fromDate != null && toDate != null) {
      return '${Formatters.date(fromDate!)} - ${Formatters.date(toDate!)}';
    }
    if (fromDate != null) {
      return l10n.fromDateLabel(fromDate!, Formatters.date(fromDate!));
    }
    return l10n.untilDateLabel(toDate!, Formatters.date(toDate!));
  }
}

class _DateFilterSheet extends StatefulWidget {
  const _DateFilterSheet({
    required this.label,
    required this.initialFrom,
    required this.initialTo,
  });

  final String label;
  final DateTime? initialFrom;
  final DateTime? initialTo;

  @override
  State<_DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<_DateFilterSheet> {
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _from = widget.initialFrom;
    _to = widget.initialTo;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.label} ${context.l10n.t('filter')}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: context.l10n.t('from'),
                    value: _from,
                    onTap: () => _pickDate(isFrom: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateTile(
                    label: context.l10n.t('to'),
                    value: _to,
                    onTap: () => _pickDate(isFrom: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(const _DateRange()),
                    child: Text(context.l10n.t('clear')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_DateRange(_from, _to)),
                    child: Text(context.l10n.t('apply')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from ?? now : _to ?? _from ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 3),
    );
    if (selected == null) return;
    setState(() {
      if (isFrom) {
        _from = selected;
        if (_to != null && _to!.isBefore(selected)) _to = selected;
      } else {
        _to = selected;
        if (_from != null && _from!.isAfter(selected)) _from = selected;
      }
    });
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.mutedText)),
            const SizedBox(height: 6),
            Text(
              value == null ? context.l10n.t('any') : Formatters.date(value!),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRange {
  const _DateRange([this.from, this.to]);

  final DateTime? from;
  final DateTime? to;
}
