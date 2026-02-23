import 'dart:convert';

class Item {
  final String itemId;
  final String itemName;
  final double price;
  double sellPrice;
  final double gstPercent;

  final String unitOfMeasurement;
  final int currentStock;
  final String detailRequirement;
  final bool isActive;
  final String userId;

  Item({
    required this.itemId,
    required this.itemName,
    required this.price,
    this.sellPrice = 0.0,
    this.gstPercent = 0.0,

    this.unitOfMeasurement = 'pcs',
    this.currentStock = 0,
    this.detailRequirement = '',
    this.isActive = true,
    this.userId = '0',
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'price': price,
      'sellPrice': sellPrice,
      'gst': gstPercent,

      'unitOfMeasurement': unitOfMeasurement,
      'currentStock': currentStock,
      'detailRequirement': detailRequirement,
      'isActive': isActive,
      "userId": userId,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      itemId: map['itemId']?.toString() ?? '',
      itemName: map['itemName']?.toString() ?? '',
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      sellPrice: double.tryParse(map['sellPrice']?.toString() ?? '0') ?? 0.0,
      gstPercent: double.tryParse(map['gst']?.toString() ?? '0') ?? 0.0,

      unitOfMeasurement: map['unitOfMeasurement']?.toString() ?? 'pcs',
      currentStock: int.tryParse(map['currentStock']?.toString() ?? '0') ?? 0,
      detailRequirement: map['detailRequirement']?.toString() ?? '',
      isActive: _parseIsActive(map['isActive']),
      userId: map['userId']?.toString() ?? '',
    );
  }

  // Helper method to handle different isActive formats
  static bool _parseIsActive(dynamic value) {
    if (value == null) return true; // Default to active if null

    // Handle string values (AppSheet Yes/No)
    if (value is String) {
      final lowerValue = value.toLowerCase().trim();
      return lowerValue == 'yes' ||
          lowerValue == 'y' ||      // Handle "Y"/"N" format
          lowerValue == 'true' ||
          lowerValue == '1' ||
          lowerValue == 'active';
    }

    // Handle boolean values
    if (value is bool) {
      return value;
    }

    // Handle integer values (1 = true, 0 = false)
    if (value is int) {
      return value == 1;
    }

    // Handle numeric strings
    if (value is String && (value == '1' || value == '0')) {
      return value == '1';
    }

    // Default to true for any other case
    return true;
  }

  Item copyWith({
    String? itemId,
    String? itemName,
    double? price,
    double? gst,
    String? unitOfMeasurement,
    int? currentStock,
    String? detailRequirement,
    bool? isActive,
  }) {
    return Item(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      price: price ?? this.price,
      gstPercent: gst ?? this.gstPercent,
      unitOfMeasurement: unitOfMeasurement ?? this.unitOfMeasurement,
      currentStock: currentStock ?? this.currentStock,
      detailRequirement: detailRequirement ?? this.detailRequirement,
      isActive: isActive ?? this.isActive,
    );
  }

}



