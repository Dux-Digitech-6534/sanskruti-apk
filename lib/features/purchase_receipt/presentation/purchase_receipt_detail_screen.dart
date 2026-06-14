import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../repositories/purchase_receipt_repository.dart';
import 'purchase_receipt_controller.dart';

final purchaseReceiptDetailProvider = FutureProvider.autoDispose
    .family<PurchaseReceiptDetail, String>((ref, name) {
      return ref
          .watch(purchaseReceiptRepositoryProvider)
          .fetchPurchaseReceiptDetail(name);
    });

class PurchaseReceiptDetailScreen extends ConsumerStatefulWidget {
  const PurchaseReceiptDetailScreen({required this.id, super.key});

  final String id;

  @override
  ConsumerState<PurchaseReceiptDetailScreen> createState() =>
      _PurchaseReceiptDetailScreenState();
}

class _PurchaseReceiptDetailScreenState
    extends ConsumerState<PurchaseReceiptDetailScreen> {
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(purchaseReceiptRepositoryProvider)
          .submitPurchaseReceipt(widget.id);
      ref.invalidate(purchaseReceiptDetailProvider(widget.id));
      ref.invalidate(purchaseReceiptControllerProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.message('Material Received Submitted.')),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.message(error.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(purchaseReceiptDetailProvider(widget.id));

    return Scaffold(
      appBar: CustomAppBar(title: widget.id),
      bottomNavigationBar: detail.maybeWhen(
        data: (receipt) => receipt.isDraft
            ? SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: AppButton(
                  label: context.l10n.t('submit'),
                  icon: Icons.check_circle_outline,
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              )
            : null,
        orElse: () => null,
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _MessageState(
          message: error.toString(),
          onRetry: () =>
              ref.invalidate(purchaseReceiptDetailProvider(widget.id)),
        ),
        data: (receipt) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(purchaseReceiptDetailProvider(widget.id));
            await ref.read(purchaseReceiptDetailProvider(widget.id).future);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(receipt: receipt),
              const SizedBox(height: 16),
              Text(
                context.l10n.t('items'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (receipt.items.isEmpty)
                _InfoCard(child: Text(context.l10n.t('no_items_found')))
              else
                ...receipt.items.map(_ItemCard.new),
              if (receipt.items.isNotEmpty) ...[
                const SizedBox(height: 6),
                _TotalAmountCard(receipt: receipt),
              ],
              const SizedBox(height: 16),
              Text(
                context.l10n.t('attachments'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (receipt.attachments.isEmpty)
                _InfoCard(child: Text(context.l10n.t('no_attachments_found')))
              else
                ...receipt.attachments.map(_AttachmentCard.new),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.receipt});

  final PurchaseReceiptDetail receipt;

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
                  receipt.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              StatusBadge(
                label: receipt.isSubmitted ? 'Submitted' : receipt.status,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoLine(label: context.l10n.t('supplier'), value: receipt.supplier),
          _InfoLine(
            label: context.l10n.t('posting_date'),
            value: Formatters.dateString(receipt.postingDate),
          ),
          if (receipt.supplierDeliveryNote.isNotEmpty)
            _InfoLine(
              label: context.l10n.t('supplier_delivery_note'),
              value: receipt.supplierDeliveryNote,
            ),
          _InfoLine(
            label: context.l10n.t('total'),
            value: Formatters.currency(
              receipt.grandTotal > 0 ? receipt.grandTotal : receipt.totalAmount,
            ),
          ),
          _InfoLine(
            label: context.l10n.t('document'),
            value: receipt.isSubmitted
                ? context.l10n.t('submitted')
                : receipt.isDraft
                ? context.l10n.t('draft')
                : context.l10n.t('cancelled'),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard(this.item);

  final PurchaseReceiptDetailItem item;

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
                  label: context.l10n.t('warehouse'),
                  value: item.warehouse,
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
          if (item.remark.isNotEmpty)
            _InfoLine(label: context.l10n.t('remark'), value: item.remark),
        ],
      ),
    );
  }
}

class _TotalAmountCard extends StatelessWidget {
  const _TotalAmountCard({required this.receipt});

  final PurchaseReceiptDetail receipt;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.t('total_amount'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            Formatters.currency(receipt.totalAmount),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _AttachmentCard extends ConsumerWidget {
  const _AttachmentCard(this.attachment);

  final ReceiptAttachment attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = _absoluteFileUrl(attachment.fileUrl);

    return _InfoCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _AttachmentPreview(attachment: attachment),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    attachment.fileName.isEmpty
                        ? attachment.fileUrl
                        : attachment.fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            if (_looksLikeImage(attachment) && imageUrl != null) ...[
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

class _AttachmentPreview extends ConsumerWidget {
  const _AttachmentPreview({required this.attachment});

  final ReceiptAttachment attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = _absoluteFileUrl(attachment.fileUrl);
    final title = attachment.fileName.isEmpty
        ? context.l10n.t('attachments')
        : attachment.fileName;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: Center(
          child: _looksLikeImage(attachment) && imageUrl != null
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

String? _absoluteFileUrl(String fileUrl) {
  if (fileUrl.isEmpty) return null;
  final uri = Uri.tryParse(fileUrl);
  if (uri != null && uri.hasScheme) return uri.toString();
  return ApiConfig.baseUri.resolve(fileUrl).toString();
}

bool _looksLikeImage(ReceiptAttachment attachment) {
  final lowerUrl = attachment.fileUrl.toLowerCase();
  final lowerName = attachment.fileName.toLowerCase();
  return _isImageName(lowerUrl) || _isImageName(lowerName);
}

bool _isImageName(String value) {
  return value.endsWith('.jpg') ||
      value.endsWith('.jpeg') ||
      value.endsWith('.png') ||
      value.endsWith('.webp') ||
      value.endsWith('.gif');
}
