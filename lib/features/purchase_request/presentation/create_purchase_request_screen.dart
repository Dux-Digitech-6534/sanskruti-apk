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
import '../../../l10n/app_localizations.dart';
import '../../../models/purchase_request_form_models.dart';
import '../../../repositories/purchase_request_repository.dart';
import 'create_purchase_request_controller.dart';
import 'purchase_request_controller.dart';

class CreatePurchaseRequestScreen extends ConsumerStatefulWidget {
  const CreatePurchaseRequestScreen({super.key});

  @override
  ConsumerState<CreatePurchaseRequestScreen> createState() =>
      _CreatePurchaseRequestScreenState();
}

class _CreatePurchaseRequestScreenState
    extends ConsumerState<CreatePurchaseRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _requestDateController = TextEditingController();
  final _remarkController = TextEditingController();
  bool _isOpeningFreshForm = true;

  static const _priorityOptions = [
    LookupOption(id: 'Low', label: 'Low'),
    LookupOption(id: 'Medium', label: 'Medium'),
    LookupOption(id: 'High', label: 'High'),
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('NEW FORM OPENED');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      ref.invalidate(createPurchaseRequestControllerProvider);
      final controller = ref.read(
        createPurchaseRequestControllerProvider.notifier,
      );
      controller.reset();
      final state = ref.read(createPurchaseRequestControllerProvider);
      if (state.scheduleDate != null) {
        _requestDateController.text = _displayDate(state.scheduleDate!);
      }
      debugPrint('ITEM COUNT: ${state.items.length}');
      await controller.loadLookups();
      if (!mounted) return;
      setState(() {
        _isOpeningFreshForm = false;
      });
    });
  }

  @override
  void dispose() {
    _requestDateController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _pickRequestDate() async {
    final controller = ref.read(
      createPurchaseRequestControllerProvider.notifier,
    );
    final state = ref.read(createPurchaseRequestControllerProvider);
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: state.scheduleDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (selected == null) return;
    final normalized = DateTime(selected.year, selected.month, selected.day);
    controller.setScheduleDate(normalized);
    _requestDateController.text = _displayDate(normalized);
  }

  Future<void> _openAddItemSheet() async {
    final state = ref.read(createPurchaseRequestControllerProvider);
    if (state.selectedCategory == null || state.selectedCategory!.isEmpty) {
      _showMessage('Select category before adding items.');
      return;
    }
    if (state.isLoadingItems) {
      _showMessage('Items are loading for selected category.');
      return;
    }
    if (state.filteredItems.isEmpty) {
      _showMessage('No items found for selected category.');
      return;
    }

    final item = await showModalBottomSheet<CreatePurchaseRequestItemDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddItemSheet(
        items: state.filteredItems,
        loadItemDetail: ref
            .read(createPurchaseRequestControllerProvider.notifier)
            .fetchItemDetail,
      ),
    );
    if (item == null) return;
    ref.read(createPurchaseRequestControllerProvider.notifier).addItem(item);
  }

  Future<void> _pickAttachment() async {
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
        .read(createPurchaseRequestControllerProvider.notifier)
        .captureAttachment(filePath: picked.path, fileName: picked.name);
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

  Future<void> _saveMaterialRequest() async {
    debugPrint('[CreatePurchaseRequest] Save clicked');
    if (!_formKey.currentState!.validate()) return;
    try {
      final detail = await ref
          .read(createPurchaseRequestControllerProvider.notifier)
          .createAndSave();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.message(
              'Material Request created successfully: '
              '${detail.name} (${detail.displayWorkflowState})',
            ),
          ),
        ),
      );
      ref.invalidate(purchaseRequestControllerProvider);
      context.go(
        '/purchase-request-detail/${Uri.encodeComponent(detail.name)}',
      );
    } on Object catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.message(message))));
  }

  @override
  Widget build(BuildContext context) {
    if (_isOpeningFreshForm) {
      return Scaffold(
        appBar: CustomAppBar(title: context.l10n.t('create_material_request')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final state = ref.watch(createPurchaseRequestControllerProvider);
    final controller = ref.read(
      createPurchaseRequestControllerProvider.notifier,
    );
    if (state.scheduleDate != null &&
        _requestDateController.text != _displayDate(state.scheduleDate!)) {
      _requestDateController.text = _displayDate(state.scheduleDate!);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(title: context.l10n.t('create_material_request')),
      floatingActionButton: state.isLoading
          ? null
          : FloatingActionButton.extended(
              heroTag: 'create-purchase-request-add-item',
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onPressed: state.isSubmitting ? null : _openAddItemSheet,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.t('add_item')),
            ),
      bottomNavigationBar: state.isLoading
          ? null
          : _StickySubmitBar(
              isSubmitting: state.isSubmitting,
              itemCount: state.items.length,
              onSave: _saveMaterialRequest,
            ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 152),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: state.errorMessage == null
                          ? const SizedBox.shrink()
                          : Padding(
                              key: ValueKey(state.errorMessage),
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _ErrorBanner(message: state.errorMessage!),
                            ),
                    ),
                    _SectionCard(
                      title: context.l10n.t('request_details'),
                      icon: Icons.assignment_outlined,
                      child: Column(
                        children: [
                          SearchableComboBox<LookupOption>(
                            label: context.l10n.t('project'),
                            value: state.selectedProject,
                            items: state.projects,
                            itemValue: (project) => project.id,
                            itemLabel: (project) => project.label,
                            prefixIcon: Icons.account_tree_outlined,
                            onChanged: state.isSubmitting
                                ? (_) {}
                                : controller.setProject,
                            validator: (value) => value == null
                                ? context.l10n.message('Project is required')
                                : null,
                          ),
                          const SizedBox(height: 18),
                          _WarehouseReadOnlyField(
                            warehouse: state.autoWarehouse,
                            isLoading: state.isLoadingProject,
                          ),
                          const SizedBox(height: 18),
                          SearchableComboBox<LookupOption>(
                            label: context.l10n.t('category'),
                            value: state.selectedCategory,
                            items: state.categories,
                            itemValue: (category) => category.id,
                            itemLabel: (category) => category.label,
                            prefixIcon: Icons.category_outlined,
                            onChanged: state.isSubmitting
                                ? (_) {}
                                : controller.setCategory,
                            validator: (value) => value == null
                                ? context.l10n.message('Category is required')
                                : null,
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: state.isLoadingItems
                                ? const Padding(
                                    key: ValueKey('loading-items'),
                                    padding: EdgeInsets.only(top: 14),
                                    child: LinearProgressIndicator(
                                      minHeight: 2,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 18),
                          AppTextField(
                            controller: _requestDateController,
                            hintText: context.l10n.t('required_date'),
                            prefixIcon: Icons.calendar_today_outlined,
                            readOnly: true,
                            onTap: state.isSubmitting ? null : _pickRequestDate,
                            validator: (_) => state.scheduleDate == null
                                ? context.l10n.message(
                                    'Required date is required',
                                  )
                                : null,
                          ),
                          const SizedBox(height: 18),
                          SearchableComboBox<LookupOption>(
                            label: context.l10n.t('priority'),
                            value: state.priority,
                            items: _priorityOptions,
                            itemValue: (priority) => priority.id,
                            itemLabel: (priority) => priority.label,
                            prefixIcon: Icons.priority_high_outlined,
                            onChanged: state.isSubmitting
                                ? (_) {}
                                : controller.setPriority,
                            validator: (value) => value == null
                                ? context.l10n.message('Priority is required.')
                                : null,
                          ),
                          const SizedBox(height: 18),
                          AppTextField(
                            controller: _remarkController,
                            hintText: context.l10n.t('remark'),
                            prefixIcon: Icons.notes_outlined,
                            maxLines: 3,
                            onChanged: controller.setRemark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: context.l10n.t('material_attachment'),
                      icon: Icons.image_outlined,
                      child: _AttachmentRow(
                        attachment: state.materialAttachmentDraft,
                        isUploading: state.isUploadingAttachment,
                        onAttach: state.isSubmitting ? null : _pickAttachment,
                        onClear:
                            state.isSubmitting ||
                                state.materialAttachmentDraft == null
                            ? null
                            : controller.clearAttachment,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: context.l10n.t('items'),
                      icon: Icons.inventory_2_outlined,
                      trailing: _ItemCountPill(count: state.items.length),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: state.items.isEmpty
                            ? const _EmptyItems(key: ValueKey('empty-items'))
                            : Column(
                                key: ValueKey('items-${state.items.length}'),
                                children: List.generate(
                                  state.items.length,
                                  (index) => _ItemSummaryCard(
                                    index: index,
                                    item: state.items[index],
                                    onRemove: state.isSubmitting
                                        ? null
                                        : () => controller.removeItem(index),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({
    required this.attachment,
    required this.isUploading,
    required this.onAttach,
    required this.onClear,
  });

  final MaterialRequestAttachmentDraft? attachment;
  final bool isUploading;
  final VoidCallback? onAttach;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                attachment == null
                    ? context.l10n.t('no_attachments_found')
                    : attachment!.fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: attachment == null
                      ? AppColors.mutedText
                      : AppColors.text,
                  fontWeight: attachment == null
                      ? FontWeight.w500
                      : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (attachment != null)
          IconButton(
            tooltip: context.l10n.t('clear'),
            onPressed: onClear,
            icon: const Icon(Icons.clear, color: AppColors.danger),
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

class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet({required this.items, required this.loadItemDetail});

  final List<ItemLookupOption> items;
  final Future<ItemRequestDetail> Function(String itemCode) loadItemDetail;

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _qtyController = TextEditingController();
  final _specificationController = TextEditingController();

  String? _itemCode;
  String? _itemLabel;
  DateTime? _scheduleDate;
  String _uom = '';
  double _conversionFactor = 1;
  bool _isLoadingItem = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _scheduleDate = DateTime(today.year, today.month, today.day);
    _dateController.text = _displayDate(_scheduleDate!);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _qtyController.dispose();
    _specificationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _scheduleDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (selected == null) return;
    setState(() {
      _scheduleDate = selected;
      _dateController.text = _displayDate(selected);
    });
  }

  Future<void> _setItem(String? value) async {
    if (value == null) {
      setState(() {
        _itemCode = null;
        _itemLabel = null;
        _uom = '';
        _conversionFactor = 1;
      });
      return;
    }
    final selected = widget.items.firstWhere((item) => item.id == value);
    setState(() {
      _itemCode = selected.id;
      _itemLabel = selected.label;
      _isLoadingItem = true;
      _uom = '';
      _conversionFactor = 1;
    });

    try {
      final detail = await widget.loadItemDetail(selected.id);
      if (!mounted) return;
      setState(() {
        _uom = detail.stockUom;
        _conversionFactor = detail.factor;
        _isLoadingItem = false;
      });
    } on Object catch (_) {
      if (!mounted) return;
      setState(() {
        _uom = selected.uom;
        _conversionFactor = 1;
        _isLoadingItem = false;
      });
    }
  }

  void _addItem() {
    if (_isLoadingItem) return;
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      CreatePurchaseRequestItemDraft(
        itemCode: _itemCode!,
        itemLabel: _itemLabel ?? _itemCode!,
        scheduleDate: _scheduleDate!,
        qty: double.parse(_qtyController.text),
        uom: _uom,
        conversionFactor: _conversionFactor,
        specification: _specificationController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.t('add_item'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SearchableComboBox<ItemLookupOption>(
                        label: context.l10n.t('item'),
                        value: _itemCode,
                        items: widget.items,
                        itemValue: (item) => item.id,
                        itemLabel: (item) => item.label,
                        prefixIcon: Icons.inventory_2_outlined,
                        onChanged: _setItem,
                        validator: (value) => value == null
                            ? context.l10n.message('Item is required')
                            : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _dateController,
                        hintText: context.l10n.t('required_date'),
                        prefixIcon: Icons.calendar_today_outlined,
                        readOnly: true,
                        onTap: _pickDate,
                        validator: (_) => _scheduleDate == null
                            ? context.l10n.message('Required date is required')
                            : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _qtyController,
                        hintText: context.l10n.t('quantity'),
                        prefixIcon: Icons.numbers_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final qty = double.tryParse(value ?? '');
                          if (qty == null || qty <= 0) {
                            return context.l10n.message('Qty > 0');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _specificationController,
                        hintText: context.l10n.t('specification'),
                        prefixIcon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),
                      _AutoValueTile(
                        label: context.l10n.t('uom'),
                        value: _uom.isEmpty ? '-' : _uom,
                        isLoading: _isLoadingItem,
                      ),
                      const SizedBox(height: 18),
                      AppButton(
                        label: context.l10n.t('add_item'),
                        icon: Icons.add,
                        isLoading: _isLoadingItem,
                        onPressed: _addItem,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _WarehouseReadOnlyField extends StatelessWidget {
  const _WarehouseReadOnlyField({
    required this.warehouse,
    required this.isLoading,
  });

  final String warehouse;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Icon(
              Icons.store_mall_directory_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: LinearProgressIndicator(minHeight: 2),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.t('store_warehouse'),
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        warehouse.isEmpty
                            ? context.l10n.t(
                                'auto_filled_from_selected_project',
                              )
                            : warehouse,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: warehouse.isEmpty
                              ? AppColors.mutedText
                              : AppColors.text,
                          fontWeight: warehouse.isEmpty
                              ? FontWeight.w500
                              : FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ItemSummaryCard extends StatelessWidget {
  const _ItemSummaryCard({
    required this.index,
    required this.item,
    required this.onRemove,
  });

  final int index;
  final CreatePurchaseRequestItemDraft item;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemLabel,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.event_outlined,
                      label: _displayDate(item.scheduleDate),
                    ),
                    _InfoChip(
                      icon: Icons.scale_outlined,
                      label: '${_formatQty(item.qty)} ${item.uom}',
                    ),
                  ],
                ),
                if (item.specification.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    item.specification.trim(),
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.t('remove_item'),
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _AutoValueTile extends StatelessWidget {
  const _AutoValueTile({
    required this.label,
    required this.value,
    required this.isLoading,
  });

  final String label;
  final String value;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isLoading
                ? const LinearProgressIndicator(
                    key: ValueKey('loading'),
                    minHeight: 2,
                  )
                : Text(
                    value,
                    key: ValueKey(value),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ItemCountPill extends StatelessWidget {
  const _ItemCountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        context.l10n.itemCount(count),
        style: const TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StickySubmitBar extends StatelessWidget {
  const _StickySubmitBar({
    required this.isSubmitting,
    required this.itemCount,
    required this.onSave,
  });

  final bool isSubmitting;
  final int itemCount;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              offset: const Offset(0, -8),
              blurRadius: 24,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.t('material_request'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    context.l10n.itemCountReady(itemCount),
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 170,
              child: AppButton(
                label: context.l10n.t('save'),
                isLoading: isSubmitting,
                onPressed: onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyItems extends StatelessWidget {
  const _EmptyItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: .12)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.add_shopping_cart_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.t('no_items_added'),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            context.l10n.t('select_category_then_add_item'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.mutedText),
          ),
        ],
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: .2)),
      ),
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

String _displayDate(DateTime value) {
  return Formatters.date(value);
}

String _formatQty(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}