/// it s Workig til 23-09 1:16 PM
// class Invoice {
//   final String invoiceId;
//   final String? itemId;
//   final String? itemName;
//   final int? qty;
//   final double? price;
//   final double? gst;
//   final String mobile;
//   final String customerId;
//   final String customerName;
//   final String? customerEmail;
//   final String? customerAddress;
//   final DateTime? issueDate;
//   final DateTime? dueDate;
//   final double? subtotal;
//  // final double? gstRate;
//   final double? gstAmount;
//   final double? discountAmount;
//   //final String? discountType;
//   final double? totalAmount;
//   final String? notes;
//   final String? status;
//   final List<InvoiceItem>? items;
//   final String? userId;
//   final String? challanId;
//
//   Invoice({
//     required this.invoiceId,
//      this.itemId,
//      this.itemName,
//      this.qty,
//      this.price,
//     this.gst = 0.0,
//     required this.mobile,
//     required this.customerName,
//     this.customerId = '',
//     this.customerEmail,
//     this.customerAddress,
//     this.issueDate,
//     this.dueDate,
//     this.subtotal,
//    // this.gstRate,
//     this.gstAmount = 0.0,
//     this.discountAmount,
//     //this.discountType,
//     this.totalAmount,
//     this.notes,
//     this.status,
//     this.items,
//     this.userId,
//     this.challanId,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'invoiceId': invoiceId,
//       'itemId': itemId,
//       'itemName': itemName,
//       'qty': qty,
//       'price': price,
//       'gstRate': gst,
//       'gstAmount': gstAmount,
//       'mobile': mobile,
//       'customerId': customerId,
//       'customerName': customerName,
//       'customerEmail': customerEmail,
//       'customerAddress': customerAddress,
//       'issueDate': issueDate?.toIso8601String(),
//       'dueDate': dueDate?.toIso8601String(),
//       'subtotal': subtotal,
//       'discountAmount': discountAmount,
//       //'discountType': discountType,
//       'totalAmount': totalAmount,
//       'notes': notes,
//       'status': status,
//       ///'items': json.encode(items?.map((item) => item.toMap()).toList()),
//
//     };
//   }
//
//   // Convert invoice items to a separate map for the items table
//   List<Map<String, dynamic>> itemsToMap() {
//     if (items == null) return [];
//
//     return items!.map((item) {
//       return {
//         'invoiceId': invoiceId, // Foreign key reference
//         'itemId': item.itemId,
//         'description': item.description,
//         'quantity': item.quantity,
//         'rate': item.rate,
//         'totalPrice': item.totalPrice,
//         'gstRate': item.gstRate,
//         'gstAmount': item.gstAmount,
//         'amountWithGst': item.amountWithGst,
//         'challanId': item.challanId,
//       };
//     }).toList();
//   }
//
//   factory Invoice.fromMap(Map<String, dynamic> map) {
//     return Invoice(
//       invoiceId: map['invoiceId'] ?? map['InvoiceId'] ?? '',
//       itemId: map['itemId'] ?? map['ItemId'] ?? '',
//       itemName: map['itemName'] ?? map['ItemName'] ?? '',
//       qty: (map['qty'] ?? map['Qty'] ?? map['quantity'] ?? 0) is int
//           ? map['qty'] ?? map['Qty'] ?? map['quantity'] ?? 0
//           : int.tryParse(map['qty']?.toString() ?? '0') ?? 0,
//       price: (map['price'] ?? map['Price'] ?? 0.0) is double
//           ? map['price'] ?? map['Price'] ?? 0.0
//           : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
//       gst: map['gst'] != null ? double.parse(map['gst'].toString()) : 0.0,
//       mobile: map['mobile'] ?? map['Mobile'] ?? map['phone'] ?? '',
//       customerId: map['customerId'] ?? '',
//       customerName: map['customerName'] ?? map['CustomerName'] ?? map['customer'] ?? '',
//       customerEmail: map['customerEmail'] ?? map['CustomerEmail'] ?? map['email'] ?? '',
//       customerAddress: map['customerAddress'] ?? map['CustomerAddress'] ?? map['address'] ?? '',
//       issueDate: map['issueDate'] != null
//           ? DateTime.tryParse(map['issueDate'])
//           : map['IssueDate'] != null
//           ? DateTime.tryParse(map['IssueDate'])
//           : null,
//       dueDate: map['dueDate'] != null
//           ? DateTime.tryParse(map['dueDate'])
//           : map['DueDate'] != null
//           ? DateTime.tryParse(map['DueDate'])
//           : null,
//       subtotal: (map['subtotal'] ?? map['Subtotal'] ?? 0.0) is double
//           ? map['subtotal'] ?? map['Subtotal'] ?? 0.0
//           : double.tryParse(map['subtotal']?.toString() ?? '0') ?? 0.0,
//       gst: (map['gst'] ?? map['gst'] ?? 0.0) is double
//           ? map['gst'] ?? map['gst'] ?? 0.0
//           : double.tryParse(map['gst']?.toString() ?? '0') ?? 0.0,
//       gstAmount: (map['gstAmount'] ?? map['gstAmount'] ?? 0.0) is double
//           ? map['gstAmount'] ?? map['gstAmount'] ?? 0.0
//           : double.tryParse(map['taxAmount']?.toString() ?? '0') ?? 0.0,
//       discountAmount: (map['discountAmount'] ?? map['DiscountAmount'] ?? 0.0) is double
//           ? map['discountAmount'] ?? map['DiscountAmount'] ?? 0.0
//           : double.tryParse(map['discountAmount']?.toString() ?? '0') ?? 0.0,
//       //discountType: map['discountType'] ?? map['DiscountType'] ?? 'amount',
//       totalAmount: (map['totalAmount'] ?? map['TotalAmount'] ?? 0.0) is double
//           ? map['totalAmount'] ?? map['TotalAmount'] ?? 0.0
//           : double.tryParse(map['totalAmount']?.toString() ?? '0') ?? 0.0,
//       notes: map['notes'] ?? map['Notes'] ?? '',
//       status: map['status'] ?? map['Status'] ?? 'issued',
//       items: [],
//       userId: map['userId'] ?? '',
//     );
//   }
//
//   // Helper method to create a copy of the invoice with updated values
//   Invoice copyWith({
//     String? invoiceId,
//     String? itemId,
//     String? itemName,
//     int? qty,
//     double? price,
//     String? mobile,
//     String? customerName,
//     String? customerEmail,
//     String? customerAddress,
//     DateTime? issueDate,
//     DateTime? dueDate,
//     double? subtotal,
//     double? gst,
//     double? gstAmount,
//     double? discountAmount,
//     //String? discountType,
//     double? totalAmount,
//     String? notes,
//     String? status,
//     List<InvoiceItem>? items,
//   }) {
//     return Invoice(
//       invoiceId: invoiceId ?? this.invoiceId,
//       itemId: itemId ?? this.itemId,
//       itemName: itemName ?? this.itemName,
//       qty: qty ?? this.qty,
//       price: price ?? this.price,
//       mobile: mobile ?? this.mobile,
//       customerName: customerName ?? this.customerName,
//       customerEmail: customerEmail ?? this.customerEmail,
//       customerAddress: customerAddress ?? this.customerAddress,
//       issueDate: issueDate ?? this.issueDate,
//       dueDate: dueDate ?? this.dueDate,
//       subtotal: subtotal ?? this.subtotal,
//       gst: gst ?? this.gst,
//       gstAmount: gstAmount ?? this.gstAmount,
//       discountAmount: discountAmount ?? this.discountAmount,
//       //discountType: discountType ?? this.discountType,
//       totalAmount: totalAmount ?? this.totalAmount,
//       notes: notes ?? this.notes,
//       status: status ?? this.status,
//       items: items,
//     );
//   }
//
//   @override
//   String toString() {
//     return 'Invoice(invoiceId: $invoiceId, itemId: $itemId, itemName: $itemName, qty: $qty, price: $price, mobile: $mobile, customerName: $customerName)';
//   }
// }
//
//
// class InvoiceItem {
//   final String description;
//   final int quantity;
//   final double rate;
//   double? gstRate;      // %
//
//   final String itemId;
//   final String itemName;
//   //final double totalPrice;
//   final String? challanId;
//
//   InvoiceItem({
//     required this.description,
//     required this.quantity,
//     required this.rate,
//     this.gstRate = 0.0,
//     required this.itemId,
//     required this.itemName,
//     //required this.totalPrice,
//     this.challanId,
//   });
//
//   // Use the totalPrice from API instead of calculating
//   double get totalPrice => quantity * rate;
//   double get gstAmount => (totalPrice * gstRate!) / 100;
//   double get amountWithGst => totalPrice + gstAmount;
//
//
//   Map<String, dynamic> toMap() {
//     return {
//       "itemId": itemId ?? "",
//       "itemName": itemName,
//       "quantity": quantity,
//       "rate": rate,
//       "gstRate": gstRate,
//       "gstAmount": gstAmount,
//       "amountWithGst": amountWithGst,
//       "totalPrice": totalPrice,
//     };
//   }
//
//   factory InvoiceItem.fromJson(Map<String, dynamic> map) {
//     double qty = double.tryParse(map['quantity']?.toString() ?? '0') ?? 0;
//     double price = double.tryParse(map['price']?.toString() ?? '0') ?? 0;
//     double gstRate = double.tryParse(map['gstRate']?.toString() ?? '0') ?? 0;
//
//     double lineTotal = qty * price;
//     double gstAmount = lineTotal * (gstRate / 100);
//     double amountWithGst = lineTotal + gstAmount;
//     return InvoiceItem(
//       description: map['description']?.toString() ?? '',
//       quantity: int.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
//       rate: double.tryParse(map['price']?.toString() ?? '0.0') ?? 0.0,
//       itemId: map['itemId']?.toString() ?? '',
//       itemName: map['itemName']?.toString() ?? '',
//       //totalPrice: double.tryParse(map['totalPrice']?.toString() ?? '0.0') ?? 0.0,
//       gstRate: gstRate,
//
//     );
//   }
//
//   factory InvoiceItem.fromMap(Map<String, dynamic> map) => InvoiceItem.fromJson(map);
//
//   InvoiceItem copyWith({
//     String? description,
//     int? quantity,
//     double? rate,
//     String? itemId,
//     String? itemName,
//     double? gstRate,
//     String? challanId,
//   }) {
//     return InvoiceItem(
//       description: description ?? this.description,
//       quantity: quantity ?? this.quantity,
//       rate: rate ?? this.rate,
//       itemId: itemId ?? this.itemId,
//       itemName: itemName ?? this.itemName,
//       gstRate: gstRate ?? this.gstRate,
//       challanId: challanId ?? this.challanId,
//     );
//   }
// }
//
