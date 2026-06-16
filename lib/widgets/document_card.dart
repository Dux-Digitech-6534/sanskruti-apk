import 'package:flutter/material.dart';

import '../core/models/document_summary.dart';
import '../core/utils/formatters.dart';

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.document,
    required this.icon,
    required this.onTap,
  });

  final DocumentSummary document;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amount = document.grandTotal;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.14),
                foregroundColor: Theme.of(context).colorScheme.secondary,
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${document.status}  |  ${document.modified}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (amount > 0)
                Text(
                  Formatters.currency(amount),
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
