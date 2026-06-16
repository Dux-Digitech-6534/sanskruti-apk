import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    this.tint = AppColors.primary,
    this.onTap,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withValues(alpha: .12), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .85)),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: .10),
            offset: const Offset(0, 14),
            blurRadius: 28,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: tint,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .72),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tint),
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: content,
    );
  }
}
