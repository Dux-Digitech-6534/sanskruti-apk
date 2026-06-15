import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('hi')];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    _AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  bool get isHindi => locale.languageCode == 'hi';

  String t(String key) {
    if (!isHindi) return _en[key] ?? key;
    return _hi[key] ?? _en[key] ?? key;
  }

  String status(String value) {
    final key = value.trim().toLowerCase();
    final statusKey = 'status.$key';
    final translated = t(statusKey);
    return translated == statusKey ? t(key) : translated;
  }

  String message(String value) {
    if (!isHindi) return value;
    final trimmed = value.trim();
    final exact = _messageHi[trimmed];
    if (exact != null) return exact;

    final submittedMatch = RegExp(r'^(.+) submitted\.$').firstMatch(trimmed);
    if (submittedMatch != null) {
      return '${submittedMatch.group(1)} सबमिट हो गया।';
    }

    final capturedMatch = RegExp(
      r'^(.+) captured\. It will upload after save\.$',
    ).firstMatch(trimmed);
    if (capturedMatch != null) {
      return '${capturedMatch.group(1)} कैप्चर हुआ। यह सेव के बाद अपलोड होगा।';
    }

    final receiptSubmitted = RegExp(
      r'^(Purchase Receipt|Material Received) Submitted: (.+)$',
    ).firstMatch(trimmed);
    if (receiptSubmitted != null) {
      return 'मटेरियल रिसीट सबमिट हुई: ${receiptSubmitted.group(2)}';
    }

    final itemFullyReceived = RegExp(
      r'^(.+) is fully received\.$',
    ).firstMatch(trimmed);
    if (itemFullyReceived != null) {
      return '${itemFullyReceived.group(1)} पूरी तरह रिसीव हो चुका है।';
    }

    final itemUomRequired = RegExp(
      r'^(.+) UOM is required\.$',
    ).firstMatch(trimmed);
    if (itemUomRequired != null) {
      return '${itemUomRequired.group(1)} UOM आवश्यक है।';
    }

    final itemReceiveQtyPending = RegExp(
      r'^(.+) receive qty cannot exceed (current )?pending qty\.$',
    ).firstMatch(trimmed);
    if (itemReceiveQtyPending != null) {
      return '${itemReceiveQtyPending.group(1)} रिसीव मात्रा लंबित मात्रा से अधिक नहीं हो सकती।';
    }

    final itemWarehouseRequired = RegExp(
      r'^(.+) warehouse is required\.$',
    ).firstMatch(trimmed);
    if (itemWarehouseRequired != null) {
      return '${itemWarehouseRequired.group(1)} वेयरहाउस आवश्यक है।';
    }

    return trimmed;
  }

  String selectLabel(String label) => '${t('select')} $label';
  String clearLabel(String label) => '${t('clear')} $label';
  String searchLabel(String label) => '${t('search')} ${label.toLowerCase()}';
  String fromDateLabel(DateTime date, String formatted) =>
      '${t('from')} $formatted';
  String untilDateLabel(DateTime date, String formatted) =>
      '${t('until')} $formatted';
  String itemCount(int count) =>
      '$count ${count == 1 ? t('item') : t('items')}';
  String itemCountReady(int count) =>
      '$count ${count == 1 ? t('item') : t('items')} ${t('ready')}';
  String pendingItemCount(int count) =>
      '$count ${t('pending')} ${count == 1 ? t('item') : t('items')}';
  String role(String value) => '${t('role')}: $value';
  String site(String value) => '${t('site')}: $value';
  String hello(String value) => '${t('hello')}, $value';
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

