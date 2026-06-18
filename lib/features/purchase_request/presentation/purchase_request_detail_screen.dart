import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../repositories/purchase_request_repository.dart';
import '../../../repositories/dashboard_repository.dart';
import 'purchase_request_detail_controller.dart';
import 'purchase_request_controller.dart';

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

  Future<void> _applyWorkflowAction(String action) async {
    final rejectionRemark = _isRejectAction(action)
        ? await _askRejectionRemark()
        : null;
    if (_isRejectAction(action) && rejectionRemark == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    try {
      await ref
          .read(purchaseRequestDetailControllerProvider(widget.id).notifier)
          .applyWorkflowAction(action, rejectionRemark: rejectionRemark);
      if (!mounted) return;
      ref.invalidate(purchaseRequestControllerProvider);
      ref.invalidate(dashboardDataProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.message('$action completed.'))),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<String?> _askRejectionRemark() async {
    final controller = TextEditingController();
    final l10n = context.l10n;
    final title = l10n.t('rejection_reason');
    final label = l10n.t('reason_remark_required');
    final requiredMessage = l10n.message('Rejection remark is required.');
    final cancelLabel = l10n.t('cancel');
    final rejectLabel = l10n.t('reject');
    String? errorText;
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                autofocus: true,
                minLines: 4,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: label,
                  errorText: errorText,
                  alignLabelWithHint: true,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(cancelLabel),
                ),
                FilledButton(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.isEmpty) {
                      setState(() {
                        errorText = requiredMessage;
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(value);
                  },
                  child: Text(rejectLabel),
                ),
              ],
            );
          },
        );
      },
    );
    await Future<void>.delayed(Duration.zero);
    controller.dispose();
    return result;
  }

  bool _isRejectAction(String action) {
    return action.trim().toLowerCase().contains('reject');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseRequestDetailControllerProvider(widget.id));
    final detail = state.detail;

    return Scaffold(
      appBar: CustomAppBar(title: widget.id),
      bottomNavigationBar: detail != null && state.workflowActions.isNotEmpty
          ? _WorkflowActionsBar(
              actions: state.workflowActions,
              actionInProgress: state.workflowActionInProgress,
              onAction: _applyWorkflowAction,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.isLoadingWorkflowActions)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  if (state.workflowErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _WarningBanner(
                        message: state.workflowErrorMessage!,
                      ),
                    ),
                  _DetailContent(detail: detail),
                ],
              ),
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
                  StatusBadge(label: detail.displayWorkflowState),
                ],
              ),
              const SizedBox(height: 14),
              _InfoLine(
                label: context.l10n.t('required_date'),
                value: Formatters.dateString(detail.scheduleDate),
              ),
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
                label: context.l10n.t('sub_category'),
                value: detail.subCategory.trim().isEmpty
                    ? '-'
                    : detail.subCategory,
              ),
              _InfoLine(
                label: context.l10n.t('priority'),
                value: detail.priority,
              ),
              if (detail.remark.isNotEmpty)
                _InfoLine(
                  label: context.l10n.t('remark'),
                  value: detail.remark,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (detail.materialAttachmentUrl.isNotEmpty) ...[
          Text(
            context.l10n.t('attachment'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _MaterialAttachmentCard(fileUrl: detail.materialAttachmentUrl),
          const SizedBox(height: 16),
        ],
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

class _WorkflowActionsBar extends StatelessWidget {
  const _WorkflowActionsBar({
    required this.actions,
    required this.actionInProgress,
    required this.onAction,
  });

  final List<WorkflowAction> actions;
  final String? actionInProgress;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final action in actions) ...[
              AppButton(
                label: action.action,
                icon: Icons.check_circle_outline,
                isLoading: actionInProgress == action.action,
                onPressed: actionInProgress == null
                    ? () => onAction(action.action)
                    : null,
              ),
              if (action != actions.last) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.message(message),
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialAttachmentCard extends ConsumerWidget {
  const _MaterialAttachmentCard({required this.fileUrl});

  final String fileUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = _absoluteFileUrl(fileUrl);

    return _InfoCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _MaterialAttachmentPreview(fileUrl: fileUrl),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file, color: AppColors.primary),
              ],
            ),
            if (_isImageName(fileUrl) && imageUrl != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FutureBuilder<String?>(
                  future: ref.read(secureStorageProvider).readSessionCookie(),
                  builder: (context, snapshot) {
                    final cookie = snapshot.data;
                    return Image.network(
                      imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      headers: cookie == null || cookie.isEmpty
                          ? null
                          : {'Cookie': cookie},
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 96,
                        alignment: Alignment.center,
                        color: AppColors.background,
                        child: Text(
                          context.l10n.t('image_preview_unavailable'),
                          style: const TextStyle(color: AppColors.mutedText),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MaterialAttachmentPreview extends ConsumerWidget {
  const _MaterialAttachmentPreview({required this.fileUrl});

  final String fileUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = _absoluteFileUrl(fileUrl);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('attachment'))),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: _isImageName(fileUrl) && imageUrl != null
              ? FutureBuilder<String?>(
                  future: ref.read(secureStorageProvider).readSessionCookie(),
                  builder: (context, snapshot) {
                    final cookie = snapshot.data;
                    return InteractiveViewer(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        headers: cookie == null || cookie.isEmpty
                            ? null
                            : {'Cookie': cookie},
                        errorBuilder: (context, error, stackTrace) => Text(
                          context.l10n.t('image_preview_unavailable'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                )
              : const Icon(Icons.attach_file, color: Colors.white, size: 64),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard(this.item);

  final MaterialRequestDetailItem item;

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
                  label: context.l10n.t('required_date'),
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
          if (item.remark.isNotEmpty)
            _InfoLine(label: context.l10n.t('remark'), value: item.remark),
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

String? _absoluteFileUrl(String fileUrl) {
  if (fileUrl.isEmpty) return null;
  final uri = Uri.tryParse(fileUrl);
  if (uri != null && uri.hasScheme) return uri.toString();
  return ApiConfig.baseUri.resolve(fileUrl).toString();
}

bool _isImageName(String value) {
  final lower = value.toLowerCase();
  return lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.gif');
}
