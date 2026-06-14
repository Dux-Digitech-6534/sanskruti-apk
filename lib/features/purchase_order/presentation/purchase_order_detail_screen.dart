import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../repositories/purchase_order_repository.dart';

final purchaseOrderDetailProvider = FutureProvider.autoDispose
    .family<PurchaseOrderDetail, String>((ref, name) {
      return ref
          .watch(purchaseOrderRepositoryProvider)
          .fetchPurchaseOrderDetail(name);
    });

class PurchaseOrderDetailScreen extends ConsumerWidget {
  const PurchaseOrderDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(purchaseOrderDetailProvider(id));

    return Scaffold(
      appBar: CustomAppBar(title: id),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _MessageState(
          message: error.toString(),
          onRetry: () => ref.invalidate(purchaseOrderDetailProvider(id)),
        ),
        data: (order) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(purchaseOrderDetailProvider(id));
            await ref.read(purchaseOrderDetailProvider(id).future);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(order: order),
              const SizedBox(height: 16),
              Text(
                context.l10n.t('items'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (order.items.isEmpty)
                _InfoCard(child: Text(context.l10n.t('no_items_found')))
              else
                ...order.items.map(_ItemCard.new),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.order});

  final PurchaseOrderDetail order;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              StatusBadge(label: order.status),
            ],
          ),
          const SizedBox(height: 14),
          _InfoLine(label: context.l10n.t('supplier'), value: order.supplier),
          _InfoLine(
            label: context.l10n.t('order_date'),
            value: Formatters.dateString(order.transactionDate),
          ),
          _InfoLine(
            label: context.l10n.t('schedule_date'),
            value: Formatters.dateString(order.scheduleDate),
          ),
          _InfoLine(
            label: context.l10n.t('total'),
            value: Formatters.currency(order.grandTotal),
          ),
          _InfoLine(
            label: context.l10n.t('document'),
            value: order.docstatus == 0
                ? context.l10n.t('draft')
                : order.docstatus == 1
                ? context.l10n.t('submitted')
                : context.l10n.t('cancelled'),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard(this.item);

  final PurchaseOrderDetailItem item;

  @override
  Widget build(BuildContext context) {
    final title = item.itemName.isEmpty || item.itemName == item.itemCode
        ? item.itemCode
        : item.itemName;
    return _InfoCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          if (item.itemCode.trim() != title.trim()) ...[
            const SizedBox(height: 6),
            Text(
              item.itemCode,
              style: const TextStyle(color: AppColors.mutedText),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _InfoLine(
                  label: context.l10n.t('qty'),
                  value: '${_formatQty(item.qty)} ${item.uom}',
                ),
              ),
              Expanded(
                child: _InfoLine(
                  label: context.l10n.t('received'),
                  value: _formatQty(item.receivedQty),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _InfoLine(
                  label: context.l10n.t('rate'),
                  value: Formatters.currency(item.rate),
                ),
              ),
              Expanded(
                child: _InfoLine(
                  label: context.l10n.t('amount'),
                  value: Formatters.currency(item.amount),
                ),
              ),
            ],
          ),
          _InfoLine(label: context.l10n.t('warehouse'), value: item.warehouse),
          _InfoLine(
            label: context.l10n.t('schedule_date'),
            value: Formatters.dateString(item.scheduleDate),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child, this.margin});

  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.message(message), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(context.l10n.t('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatQty(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}