const _en = <String, String>{
  'add': 'Add',
  'add_item_with_plus': '+ Add Item',
  'add_po': '+ Add PO',
  'add_invoice_receipt': 'Add Invoice Receipt',
  'add_item': 'Add Item',
  'add_material_receipt': 'Add Material Received',
  'all': 'All',
  'all_projects': 'All Projects',
  'amount': 'Amount',
  'any': 'Any',
  'apply': 'Apply',
  'approved': 'Approved',
  'attachment': 'Attachment',
  'attach': 'Attach',
  'attachments': 'Attachments',
  'auto_filled_from_selected_project': 'Auto filled from selected project',
  'cancel': 'Cancel',
  'camera': 'Camera',
  'cancelled': 'Cancelled',
  'category': 'Category',
  'clear': 'Clear',
  'close': 'Close',
  'completed': 'Completed',
  'conversion_factor': 'Conversion Factor',
  'create_material_request': 'Create Material Request',
  'create_purchase_receipt': 'Create Material Received',
  'dashboard': 'Dashboard',
  'date': 'Date',
  'document': 'Document',
  'draft': 'Draft',
  'edit': 'Edit',
  'email_mobile_number': 'Email / Mobile Number',
  'user_id': 'User ID',
  'english': 'English',
  'filtered': 'Filtered',
  'filter': 'filter',
  'forgot_password': 'Forgot Password?',
  'from': 'From',
  'from_date': 'From Date',
  'grand_total': 'Grand Total',
  'gallery': 'Gallery',
  'hello': 'Hello',
  'hindi': 'हिंदी',
  'home': 'Home',
  'image_preview_unavailable': 'Image preview unavailable',
  'item': 'item',
  'items': 'Items',
  'language': 'Language',
  'loaded_po': 'Loaded PO',
  'loaded_receipts': 'Loaded Receipts',
  'loaded_requests': 'Loaded Requests',
  'login': 'Login',
  'login_to_continue': 'Login to continue',
  'login_with_otp': 'Login with OTP',
  'logout': 'Logout',
  'material_request': 'Material Request',
  'material_attachment': 'Material Attachment',
  'material_requests': 'Material Requests',
  'material_receipt_attachment': 'Image of Material Received',
  'material_receipt': 'Material Received',
  'menu': 'Menu',
  'no_attachments_found': 'No attachments found.',
  'no_data_found': 'No data found',
  'no_items_added': 'No items added',
  'no_items_found': 'No items found.',
  'no_matching_options': 'No matching options',
  'no_material_requests_found': 'No material requests found.',
  'no_more_receipts': 'No more receipts',
  'no_more_requests': 'No more requests',
  'no_notifications_found': 'No notifications found.',
  'no_purchase_orders_found': 'No Purchase Orders found.',
  'no_purchase_receipts_found': 'No material received records found.',
  'no_recent_material_requests_found': 'No recent material requests found.',
  'no_recent_purchase_receipts_found':
      'No recent material received records found.',
  'no_stock_records_found': 'No stock records found.',
  'no_tolerance_settings_found': 'No tolerance settings found.',
  'notifications': 'Notifications',
  'or': 'OR',
  'order_date': 'Order Date',
  'ordered': 'Ordered',
  'ordered_received': 'Ordered / Received',
  'overview': 'Overview',
  'password': 'Password',
  'pending': 'Pending PO',
  'pending approval': 'Pending Approval',
  'partially ordered': 'Partially Ordered',
  'partially received': 'Partially Received',
  'pending_po': 'Pending PO',
  'pending_po_approval': 'Pending PO Approval',
  'pending_qty': 'Pending Qty',
  'pending_requests': 'Pending Material Requests',
  'posting_date': 'Posting Date',
  'powered_by': 'Powered by',
  'profile': 'Profile',
  'project': 'Project',
  'priority': 'Priority',
  'purchase_order': 'Purchase Order',
  'purchase_orders': 'Purchase Orders',
  'purchase_receipt': 'Material Received',
  'purchase_receipt_details': 'Material Received Details',
  'purchase_receipts': 'Material Received',
  'purchase_receipt_tolerance_settings': 'Purchase Receipt Tolerance Settings',
  'tolerance_settings': 'Tolerance Settings',
  'create_tolerance_settings': 'Create Tolerance Settings',
  'edit_tolerance_settings': 'Edit Tolerance Settings',
  'tolerance_settings_details': 'Tolerance Settings Details',
  'invoice_receipt_attachment': 'Image of Invoice Receipt',
  'qty': 'Qty',
  'quantity': 'Quantity',
  'quick_actions': 'Quick Actions',
  'rate': 'Rate',
  'read': 'Read',
  'ready': 'ready',
  'receipt': 'Receipt',
  'received': 'Received',
  'receive_qty': 'Receive Qty',
  'recent_receipts': 'Recent Receipts',
  'recent_requests': 'Recent Requests',
  'reject': 'Reject',
  'rejected': 'Rejected',
  'rejection_reason': 'Rejection Reason',
  'remark': 'Remark',
  'remember_me': 'Remember Me',
  'reason_remark_required': 'Reason / Remark *',
  'remove_item': 'Remove item',
  'request': 'Request',
  'request_details': 'Request Details',
  'required_date': 'Required Date',
  'retry': 'Retry',
  'role': 'Role',
  'save': 'Save',
  'schedule_date': 'Schedule Date',
  'search': 'Search',
  'search_item_or_warehouse': 'Search item or warehouse...',
  'search_material_requests': 'Search material requests...',
  'search_po_number_item_name': 'Search PO number / item name',
  'search_purchase_orders': 'Search purchase orders...',
  'search_receipts': 'Search receipts...',
  'search_tolerance_settings': 'Search tolerance settings...',
  'select': 'Select',
  'select_attachment_source': 'Select attachment source',
  'select_from_purchase_order': 'Select from Purchase Order',
  'select_purchase_order': 'Select Purchase Order',
  'select_category_then_add_item':
      'Select a category, then use the Add Item button.',
  'site': 'Site',
  'specification': 'Specification',
  'status': 'Status',
  'stock': 'Stock',
  'stock_overview': 'Stock Overview',
  'stock_report': 'Stock Report',
  'store_warehouse': 'Store Warehouse',
  'submit': 'Submit',
  'submit_purchase_receipt': 'Submit Material Received',
  'submitted': 'Submitted',
  'sub_category': 'Sub Category',
  'supplier': 'Supplier',
  'supplier_delivery_note': 'Supplier Delivery Note',
  'tap_plus_select_pending_po': 'Tap + to select pending PO',
  'tap_plus_select_supplier_po':
      'Tap + to select supplier and pending Purchase Order.',
  'to': 'To',
  'to bill': 'To Bill',
  'to receive': 'To Receive',
  'to receive and bill': 'To Receive and Bill',
  'to receive/bill': 'To Receive/Bill',
  'to_date': 'To Date',
  'total': 'Total',
  'total_amount': 'Total Amount',
  'total_qty': 'Total Qty',
  'unread': 'Unread',
  'until': 'Until',
  'uom': 'UOM',
  'version': 'Version 1.0.0',
  'view_all': 'View All',
  'view_po': 'View PO',
  'warehouse': 'Warehouse',
  'welcome_back': 'Welcome Back',
  'workflow_state': 'Status',
};

