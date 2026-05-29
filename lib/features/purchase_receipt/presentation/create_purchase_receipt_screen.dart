import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/searchable_combo_box.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../repositories/dashboard_repository.dart';
import '../../../models/purchase_request_form_models.dart';
import '../../../repositories/purchase_receipt_repository.dart';
import '../../purchase_request/presentation/purchase_request_controller.dart';
import 'create_purchase_receipt_controller.dart';
import 'purchase_receipt_controller.dart';

class CreatePurchaseReceiptScreen extends ConsumerStatefulWidget {
  const CreatePurchaseReceiptScreen({super.key});

  @override
  ConsumerState<CreatePurchaseReceiptScreen> createState() =>
      _CreatePurchaseReceiptScreenState();
}

class _CreatePurchaseReceiptScreenState
    extends ConsumerState<CreatePurchaseReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supplierDeliveryNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final controller = ref.read(
        createPurchaseReceiptControllerProvider.notifier,
      );
      controller.reset();
      controller.loadLookups();
    });
  }

  @override
  void dispose() {
    _supplierDeliveryNoteController.dispose();
    super.dispose();
  }

  Future<void> _openPurchaseOrderItemPicker() async {
    debugPrint('[CreatePurchaseReceipt] Add PO item clicked');
    FocusScope.of(context).unfocus();

    final controller = ref.read(
      createPurchaseReceiptControllerProvider.notifier,
    );
    final currentState = ref.read(createPurchaseReceiptControllerProvider);
    if (currentState.isSaved || currentState.isSubmitted) {
      _showMessage('This Material Received is already saved.');
      return;
    }
    if (currentState.suppliers.isEmpty && !currentState.isLoadingLookups) {
      await controller.loadLookups();
      if (!mounted) return;
    }

    final lookupState = ref.read(createPurchaseReceiptControllerProvider);
    if (lookupState.suppliers.isEmpty && lookupState.errorMessage != null) {
      _showMessage(lookupState.errorMessage!);
      return;
    }

    final selected = await showModalBottomSheet<PurchaseOrderItemSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _PurchaseOrderItemPickerSheet(),
    );
    if (!mounted || selected == null) return;

    final selectedOk = await controller.selectPurchaseOrderItem(selected);
    if (!mounted || selectedOk) return;

    final error = ref
        .read(createPurchaseReceiptControllerProvider)
        .errorMessage;
    if (error != null) _showMessage(error);
  }

  Future<void> _pickAttachment(PurchaseReceiptAttachmentType type) async {
    final source = await _selectAttachmentSource();
    if (!mounted || source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 70,
    );
    if (!mounted || picked == null) return;
    if (picked.path.isEmpty) {
      _showMessage('Unable to read captured image.');
      return;
    }

    ref
        .read(createPurchaseReceiptControllerProvider.notifier)
        .captureAttachment(
          type: type,
          filePath: picked.path,
          fileName: picked.name,
        );
    _showMessage('${picked.name} captured. It will upload after save.');
  }

  Future<ImageSource?> _selectAttachmentSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.l10n.t('camera')),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.t('gallery')),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAndSubmit() async {
    debugPrint('[CreatePurchaseReceipt] Create and submit clicked');
    if (!_formKey.currentState!.validate()) return;
    try {
      final receiptName = await ref
          .read(createPurchaseReceiptControllerProvider.notifier)
          .createAndSubmit();
      if (!mounted) return;
      _showMessage('Material Received Submitted: $receiptName');
      ref.invalidate(purchaseReceiptControllerProvider);
      ref.invalidate(purchaseRequestControllerProvider);
      ref.invalidate(dashboardDataProvider);
      context.go('/purchase-receipt');
    } on Object catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.message(message))));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPurchaseReceiptControllerProvider);
    final controller = ref.read(
      createPurchaseReceiptControllerProvider.notifier,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(title: context.l10n.t('create_purchase_receipt')),
      bottomNavigationBar: state.hasReceiptItems
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: AppButton(
                label: state.isSubmitted
                    ? context.l10n.t('submitted')
                    : context.l10n.t('submit_purchase_receipt'),
                icon: Icons.check_circle_outline,
                isLoading: state.isSubmitting,
                onPressed: state.isSubmitting || state.isUploadingAttachment
                    ? null
                    : state.isSubmitted
                    ? null
                    : _createAndSubmit,
              ),
            )
          : null,
      body: state.isLoadingLookups
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  state.hasReceiptItems ? 108 : 24,
                ),
                children: [
                  if (state.errorMessage != null) ...[
                    _ErrorBanner(message: state.errorMessage!),
                    const SizedBox(height: 12),
                  ],
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.l10n.t('purchase_receipt_details'),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            if (state.isSubmitted)
                              const StatusBadge(label: 'Submitted')
                            else if (state.isSaved)
                              const StatusBadge(label: 'Draft'),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                minimumSize: const Size(0, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed:
                                  state.isLoadingLookups ||
                                      state.isSubmitting ||
                                      state.isSaved ||
                                      state.isSubmitted
                                  ? null
                                  : _openPurchaseOrderItemPicker,
                              child: Text(context.l10n.t('add_po')),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _ReadOnlyField(
                          label: context.l10n.t('supplier'),
                          value: state.selectedSupplier ?? '',
                          hint: context.l10n.t('select_from_purchase_order'),
                          icon: Icons.business_outlined,
                        ),
                        const SizedBox(height: 12),
                        _ReadOnlyField(
                          label: context.l10n.t('purchase_order'),
                          value: state.selectedPurchaseOrder?.name ?? '',
                          hint: context.l10n.t('tap_plus_select_pending_po'),
                          icon: Icons.receipt_long_outlined,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _supplierDeliveryNoteController,
                          hintText: context.l10n.t('supplier_delivery_note'),
                          prefixIcon: Icons.local_shipping_outlined,
                          readOnly: state.isSaved || state.isSubmitted,
                          onChanged: controller.setSupplierDeliveryNote,
                        ),
                        const SizedBox(height: 18),
                        _AttachmentRow(
                          title: context.l10n.t('material_receipt_attachment'),
                          attachment: state.materialAttachmentDraft,
                          isUploading: state.isUploadingMaterial,
                          onAttach: state.isSaved || state.isSubmitted
                              ? null
                              : () => _pickAttachment(
                                  PurchaseReceiptAttachmentType.material,
                                ),
                        ),
                        const SizedBox(height: 10),
                        _AttachmentRow(
                          title: context.l10n.t('invoice_receipt_attachment'),
                          attachment: state.invoiceAttachmentDraft,
                          isUploading: state.isUploadingInvoice,
                          onAttach: state.isSaved || state.isSubmitted
                              ? null
                              : () => _pickAttachment(
                                  PurchaseReceiptAttachmentType.invoice,
                                ),
                        ),
                      ],
                    ),
                  ),
                  if (state.isFetchingDetails) ...[
                    const SizedBox(height: 28),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  if (state.selectedPurchaseOrder != null &&
                      !state.isFetchingDetails) ...[
                    const SizedBox(height: 16),
                    _SelectedPurchaseOrderCard(
                      order: state.selectedPurchaseOrder!,
                    ),
                  ],
                  if (state.hasReceiptItems) ...[
                    const SizedBox(height: 18),
                    Text(
                      context.l10n.t('items'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...state.receiptItems.indexed.map(
                      (entry) => _ReceiptItemCard(
                        key: ValueKey('${entry.$1}-${entry.$2.itemCode}'),
                        item: entry.$2,
                        onQtyChanged: state.isSaved || state.isSubmitted
                            ? null
                            : (value) =>
                                  controller.updateReceiveQty(entry.$1, value),
                        onRemove: state.isSaved || state.isSubmitted
                            ? null
                            : () => controller.removeReceiptItem(entry.$1),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _PurchaseOrderItemPickerSheet extends ConsumerStatefulWidget {
  const _PurchaseOrderItemPickerSheet();

  @override
  ConsumerState<_PurchaseOrderItemPickerSheet> createState() =>
      _PurchaseOrderItemPickerSheetState();
}

class _PurchaseOrderItemPickerSheetState
    extends ConsumerState<_PurchaseOrderItemPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSupplierChanged(String? value) async {
    final controller = ref.read(
      createPurchaseReceiptControllerProvider.notifier,
    );
    controller.setSupplier(value);
    if (value == null || value.isEmpty) return;
    await controller.fetchPurchaseOrderItemSelections();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPurchaseReceiptControllerProvider);
    final groups = _groupPurchaseOrders(state.poItemSelections).where((group) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) return true;
      return group.matches(query);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: .86,
      minChildSize: .48,
      maxChildSize: .94,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.l10n.t('select_purchase_order'),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SearchableComboBox<LookupOption>(
                      label: context.l10n.t('supplier'),
                      value: state.selectedSupplier,
                      items: state.suppliers,
                      itemValue: (item) => item.id,
                      itemLabel: (item) => item.label,
                      prefixIcon: Icons.business_outlined,
                      onChanged: _onSupplierChanged,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _searchController,
                      hintText: context.l10n.t('search_po_number_item_name'),
                      prefixIcon: Icons.search,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _PurchaseOrderItemTableBody(
                  groups: groups,
                  scrollController: scrollController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PurchaseOrderItemTableBody extends ConsumerWidget {
  const _PurchaseOrderItemTableBody({
    required this.groups,
    required this.scrollController,
  });

  final List<_PurchaseOrderGroup> groups;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createPurchaseReceiptControllerProvider);

    if ((state.selectedSupplier ?? '').isEmpty) {
      return _PurchaseOrderEmptyState(
        message: context.l10n.message(
          'Select supplier to view pending Purchase Orders.',
        ),
      );
    }
    if (state.isFetchingPoItems) {
      return const Center(child: CircularProgressIndicator());
    }
    if (groups.isEmpty) {
      return _PurchaseOrderEmptyState(
        message: context.l10n.message('No pending Purchase Orders found.'),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final selected =
            state.selectedPurchaseOrder?.name == group.purchaseOrder ||
            state.selectedPoItem?.purchaseOrder == group.purchaseOrder;
        return _PurchaseOrderItemRowCard(
          group: group,
          isSelected: selected,
          onTap: () => Navigator.of(context).pop(group.selection),
        );
      },
    );
  }
}

class _PurchaseOrderItemRowCard extends StatelessWidget {
  const _PurchaseOrderItemRowCard({
    required this.group,
    required this.isSelected,
    required this.onTap,
  });

  final _PurchaseOrderGroup group;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: .08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .035),
              offset: const Offset(0, 8),
              blurRadius: 18,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.purchaseOrder,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.pendingItemCount(group.itemCount),
              style: const TextStyle(color: AppColors.mutedText),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QtyPill(
                    label: context.l10n.t('total_qty'),
                    value: group.totalQty,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QtyPill(
                    label: context.l10n.t('pending_qty'),
                    value: group.pendingQty,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseOrderGroup {
  const _PurchaseOrderGroup({required this.purchaseOrder, required this.rows});

  final String purchaseOrder;
  final List<PurchaseOrderItemSelection> rows;

  PurchaseOrderItemSelection get selection => rows.first;
  int get itemCount => rows.length;

  double get totalQty => rows.fold<double>(0, (sum, row) => sum + row.qty);

  double get pendingQty =>
      rows.fold<double>(0, (sum, row) => sum + row.pendingQty);

  bool matches(String query) {
    if (purchaseOrder.toLowerCase().contains(query)) return true;
    return rows.any((row) {
      final itemName = row.itemName.isEmpty ? row.itemCode : row.itemName;
      return row.itemCode.toLowerCase().contains(query) ||
          itemName.toLowerCase().contains(query);
    });
  }
}

List<_PurchaseOrderGroup> _groupPurchaseOrders(
  List<PurchaseOrderItemSelection> rows,
) {
  final grouped = <String, List<PurchaseOrderItemSelection>>{};
  for (final row in rows) {
    grouped.putIfAbsent(row.purchaseOrder, () => []).add(row);
  }
  return grouped.entries
      .map(
        (entry) =>
            _PurchaseOrderGroup(purchaseOrder: entry.key, rows: entry.value),
      )
      .toList(growable: false);
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
  });

  final String label;
  final String value;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('$label-$value'),
      initialValue: value.isEmpty ? hint : value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: AppColors.background,
      ),
      style: TextStyle(
        color: value.isEmpty ? AppColors.mutedText : AppColors.text,
        fontWeight: value.isEmpty ? FontWeight.w500 : FontWeight.w700,
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({
    required this.title,
    required this.attachment,
    required this.isUploading,
    required this.onAttach,
  });

  final String title;
  final ReceiptAttachmentDraft? attachment;
  final bool isUploading;
  final VoidCallback? onAttach;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (attachment != null) ...[
                const SizedBox(height: 4),
                Text(
                  attachment!.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.text,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: isUploading ? null : onAttach,
          icon: isUploading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.attach_file, size: 18),
          label: Text(context.l10n.t('attach')),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            offset: const Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SelectedPurchaseOrderCard extends StatelessWidget {
  const _SelectedPurchaseOrderCard({required this.order});

  final PendingPurchaseOrder order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  '${context.l10n.t('supplier')}: ${order.supplier}',
                  style: const TextStyle(color: AppColors.mutedText),
                ),
                const SizedBox(height: 3),
                Text(
                  '${context.l10n.t('date')}: ${Formatters.dateString(order.transactionDate)}',
                  style: const TextStyle(color: AppColors.mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptItemCard extends StatelessWidget {
  const _ReceiptItemCard({
    required this.item,
    required this.onQtyChanged,
    required this.onRemove,
    super.key,
  });

  final ReceiptDraftItem item;
  final ValueChanged<String>? onQtyChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            offset: const Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.itemName.isEmpty ? item.itemCode : item.itemName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.l10n.t('remove_item'),
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.itemCode,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QtyPill(
                  label: context.l10n.t('ordered'),
                  value: item.orderedQty,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QtyPill(
                  label: context.l10n.t('received'),
                  value: item.receivedQty,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QtyPill(
                  label: context.l10n.t('pending'),
                  value: item.pendingQty,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            initialValue: _formatQty(item.receiveQty),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            enabled: onQtyChanged != null,
            onChanged: onQtyChanged,
            validator: (value) {
              final qty = double.tryParse(value ?? '');
              if (qty == null || qty <= 0) {
                return context.l10n.message('Receive qty must be > 0');
              }
              if (qty > item.maxReceiveQty) {
                return context.l10n.message(
                  'Cannot exceed allowed tolerance qty ${_formatQty(item.maxReceiveQty)}',
                );
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: context.l10n.t('receive_qty'),
              prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: item.warehouse,
            enabled: false,
            decoration: InputDecoration(
              labelText: context.l10n.t('warehouse'),
              prefixIcon: const Icon(Icons.store_outlined, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  const _QtyPill({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            _formatQty(value),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _PurchaseOrderEmptyState extends StatelessWidget {
  const _PurchaseOrderEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.mutedText),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: .2)),
      ),
      child: Text(
        context.l10n.message(message),
        style: const TextStyle(color: AppColors.danger),
      ),
    );
  }
}

String _formatQty(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}
