class MaterialRequestStatus {
  const MaterialRequestStatus._();

  static String fromErpFields({
    required String status,
    required int docstatus,
    String? workflowState,
    String? customWorkflowStatus,
    double? perOrdered,
    double? perReceived,
  }) {
    final erpStatus = status.trim();
    final erpLower = erpStatus.toLowerCase();

    if (docstatus == 2 || erpLower.contains('cancel')) return 'Cancelled';

    final received = perReceived ?? 0;
    final ordered = perOrdered ?? 0;

    if (_containsAny(erpLower, const ['received', 'completed'])) {
      return _canonical(erpStatus);
    }
    if (received >= 100) return 'Received';
    if (received > 0) return 'Partially Received';

    if (erpLower.contains('ordered')) return _canonical(erpStatus);
    if (ordered >= 100) return 'Ordered';
    if (ordered > 0) return 'Partially Ordered';

    final workflow = _firstNonEmpty([customWorkflowStatus, workflowState]);
    final workflowLower = workflow.toLowerCase();
    if (_containsAny(workflowLower, const ['pending', 'approval'])) {
      return 'Pending Approval';
    }

    if (docstatus == 0) {
      return workflow.isNotEmpty ? workflow : 'Draft';
    }

    if (erpLower.isNotEmpty && erpLower != 'draft') {
      return _canonical(erpStatus);
    }
    if (workflow.isNotEmpty) return workflow;
    return docstatus == 1 ? 'Pending PO' : 'Draft';
  }

  static bool isPendingLike(String value) {
    final lower = value.trim().toLowerCase();
    if (lower.contains('approval') || lower == 'draft') return false;
    return _containsAny(lower, const ['pending', 'open', 'submitted']);
  }

  static bool isDraftLike(String value) {
    final lower = value.trim().toLowerCase();
    return lower == 'draft' || lower.contains('approval');
  }

  static bool isOrderedLike(String value) {
    final lower = value.trim().toLowerCase();
    return lower.contains('ordered');
  }

  static bool isReceivedLike(String value) {
    final lower = value.trim().toLowerCase();
    return lower.contains('received') || lower == 'completed';
  }

  static bool isRejectedLike(String value) {
    final lower = value.trim().toLowerCase();
    return lower.contains('reject');
  }

  static bool isCancelledLike(String value) {
    final lower = value.trim().toLowerCase();
    return lower.contains('cancel');
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  static bool _containsAny(String value, List<String> needles) {
    return needles.any(value.contains);
  }

  static String _canonical(String value) {
    final lower = value.trim().toLowerCase();
    return switch (lower) {
      'partially ordered' => 'Partially Ordered',
      'ordered' => 'Ordered',
      'partially received' => 'Partially Received',
      'received' => 'Received',
      'completed' => 'Received',
      'pending' => 'Pending PO',
      'draft' => 'Draft',
      'cancelled' || 'canceled' => 'Cancelled',
      _ => value.trim(),
    };
  }
}