const _hi = <String, String>{
  'add': 'जोड़ें',
  'add_item_with_plus': '+ आइटम जोड़ें',
  'add_po': '+ Add PO',
  'add_invoice_receipt': 'इनवॉइस रिसीट जोड़ें',
  'add_item': 'आइटम जोड़ें',
  'add_material_receipt': 'मटेरियल रिसीव्ड जोड़ें',
  'all': 'सभी',
  'all_projects': 'सभी प्रोजेक्ट',
  'amount': 'राशि',
  'any': 'कोई भी',
  'apply': 'लागू करें',
  'approved': 'स्वीकृत',
  'attachment': 'अटैचमेंट',
  'attach': 'अटैच',
  'attachments': 'अटैचमेंट',
  'auto_filled_from_selected_project': 'चुने गए प्रोजेक्ट से ऑटो भरेगा',
  'cancel': 'रद्द करें',
  'camera': 'कैमरा',
  'cancelled': 'रद्द',
  'category': 'कैटेगरी',
  'clear': 'क्लियर',
  'close': 'बंद करें',
  'completed': 'पूर्ण',
  'conversion_factor': 'कन्वर्ज़न फैक्टर',
  'create_material_request': 'मटेरियल रिक्वेस्ट बनाएं',
  'create_purchase_receipt': 'मटेरियल रिसीव्ड बनाएं',
  'dashboard': 'डैशबोर्ड',
  'date': 'तारीख',
  'document': 'डॉक्यूमेंट',
  'draft': 'ड्राफ्ट',
  'edit': 'संपादित करें',
  'email_mobile_number': 'ईमेल / मोबाइल नंबर',
  'user_id': 'यूज़र आईडी',
  'english': 'English',
  'filtered': 'फ़िल्टर किए गए',
  'filter': 'फ़िल्टर',
  'forgot_password': 'पासवर्ड भूल गए?',
  'from': 'शुरू',
  'from_date': 'शुरू तारीख',
  'grand_total': 'कुल योग',
  'gallery': 'गैलरी',
  'hello': 'नमस्ते',
  'hindi': 'हिंदी',
  'home': 'होम',
  'image_preview_unavailable': 'इमेज प्रीव्यू उपलब्ध नहीं',
  'item': 'आइटम',
  'items': 'आइटम',
  'language': 'भाषा',
  'loaded_po': 'लोडेड PO',
  'loaded_receipts': 'लोडेड रिसीट',
  'loaded_requests': 'लोडेड रिक्वेस्ट',
  'login': 'लॉगिन',
  'login_to_continue': 'जारी रखने के लिए लॉगिन करें',
  'login_with_otp': 'OTP से लॉगिन',
  'logout': 'लॉगआउट',
  'material_request': 'मटेरियल रिक्वेस्ट',
  'material_attachment': 'मटेरियल अटैचमेंट',
  'material_requests': 'मटेरियल रिक्वेस्ट',
  'material_receipt_attachment': 'मटेरियल रिसीव्ड की इमेज',
  'material_receipt': 'मटेरियल रिसीव्ड',
  'menu': 'मेनू',
  'no_attachments_found': 'कोई अटैचमेंट नहीं मिला।',
  'no_data_found': 'कोई डेटा नहीं मिला',
  'no_items_added': 'कोई आइटम नहीं जोड़ा गया',
  'no_items_found': 'कोई आइटम नहीं मिला।',
  'no_matching_options': 'कोई मिलते विकल्प नहीं',
  'no_material_requests_found': 'कोई मटेरियल रिक्वेस्ट नहीं मिली।',
  'no_more_receipts': 'और रिसीट नहीं हैं',
  'no_more_requests': 'और रिक्वेस्ट नहीं हैं',
  'no_notifications_found': 'कोई नोटिफिकेशन नहीं मिला।',
  'no_purchase_orders_found': 'कोई परचेज ऑर्डर नहीं मिला।',
  'no_purchase_receipts_found': 'कोई मटेरियल रिसीव्ड रिकॉर्ड नहीं मिला।',
  'no_recent_material_requests_found':
      'हाल की कोई मटेरियल रिक्वेस्ट नहीं मिली।',
  'no_recent_purchase_receipts_found':
      'हाल का कोई मटेरियल रिसीव्ड रिकॉर्ड नहीं मिला।',
  'no_stock_records_found': 'कोई स्टॉक रिकॉर्ड नहीं मिला।',
  'no_tolerance_settings_found': 'कोई टॉलरेंस सेटिंग्स नहीं मिली।',
  'notifications': 'नोटिफिकेशन',
  'or': 'या',
  'order_date': 'ऑर्डर तारीख',
  'ordered': 'ऑर्डर की गई',
  'ordered_received': 'ऑर्डर / प्राप्त',
  'overview': 'अवलोकन',
  'password': 'पासवर्ड',
  'pending': 'Pending PO',
  'pending_po': 'लंबित PO',
  'pending_po_approval': 'Pending PO Approval',
  'pending_qty': 'लंबित मात्रा',
  'pending_requests': 'लंबित मटेरियल रिक्वेस्ट',
  'posting_date': 'पोस्टिंग तारीख',
  'powered_by': 'Powered by',
  'profile': 'प्रोफाइल',
  'project': 'प्रोजेक्ट',
  'purchase_order': 'परचेज ऑर्डर',
  'purchase_orders': 'परचेज ऑर्डर',
  'purchase_receipt': 'मटेरियल रिसीव्ड',
  'purchase_receipt_details': 'मटेरियल रिसीव्ड विवरण',
  'purchase_receipts': 'मटेरियल रिसीव्ड',
  'purchase_receipt_tolerance_settings': 'परचेज रिसीट टॉलरेंस सेटिंग्स',
  'tolerance_settings': 'टॉलरेंस सेटिंग्स',
  'create_tolerance_settings': 'टॉलरेंस सेटिंग्स बनाएं',
  'edit_tolerance_settings': 'टॉलरेंस सेटिंग्स संपादित करें',
  'tolerance_settings_details': 'टॉलरेंस सेटिंग्स विवरण',
  'invoice_receipt_attachment': 'इनवॉइस रिसीट की इमेज',
  'qty': 'मात्रा',
  'quantity': 'मात्रा',
  'quick_actions': 'त्वरित कार्य',
  'rate': 'रेट',
  'read': 'पढ़ा गया',
  'ready': 'तैयार',
  'receipt': 'रिसीट',
  'received': 'प्राप्त',
  'receive_qty': 'रिसीव मात्रा',
  'recent_receipts': 'हाल की रिसीट',
  'recent_requests': 'हाल की रिक्वेस्ट',
  'reject': 'Reject',
  'rejected': 'अस्वीकृत',
  'rejection_reason': 'Rejection Reason',
  'remark': 'रिमार्क',
  'remember_me': 'मुझे याद रखें',
  'reason_remark_required': 'Reason / Remark *',
  'remove_item': 'आइटम हटाएं',
  'request': 'रिक्वेस्ट',
  'request_details': 'रिक्वेस्ट विवरण',
  'required_date': 'आवश्यक तारीख',
  'retry': 'फिर कोशिश करें',
  'role': 'भूमिका',
  'save': 'सेव',
  'schedule_date': 'शेड्यूल तारीख',
  'search': 'खोजें',
  'search_item_or_warehouse': 'आइटम या वेयरहाउस खोजें...',
  'search_material_requests': 'मटेरियल रिक्वेस्ट खोजें...',
  'search_po_number_item_name': 'PO नंबर / आइटम नाम खोजें',
  'search_purchase_orders': 'परचेज ऑर्डर खोजें...',
  'search_receipts': 'रिसीट खोजें...',
  'search_tolerance_settings': 'टॉलरेंस सेटिंग्स खोजें...',
  'select': 'चुनें',
  'select_attachment_source': 'अटैचमेंट स्रोत चुनें',
  'select_from_purchase_order': 'परचेज ऑर्डर से चुनें',
  'select_purchase_order': 'परचेज ऑर्डर चुनें',
  'select_category_then_add_item':
      'कैटेगरी चुनें, फिर आइटम जोड़ें बटन इस्तेमाल करें।',
  'site': 'साइट',
  'specification': 'स्पेसिफिकेशन',
  'status': 'स्थिति',
  'stock': 'स्टॉक',
  'stock_overview': 'स्टॉक अवलोकन',
  'stock_report': 'स्टॉक रिपोर्ट',
  'store_warehouse': 'स्टोर वेयरहाउस',
  'submit': 'सबमिट',
  'submit_purchase_receipt': 'मटेरियल रिसीव्ड सबमिट करें',
  'submitted': 'सबमिटेड',
  'sub_category': 'सब कैटेगरी',
  'supplier': 'सप्लायर',
  'supplier_delivery_note': 'सप्लायर डिलीवरी नोट',
  'tap_plus_select_pending_po': '+ दबाकर लंबित PO चुनें',
  'tap_plus_select_supplier_po': '+ दबाकर सप्लायर और लंबित परचेज ऑर्डर चुनें।',
  'to': 'अंतिम',
  'to bill': 'To Bill',
  'to receive': 'To Receive',
  'to receive and bill': 'To Receive and Bill',
  'to receive/bill': 'To Receive/Bill',
  'to_date': 'अंतिम तारीख',
  'total': 'कुल',
  'total_amount': 'कुल राशि',
  'total_qty': 'कुल मात्रा',
  'unread': 'अपठित',
  'until': 'तक',
  'uom': 'UOM',
  'version': 'वर्जन 1.0.0',
  'view_all': 'सभी देखें',
  'view_po': 'PO देखें',
  'warehouse': 'वेयरहाउस',
  'welcome_back': 'वापसी पर स्वागत है',
};

