import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../services/api_client.dart';
import '../../../services/document_repository.dart';
import '../../../widgets/responsive_shell.dart';

class PurchaseOrderApprovalView extends StatefulWidget {
  const PurchaseOrderApprovalView({super.key});

  @override
  State<PurchaseOrderApprovalView> createState() =>
      _PurchaseOrderApprovalViewState();
}

class _PurchaseOrderApprovalViewState extends State<PurchaseOrderApprovalView> {
  late final DocumentRepository _repository = DocumentRepository(
    Get.find<ApiClient>(),
    'Purchase Order',
  );
  late Map<String, dynamic> data = Map<String, dynamic>.from(
    (Get.arguments as Map?) ?? {},
  );
  bool isApproving = false;

  double get total =>
      double.tryParse((data['grand_total'] ?? data['total'] ?? 0).toString()) ??
      0;

  bool get requiresApproval => total > AppConstants.approvalThreshold;

  Future<void> _approve() async {
    final name = data['name']?.toString() ?? '';
    if (name.isEmpty) return;
    setState(() => isApproving = true);
    try {
      final latest = await _repository.getByName(name);
      final approved = await _repository.submitByAction(latest, 'Approve');
      setState(() => data = approved.isEmpty ? latest : approved);
      Get.snackbar('Approval sent', '$name was submitted in ERPNext.');
    } catch (e) {
      Get.snackbar('Approval failed', Get.find<ApiClient>().readableError(e));
    } finally {
      if (mounted) setState(() => isApproving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveShell(
      title: 'Purchase Order Approval',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name']?.toString() ?? 'Purchase Order',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Supplier: ${data['supplier'] ?? '-'}'),
                  Text('Status: ${data['status'] ?? 'Draft'}'),
                  Text('Amount: ${Formatters.currency(total)}'),
                  Text(
                    'Approval Threshold: ${Formatters.currency(AppConstants.approvalThreshold)}',
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    avatar: Icon(
                      requiresApproval
                          ? Icons.pending_actions
                          : Icons.check_circle_outline,
                    ),
                    label: Text(
                      requiresApproval
                          ? 'Approval required before PO creation'
                          : 'Direct PO creation allowed',
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isApproving ? null : Get.back,
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: requiresApproval && !isApproving
                              ? _approve
                              : null,
                          icon: isApproving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.verified),
                          label: Text(
                            requiresApproval ? 'Approve' : 'Not Required',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
