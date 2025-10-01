class Invoice {
  final String invoiceId;
  final String? itemId;
  final String? itemName;
  final double? qty;
  final double? price;
  final double gst; // overall GST % for invoice (if applicable)
  final String mobile;
  final String customerId;
  final String customerName;
  final String? customerEmail;
  final String? customerAddress;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final double? subtotal;
  final double? gstRate;
  final double? gstAmount;
  final double? discountAmount;
  final double? totalAmount;
  final String? notes;
  final String? status;
  final List<InvoiceItem>? items;
  final String? userId;
  final String? challanId;

  Invoice({
    required this.invoiceId,
    this.itemId,
    this.itemName,
    this.qty,
    this.price,
    this.gst = 0.0,
    required this.mobile,
    required this.customerName,
    this.customerId = '',
    this.customerEmail,
    this.customerAddress,
    this.issueDate,
    this.dueDate,
    this.subtotal,
    this.gstRate,
    this.gstAmount,
    this.discountAmount,
    this.totalAmount,
    this.notes,
    this.status,
    this.items,
    this.userId,
    this.challanId,
  });

  Map<String, dynamic> toMap() {
    return {
      'invoiceId': invoiceId,
      'itemId': itemId,
      'itemName': itemName,
      'qty': qty,
      'price': price,
      'gstRate': gstRate,
      'gstAmount': gstAmount,
      'mobile': mobile,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerAddress': customerAddress,
      'issueDate': issueDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'notes': notes,
      'status': status,
      'userId': userId,
      'challanId': challanId,
    };
  }

  // ✅ export invoice items as separate table rows
  List<Map<String, dynamic>> itemsToMap() {
    if (items == null) return [];

    return items!.map((item) {
      return {
        'invoiceId': invoiceId,
        'itemId': item.itemId,
        'itemName': item.itemName,
        'description': item.description,
        'quantity': item.quantity,
        'rate': item.rate,
        'totalPrice': item.totalPrice,
        'gstRate': item.gstRate,
        'gstAmount': item.gstAmount,
        'amountWithGst': item.amountWithGst,
        'challanId': item.challanId,
      };
    }).toList();
  }
  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      invoiceId: map['invoiceId'] ?? map['InvoiceId'] ?? '',
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      qty: double.tryParse(map['qty']?.toString() ?? map['quantity']?.toString() ?? '0') ?? 0,
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      gst: double.tryParse(map['gst']?.toString() ?? '0') ?? 0.0,
      mobile: map['mobile'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerEmail: map['customerEmail'],
      customerAddress: map['customerAddress'],
      // 🔹 FIX: Handle both DateTime objects and String dates
      issueDate: _parseDateField(map['issueDate']),
      dueDate: _parseDateField(map['dueDate']),
      subtotal: double.tryParse(map['subtotal']?.toString() ?? '0') ?? 0.0,
      gstRate: double.tryParse(map['gstRate']?.toString() ?? '0') ?? 0.0,
      gstAmount: double.tryParse(map['gstAmount']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(map['discountAmount']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(map['totalAmount']?.toString() ?? '0') ?? 0.0,
      notes: map['notes'],
      status: map['status'],
      userId: map['userId'],
      challanId: map['challanId'],
      items: [],
    );
  }

// 🔹 Helper method to parse date fields
  static DateTime? _parseDateField(dynamic dateValue) {
    if (dateValue == null) return null;

    // If already a DateTime object, return it
    if (dateValue is DateTime) {
      return dateValue;
    }

    // If it's a String, try to parse it
    if (dateValue is String && dateValue.isNotEmpty) {
      // Try ISO format first
      DateTime? parsed = DateTime.tryParse(dateValue);
      if (parsed != null) return parsed;

      // Try dd/MM/yyyy format
      if (dateValue.contains("/")) {
        try {
          final parts = dateValue.split("/");
          if (parts.length == 3) {
            return DateTime(
              int.parse(parts[2]), // yyyy
              int.parse(parts[1]), // MM
              int.parse(parts[0]), // dd
            );
          }
        } catch (_) {
          return null;
        }
      }
    }

    return null;
  }
  Invoice copyWith({
    String? invoiceId,
    String? itemId,
    String? itemName,
    double? qty,
    double? price,
    String? mobile,
    String? customerName,
    String? customerEmail,
    String? customerAddress,
    DateTime? issueDate,
    DateTime? dueDate,
    double? subtotal,
    double? gstRate,
    double? gstAmount,
    double? discountAmount,
    double? totalAmount,
    String? notes,
    String? status,
    List<InvoiceItem>? items,
    String? challanId,
  }) {
    return Invoice(
      invoiceId: invoiceId ?? this.invoiceId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      mobile: mobile ?? this.mobile,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerAddress: customerAddress ?? this.customerAddress,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      subtotal: subtotal ?? this.subtotal,
      gstRate: gstRate ?? this.gstRate,
      gstAmount: gstAmount ?? this.gstAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      items: items ?? this.items,
      challanId: challanId ?? this.challanId,
    );
  }

  @override
  String toString() {
    return 'Invoice(invoiceId: $invoiceId, customerName: $customerName, totalAmount: $totalAmount)';
  }
}

class InvoiceItem {
  final String? invoiceId;
  final String? customerId;
  final String description;
  final double quantity;
  final double rate;
  final String itemId;
  final String itemName;
  final String? challanId;
  final double gstRate;
  final double? gstAmount;      // ✅ Make this a stored field
  final double? amountWithGst;  // ✅ Make this a stored field
  final double? totalPrice;    // ✅ Make this a stored field
  final String? unit; // info only (comes from Item, not editable)

  InvoiceItem({
    this.invoiceId,
    this.customerId,
    required this.description,
    required this.quantity,
    required this.rate,
    required this.itemId,
    required this.itemName,
    this.challanId,
    this.gstRate = 0.0,
    this.gstAmount,      // ✅ Accept from data
    this.amountWithGst,  // ✅ Accept from data
    this.totalPrice,     // ✅ Accept from data
    this.unit,
  });

  /// ✅ Computed getters as fallback
  double get calculatedTotalPrice => totalPrice ?? (quantity * rate);
  double get calculatedGstAmount => gstAmount ?? ((calculatedTotalPrice * gstRate) / 100);
  double get calculatedAmountWithGst => amountWithGst ?? (calculatedTotalPrice + calculatedGstAmount);


  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'itemId': itemId,
      'itemName': itemName,
      'description': description,
      'quantity': quantity,
      'rate': rate,
      'totalPrice': calculatedTotalPrice,
      'gstRate': gstRate,
      'gstAmount': calculatedGstAmount,
      'amountWithGst': calculatedAmountWithGst,
      'challanId': challanId,
      'unit': unit,
    };
  }


  // factory InvoiceItem.fromJson(Map<String, dynamic> map) {
  //   print("=== PARSING INVOICE ITEM ===");
  //   print("Raw map data: $map");
  //
  //   // Parse GST with multiple fallbacks
  //   double gstRate = double.tryParse(
  //     map['gstRate']?.toString() ??
  //         map['GstRate']?.toString() ??
  //         map['gst_rate']?.toString() ??
  //         '0.0',
  //   ) ??
  //       0.0;
  //
  //   double? gstAmount = double.tryParse(map['gstAmount']?.toString() ?? '');
  //   double? amountWithGst =
  //   double.tryParse(map['amountWithGst']?.toString() ?? '');
  //   double? totalPrice =
  //   double.tryParse(map['totalPrice']?.toString() ?? '');
  //
  //   print("✅ Parsed gstRate: $gstRate");
  //   print("✅ Parsed gstAmount: $gstAmount");
  //   print("✅ Parsed amountWithGst: $amountWithGst");
  //   print("✅ Parsed totalPrice: $totalPrice");
  //
  //   return InvoiceItem(
  //     customerId: map['customerId']?.toString(),
  //     description: map['description']?.toString() ?? '',
  //     quantity: double.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
  //     rate: double.tryParse(map['rate']?.toString() ?? '0.0') ?? 0.0,
  //     itemId: map['itemId']?.toString() ?? '',
  //     invoiceId: map['invoiceId']?.toString() ?? '',
  //     itemName: map['itemName']?.toString() ?? '',
  //     gstRate: gstRate,              // ✅ Now properly parsed
  //     gstAmount: gstAmount,
  //     amountWithGst: amountWithGst,
  //     totalPrice: double.tryParse(map['totalPrice']?.toString() ?? '0.0') ??
  //         null,
  //     challanId: map['challanId'],
  //     unit: map['unit']?.toString(),
  //   );
  // }

  factory InvoiceItem.fromJson(Map<String, dynamic> map) {
    print("=== PARSING INVOICE ITEM ===");
    print("Raw map data: $map");

    // Parse rate/price with multiple fallbacks
    // Try 'price' FIRST (your column name), then 'rate' as fallback
    double rate = double.tryParse(
      map['price']?.toString() ??   // ✅ Try 'price' first (your sheet column)
          map['rate']?.toString() ??    // Fallback to 'rate'
          '0.0',
    ) ?? 0.0;

    // Parse quantity
    double quantity = double.tryParse(
        map['quantity']?.toString() ?? '0'
    ) ?? 0.0;

    // Parse GST with multiple fallbacks
    double gstRate = double.tryParse(
      map['gstRate']?.toString() ??
          map['GstRate']?.toString() ??
          map['gst_rate']?.toString() ??
          '0.0',
    ) ?? 0.0;

    double? gstAmount = double.tryParse(map['gstAmount']?.toString() ?? '');
    double? amountWithGst = double.tryParse(map['amountWithGst']?.toString() ?? '');
    double? totalPrice = double.tryParse(map['totalPrice']?.toString() ?? '');

    print("✅ Parsed rate: $rate");
    print("✅ Parsed quantity: $quantity");
    print("✅ Parsed gstRate: $gstRate");
    print("✅ Parsed gstAmount: $gstAmount");
    print("✅ Parsed amountWithGst: $amountWithGst");
    print("✅ Parsed totalPrice: $totalPrice");

    return InvoiceItem(
      customerId: map['customerId']?.toString(),
      description: map['description']?.toString() ?? '',
      quantity: quantity,
      rate: rate,  // ✅ Now properly gets value from 'price' column
      itemId: map['itemId']?.toString() ?? '',
      invoiceId: map['invoiceId']?.toString() ?? '',
      itemName: map['itemName']?.toString() ?? '',
      gstRate: gstRate,
      gstAmount: gstAmount,
      amountWithGst: amountWithGst,
      totalPrice: totalPrice,
      challanId: map['challanId'],
      unit: map['unit']?.toString(),
    );
  }

  InvoiceItem copyWith({
    String? invoiceId,
    String? customerId,
    String? description,
    double? quantity,
    double? rate,
    String? itemId,
    String? itemName,
    double? gstRate,
    double? gstAmount,
    double? amountWithGst,
    double? totalPrice,
    String? challanId,
    String? unit,
  }) {
    return InvoiceItem(
      invoiceId: invoiceId ?? this.invoiceId,
      customerId: customerId ?? this.customerId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      gstRate: gstRate ?? this.gstRate,
      gstAmount: gstAmount ?? this.gstAmount,
      amountWithGst: amountWithGst ?? this.amountWithGst,
      totalPrice: totalPrice ?? this.totalPrice,
      challanId: challanId ?? this.challanId,
      unit: unit ?? this.unit,
    );
  }

}