const _messageHi = <String, String>{
  'At least one item is required.': 'कम से कम एक आइटम आवश्यक है।',
  'Cannot exceed pending qty': 'लंबित मात्रा से अधिक नहीं हो सकता',
  'Category is required': 'कैटेगरी आवश्यक है',
  'Category is required.': 'कैटेगरी आवश्यक है।',
  'Connection timed out. Please check your network.':
      'कनेक्शन टाइम आउट हो गया। कृपया अपना नेटवर्क जांचें।',
  'Email or mobile number is required': 'ईमेल या मोबाइल नंबर आवश्यक है',
  'User ID is required': 'यूज़र आईडी आवश्यक है',
  'Enter receive quantity for at least one item.':
      'कम से कम एक आइटम की रिसीव मात्रा दर्ज करें।',
  'Image preview unavailable': 'इमेज प्रीव्यू उपलब्ध नहीं',
  'Invalid login credentials.': 'लॉगिन जानकारी गलत है।',
  'Item is required': 'आइटम आवश्यक है',
  'Item is required.': 'आइटम आवश्यक है।',
  'Items are loading for selected category.':
      'चुनी गई कैटेगरी के आइटम लोड हो रहे हैं।',
  'Material Request created successfully':
      'मटेरियल रिक्वेस्ट सफलतापूर्वक बनाई गई',
  'Material Request created but submit failed':
      'मटेरियल रिक्वेस्ट बन गई लेकिन सबमिट विफल रहा',
  'Material Request not found.': 'मटेरियल रिक्वेस्ट नहीं मिली।',
  'Material Request submitted.': 'मटेरियल रिक्वेस्ट सबमिट हुई।',
  'Network error. Please check your internet connection.':
      'नेटवर्क त्रुटि। कृपया अपना इंटरनेट कनेक्शन जांचें।',
  'No items found for selected category.':
      'चुनी गई कैटेगरी में कोई आइटम नहीं मिला।',
  'No pending Purchase Order items to receive.':
      'रिसीव करने के लिए कोई लंबित परचेज ऑर्डर आइटम नहीं है।',
  'No pending Purchase Orders found.': 'कोई लंबित परचेज ऑर्डर नहीं मिला।',
  'No pending items found for this Purchase Order.':
      'इस परचेज ऑर्डर में कोई लंबित आइटम नहीं मिला।',
  'Password is required': 'पासवर्ड आवश्यक है',
  'Project is required': 'प्रोजेक्ट आवश्यक है',
  'Project is required.': 'प्रोजेक्ट आवश्यक है।',
  'Purchase Order is required.': 'परचेज ऑर्डर आवश्यक है।',
  'Purchase Receipt Submitted': 'मटेरियल रिसीट सबमिट हुई',
  'Purchase Receipt submitted successfully':
      'मटेरियल रिसीट सफलतापूर्वक सबमिट हुई',
  'Purchase Receipt Submitted.': 'मटेरियल रिसीट सबमिट हुई।',
  'Material Received Submitted.': 'मटेरियल रिसीट सबमिट हुई।',
  'Qty > 0': 'मात्रा 0 से अधिक होनी चाहिए',
  'Required date is required': 'आवश्यक तारीख जरूरी है',
  'Quantity must be greater than zero.': 'मात्रा शून्य से अधिक होनी चाहिए।',
  'Receive qty must be > 0': 'रिसीव मात्रा 0 से अधिक होनी चाहिए',
  'Rejection remark is required.': 'रिजेक्शन रिमार्क आवश्यक है।',
  'Select category before adding items.': 'आइटम जोड़ने से पहले कैटेगरी चुनें।',
  'Select supplier to view pending Purchase Orders.':
      'लंबित परचेज ऑर्डर देखने के लिए सप्लायर चुनें।',
  'Server timeout. Please try again.':
      'सर्वर टाइम आउट हो गया। कृपया फिर कोशिश करें।',
  'Supplier is required.': 'सप्लायर आवश्यक है।',
  'This Purchase Order is fully received and cannot be received again.':
      'यह परचेज ऑर्डर पूरी तरह रिसीव हो चुका है और दोबारा रिसीव नहीं किया जा सकता।',
  'This Purchase Receipt is already saved.': 'यह मटेरियल रिसीट पहले से सेव है।',
  'This Material Received is already saved.':
      'यह मटेरियल रिसीट पहले से सेव है।',
  'Unable to login. Please try again.':
      'लॉगिन नहीं हो सका। कृपया फिर कोशिश करें।',
  'Unable to read captured image.': 'कैप्चर की गई इमेज पढ़ी नहीं जा सकी।',
  'Warehouse is required.': 'वेयरहाउस आवश्यक है।',
  'Your ERPNext session has expired. Please login again.':
      'आपका ERPNext सेशन समाप्त हो गया है। कृपया फिर लॉगिन करें।',
};
