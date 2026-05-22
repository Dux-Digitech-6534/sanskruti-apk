import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../repositories/purchase_request_repository.dart';
import 'purchase_request_detail_controller.dart';

class PurchaseRequestDetailScreen extends ConsumerStatefulWidget {
  const PurchaseRequestDetailScreen({required this.id, super.key});

  final String id;

  @override
  ConsumerState<PurchaseRequestDetailScreen> createState() =>
      _PurchaseRequestDetailScreenState();
}

class _PurchaseRequestDetailScreenState
    extends ConsumerState<PurchaseRequestDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(purchaseRequestDetailControllerProvider(widget.id).notifier)
          .load(),
    );
  }

  Future<void> _submit() async {
    try {
      await ref
          .read(purchaseRequestDetailControllerProvider(widget.id).notifier)
          .submit();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.message('Material Request submitted.')),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseRequestDetailControllerProvider(widget.id));
    final detail = state.detail;

    return Scaffold(
      appBar: CustomAppBar(title: widget.id),
      bottomNavigationBar: detail != null && detail.isDraft
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: AppButton(
                label: context.l10n.t('submit'),
                icon: Icons.check_circle_outline,
                isLoading: state.isSubmitting,
                onPressed: _submit,
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(purchaseRequestDetailControllerProvider(widget.id).notifier)
            .load(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null)
              _MessageState(
                message: state.errorMessage!,
                onRetry: () => ref
                    .read(
                      purchaseRequestDetailControllerProvider(
                        widget.id,
                      ).notifier,
                    )
                    .load(),
              )
            else if (detail == null)
              _MessageState(
                message: context.l10n.message('Material Request not found.'),
                onRetry: () => context.pop(),
              )
            else
              _DetailContent(detail: detail),
          ],
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.detail});

  final MaterialRequestDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      detail.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  StatusBadge(label: detail.status),
                ],
              ),
              const SizedBox(height: 14),
              _InfoLine(
                label: context.l10n.t('project'),
                value: detail.project,
              ),
              _InfoLine(
                label: context.l10n.t('warehouse'),
                value: detail.warehouse,
              ),
              _InfoLine(
                label: context.l10n.t('category'),
                value: detail.category,
              ),
              _InfoLine(
                label: context.l10n.t('document'),
                value: detail.docstatus == 0
                    ? context.l10n.t('draft')
                    : detail.docstatus == 1
                    ? context.l10n.t('submitted')
                    : context.l10n.t('cancelled'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.t('items'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (detail.items.isEmpty)
          _InfoCard(child: Text(context.l10n.t('no_items_found')))
        else
          ...detail.items.map(_ItemCard.new),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard(this.item);

  final MaterialRequestDetailItem item;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.itemName.isEmpty || item.itemName == item.itemCode
                ? item.itemCode
                : item.itemName,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            item.itemCode,
            style: const TextStyle(color: AppColors.mutedText),
          ),
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
                  label: context.l10n.t('date'),
                  value: Formatters.dateString(item.scheduleDate),
                ),
              ),
            ],
          ),
          if (item.specification.isNotEmpty)
            _InfoLine(
              label: context.l10n.t('specification'),
              value: item.specification,
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
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          Text(context.l10n.message(message), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(context.l10n.t('retry'))),
        ],
      ),
    );
  }
}

String _formatQty(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}