// class InvoiceItem {
//   final String description;
//   final int quantity;
//   final double rate;
//   final String itemId;
//   final String itemName;
//   final String? challanId;
//   final double gstRate; // % GST
//
//   InvoiceItem({
//     required this.description,
//     required this.quantity,
//     required this.rate,
//     required this.itemId,
//     required this.itemName,
//     this.challanId,
//     this.gstRate = 0.0,
//   });

  /// ✅ always computed
  // double get totalPrice => quantity * rate;
  // double get gstAmount => (totalPrice * gstRate) / 100;
  // double get amountWithGst => totalPrice + gstAmount;

  // Map<String, dynamic> toMap() {
  //   return {
  //     'itemId': itemId,
  //     'itemName': itemName,
  //     'description': description,
  //     'quantity': quantity,
  //     'rate': rate,
  //     'totalPrice': totalPrice,
  //     'gstRate': gstRate,
  //     'gstAmount': gstAmount,
  //     'amountWithGst': amountWithGst,
  //     'challanId': challanId,
  //   };
  // }

  // factory InvoiceItem.fromJson(Map<String, dynamic> map) {
  //   double qty = double.tryParse(map['quantity']?.toString() ?? '0') ?? 0;
  //   double price = double.tryParse(map['price']?.toString() ?? '0') ?? 0;
  //   double gstRate = double.tryParse(map['gstRate']?.toString() ?? '') ?? 18.0; // ✅ default GST if missing
  //
  //   return InvoiceItem(
  //     description: map['description']?.toString() ?? '',
  //     quantity: qty.toInt(),
  //     rate: price,
  //     itemId: map['itemId']?.toString() ?? '',
  //     itemName: map['itemName']?.toString() ?? '',
  //     gstRate: gstRate,
  //     challanId: map['challanId'],
  //   );
  // }


  // InvoiceItem copyWith({
  //   String? description,
  //   int? quantity,
  //   double? rate,
  //   String? itemId,
  //   String? itemName,
  //   double? gstRate,
  //   String? challanId,
  // }) {
  //   return InvoiceItem(
  //     description: description ?? this.description,
  //     quantity: quantity ?? this.quantity,
  //     rate: rate ?? this.rate,
  //     itemId: itemId ?? this.itemId,
  //     itemName: itemName ?? this.itemName,
  //     gstRate: gstRate ?? this.gstRate,
  //     challanId: challanId ?? this.challanId,
  //   );
  // }

