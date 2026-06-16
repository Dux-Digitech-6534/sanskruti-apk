import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    final color = switch (lower) {
      'approved' ||
      'completed' ||
      'received' ||
      'ordered' ||
      'partially received' => AppColors.success,
      'rejected' || 'cancelled' || 'canceled' => AppColors.danger,
      _ => AppColors.warning,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .14)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          context.l10n.status(label),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
