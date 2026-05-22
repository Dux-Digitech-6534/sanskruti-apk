import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/erp_text_field.dart';
import '../../../widgets/responsive_shell.dart';
import '../controllers/material_request_controller.dart';
import '../models/material_request_item.dart';

class MaterialRequestCreateView extends GetView<MaterialRequestController> {
  const MaterialRequestCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveShell(
      title: 'Create Material Request',
      child: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section(
              title: 'Header',
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 720;
                  final width = wide
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 14,
                    children: [
                      _FieldBox(
                        width: width,
                        child: ErpTextField(
                          controller: controller.seriesController,
                          label: 'Series',
                        ),
                      ),
                      _FieldBox(
                        width: width,
                        child: ErpTextField(
                          controller: controller.departmentController,
                          label: 'Department',
                        ),
                      ),
                      _FieldBox(
                        width: width,
                        child: ErpTextField(
                          controller: controller.purposeController,
                          label: 'Purpose',
                        ),
                      ),
                      _FieldBox(
                        width: width,
                        child: ErpTextField(
                          controller: controller.transactionDateController,
                          label: 'Transaction Date',
                        ),
                      ),
                      _FieldBox(
                        width: width,
                        child: ErpTextField(
                          controller: controller.projectController,
                          label: 'Project',
                        ),
                      ),
                      _FieldBox(
                        width: width,
                        child: ErpTextField(
                          controller: controller.requiredByController,
                          label: 'Required By',
                        ),
                      ),
                      _FieldBox(
                        width: width,
                        child: ErpTextField(
                          controller: controller.categoryController,
                          label: 'Category',
                        ),
                      ),
                      _FieldBox(
                        width: width,
                        child: ErpTextField(
                          controller: controller.priceListController,
                          label: 'Price List',
                        ),
                      ),
                      _FieldBox(
                        width: width,
                        child: ErpTextField(
                          controller: controller.warehouseController,
                          label: 'Warehouse',
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Warehouse is required'
                              : null,
                        ),
                      ),
                      _FieldBox(
                        width: width,
                        child: ErpTextField(
                          controller: controller.remarksController,
                          label: 'Remarks',
                          maxLines: 2,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Items',
              trailing: TextButton.icon(
                onPressed: controller.addItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
              child: Obx(
                () => Column(
                  children: [
                    for (var i = 0; i < controller.items.length; i++)
                      _MaterialRequestItemCard(
                        index: i,
                        item: controller.items[i],
                        onRemove: () => controller.removeItem(i),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isSaving.value ? null : controller.submit,
                icon: controller.isSaving.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Submit Material Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(width: width, child: child);
}

class _MaterialRequestItemCard extends StatelessWidget {
  const _MaterialRequestItemCard({
    required this.index,
    required this.item,
    required this.onRemove,
  });

  final int index;
  final MaterialRequestItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Item ${index + 1}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remove item',
                  ),
                  TextButton.icon(
                    onPressed: () => _findItem(context),
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ],
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 680;
                  final fieldWidth = wide
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _FieldBox(
                        width: fieldWidth,
                        child: ErpTextField(
                          controller: item.itemCodeController,
                          label: 'Item Code',
                          icon: Icons.search,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Item code is required'
                              : null,
                        ),
                      ),
                      _FieldBox(
                        width: fieldWidth,
                        child: ErpTextField(
                          controller: item.itemNameController,
                          label: 'Item Name',
                        ),
                      ),
                      _FieldBox(
                        width: fieldWidth,
                        child: ErpTextField(
                          controller: item.quantityController,
                          label: 'Quantity',
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              (double.tryParse(value ?? '') ?? 0) <= 0
                              ? 'Quantity must be greater than zero'
                              : null,
                        ),
                      ),
                      _FieldBox(
                        width: fieldWidth,
                        child: ErpTextField(
                          controller: item.uomController,
                          label: 'UOM',
                        ),
                      ),
                      _FieldBox(
                        width: fieldWidth,
                        child: ErpTextField(
                          controller: item.warehouseController,
                          label: 'Warehouse',
                        ),
                      ),
                      _FieldBox(
                        width: fieldWidth,
                        child: ErpTextField(
                          controller: item.requiredByController,
                          label: 'Required By',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _findItem(BuildContext context) async {
    final controller = Get.find<MaterialRequestController>();
    final results = await controller.searchItems(item.itemCode);
    if (!context.mounted) return;
    if (results.isEmpty) {
      Get.snackbar('No items found', 'Try another item code or name.');
      return;
    }
    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: results.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = results[index];
          return ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text((item['value'] ?? '').toString()),
            subtitle: Text((item['description'] ?? '').toString()),
            onTap: () => Navigator.of(context).pop(item),
          );
        },
      ),
    );
    if (selected == null) return;
    item.itemCodeController.text = (selected['value'] ?? '').toString();
    item.itemNameController.text =
        (selected['description'] ?? selected['value'] ?? '').toString();
  }
}
