import 'package:intl/intl.dart';

import 'item_model.dart';

class Challan {
  final String challanId;
   DateTime? challanDate;
  final String customerId;
  final String customerName;
  final String customerMobile;
  final String customerEmail;
  final String customerPan;
  final String customerGst;
  final String customerAddress;
  final String? itemId;
  final String? itemName;
  final double? unit;
  final double? qty;
  final double? price;
  final double? gst;
  final double subtotal;
  final double gstAmount;
  final double totalAmount;
  final String paymentStatus;
  final String notes;
  final String status;
  List<ChallanItem>? items;
  final String? userId;

  Challan({
    required this.challanId,
     this.challanDate,
    this.customerId = '',
    required this.customerName,
    required this.customerMobile,
    this.customerEmail = '',
    this.customerPan = '',
    this.customerGst = '',
    this.customerAddress = '',
     this.itemId,
     this.itemName,
     this.qty,
     this.price,
    this.gst = 0.0,
    required this.subtotal,
    double?  gstAmount = 0.0,
    double? totalAmount,
    this.paymentStatus = 'Pending',
    this.notes = '',
    this.status = 'Draft',
    this.items,
    this.userId,
    this.unit
  })
      : gstAmount = gstAmount ?? (subtotal * gst! / 100), // auto-calc
        totalAmount = totalAmount ?? (subtotal + (subtotal * gst! / 100));

  // Convert Challan object to Map
  Map<String, dynamic> toMap() {
    return {
      'challanId': challanId,
      'challanDate': challanDate?.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'customerMobile': customerMobile,
      'customerEmail': customerEmail,
      'customerPan': customerPan,
      'customerGst': customerGst,
      'customerAddress': customerAddress,
      'itemId': itemId,
      'itemName': itemName,
      'qty': qty,
      'price': price,
      'gstRate':gst,
      'subtotal': subtotal,
      'gstAmount': gstAmount,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'notes': notes,
      'status': status,
      'unit': unit,
      'items': items?.map((item) => item.toMap()).toList(),
    };
  }

  Challan withItems(List<ChallanItem> newItems) {
    return Challan(
      challanId: challanId,
      customerName: customerName,
      customerId: customerId,
      challanDate: challanDate,
      items: newItems,
      customerMobile: customerMobile,
      subtotal: subtotal,
    );
  }

  // Create Challan object from Map
  factory Challan.fromMap(Map<String, dynamic> map) {
    String rawDate = map['challanDate']?.toString().trim() ?? "";
    DateTime? parsedDate = _parseChallanDate(rawDate);
    return Challan(
      challanId: map['challanId'] ?? '',
      challanDate:parsedDate,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerMobile: map['customerMobile'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      customerGst: map['customerGst'] ?? '',
      customerPan: map['customerPan'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      qty: map['qty'] != null ? double.parse(map['qty'].toString()) : 0.0,
      price: map['price'] != null ? double.parse(map['price'].toString()) : 0.0,
      gst: map['gst'] != null ? double.parse(map['gst'].toString()) : 0.0,
      subtotal: map['subtotal'] != null ? double.parse(map['subtotal'].toString()) : 0.0,
      gstAmount: map['gstAmount'] != null ? double.parse(map['gstAmount'].toString()) : 0.0,
      paymentStatus: map['paymentStatus'] ?? 'Pending',
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'Draft',
      items: null,
      userId: map['userId'] ?? '',
    );
  }

  /// 🔑 Helper to parse multiple formats
  static DateTime? _parseChallanDate(String rawDate) {
    try {
      DateTime? parsed = DateTime.tryParse(rawDate);
      if (parsed != null) return parsed;

      return DateFormat('dd/MM/yyyy').parseStrict(rawDate);
    } catch (_) {}

    try {
      return DateFormat('dd/MM/yyyy HH:mm:ss').parseStrict(rawDate);
    } catch (_) {
      return null;
    }
  }
  // Create Challan object from JSON
  factory Challan.fromJson(Map<String, dynamic> json) {

    return Challan(
      challanId: json['challanId']?.toString() ?? '',
      challanDate: json['challanDate'] != null
          ? DateTime.tryParse(json['challanDate'].toString())
          : null,
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerMobile: json['customerMobile']?.toString() ?? '',
      customerEmail: json['customerEmail']?.toString() ?? '',
      customerPan: json['customerPan']?.toString() ?? '',
      customerGst: json['customerGst']?.toString() ?? '',
      customerAddress: json['customerAddress']?.toString() ?? '',
      itemId: json['itemId']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? '',
      qty: json['qty'] != null ? double.tryParse(json['qty'].toString()) ?? 0 : 0,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      gst: json['gst'] != null ? double.tryParse(json['gst'].toString()) ?? 0.0 : 0.0,
      subtotal: json['subtotal'] != null ? double.tryParse(json['subtotal'].toString()) ?? 0.0 : 0.0,
      gstAmount: json['gstAmount'] != null ? double.tryParse(json['gstAmount'].toString()) ?? 0.0 : 0.0,
      paymentStatus: json['paymentStatus']?.toString() ?? 'Pending',
      notes: json['notes']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Draft',
      items: json['items'] != null
          ? (json['items'] as List).map((item) => ChallanItem.fromJson(item)).toList()
          : [],
      unit: json['unit'],
    );
  }

  // Optional: Copy with method for easy updates
  Challan copyWith({
    String? challanId,
    DateTime? challanDate,
    String? customerId,
    String? customerName,
    String? customerPan,
    String? customerGst,
    String? customerMobile,
    String? customerEmail,
    String? customerAddress,
    String? itemId,
    String? itemName,
    double? qty,
    double? price,
    double? subtotal,
    double? gstRate,
    double? gstAmount,
    String? paymentStatus,
    String? notes,
    String? status,
    List<ChallanItem>? items,
  }) {
    return Challan(
      challanId: challanId ?? this.challanId,
      challanDate: challanDate ?? this.challanDate,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPan: customerPan ?? this.customerPan,
      customerMobile: customerMobile ?? this.customerMobile,
      customerEmail: customerEmail ?? this.customerEmail,
      customerAddress: customerAddress ?? this.customerAddress,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
      gst: gstRate?? this.gst,
      gstAmount: gstAmount ?? this.gstAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      items: items,
    );
  }
}
class ChallanItem {
  final String description;
  final double quantity; // ✅ allow decimals like 0.2
  final double price;    // price per base unit
  final double gstRate;
  final double? gstAmount;
  final double? amountWithGst;
  final String itemId;
  final String customerId;
  final String itemName;
  final double? totalPrice;
  String? challanId;
  DateTime? challanDate;
  final String? unit; // info only (comes from Item, not editable)

  ChallanItem({
    required this.description,
    required this.quantity,
    required this.price,
    this.gstRate = 0.0,
    required this.itemId,
    required this.customerId,
    required this.itemName,
    this.totalPrice,
    this.gstAmount,
    this.amountWithGst,
    this.challanId,
    this.challanDate,
    this.unit,
  });

  // ✅ auto-calculated fallbacks
  double get calculatedAmount => totalPrice ?? (quantity * price);

  double get calculatedGstAmount =>
      gstAmount ?? ((calculatedAmount * gstRate) / 100);

  double get calculatedAmountWithGst =>
      amountWithGst ?? (calculatedAmount + calculatedGstAmount);

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'quantity': quantity,
      'price': price,
      'gstRate': gstRate,
      'gstAmount': calculatedGstAmount,
      'amountWithGst': calculatedAmountWithGst,
      'itemId': itemId,
      'customerId': customerId,
      'itemName': itemName,
      'unit': unit,
      'totalPrice': calculatedAmount,
      'challanDate': challanDate,
    };
  }

  factory ChallanItem.fromJson(Map<String, dynamic> map) {
    return ChallanItem(
      description: map['description']?.toString() ?? '',
      quantity: double.tryParse(map['quantity']?.toString() ?? '0') ?? 0.0,
      price: double.tryParse(map['price']?.toString() ?? '0.0') ?? 0.0,
      itemId: map['itemId']?.toString() ?? '',
      customerId: map['customerId']?.toString() ?? '',
      itemName: map['itemName']?.toString() ?? '',
      totalPrice: double.tryParse(map['totalPrice']?.toString() ?? ''),
      gstRate: double.tryParse(map['gstRate']?.toString() ?? '0.0') ?? 0.0,
      gstAmount: double.tryParse(map['gstAmount']?.toString() ?? ''),
      amountWithGst: double.tryParse(map['amountWithGst']?.toString() ?? ''),
      challanId: map['challanId']?.toString(),
      challanDate: map['challanDate'] != null
          ? DateTime.tryParse(map['challanDate'].toString())
          : null,
      unit: map['unit']?.toString(),
    );
  }

  ChallanItem copyWith({
    String? description,
    double? quantity,
    double? price,
    double? gstRate,
    double? gstAmount,
    double? amountWithGst,
    double? totalPrice,
    String? customerId,
    String? itemId,
    String? itemName,
    DateTime? challanDate,
    String? unit,
  }) {
    return ChallanItem(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      gstRate: gstRate ?? this.gstRate,
      gstAmount: gstAmount ?? this.gstAmount,
      amountWithGst: amountWithGst ?? this.amountWithGst,
      totalPrice: totalPrice ?? this.totalPrice,
      customerId: customerId ?? this.customerId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      challanDate: challanDate ?? this.challanDate,
      unit: unit ?? this.unit,
    );
  }
}

///commet 25-9 10PM
// class ChallanItem {
//   final String description;
//   final int quantity;
//   final double price;
//   final double gstRate;
//   final double? gstAmount; // ✅ Make this a stored field
//   final double? amountWithGst; // ✅ Make this a stored field
//   final String itemId;
//   final String customerId;
//   final String itemName;
//   final double? totalPrice; // ✅ Make this a stored field
//   String? challanId;
//   DateTime? challanDate;
//   final String? unit;
//
//   ChallanItem({
//     required this.description,
//     required this.quantity,
//     required this.price,
//     this.gstRate = 0.0,
//     required this.itemId,
//     required this.customerId,
//     required this.itemName,
//     this.totalPrice, // ✅ Accept from data
//     this.gstAmount, // ✅ Accept from data
//     this.amountWithGst, // ✅ Accept from data
//     this.challanId,
//     this.challanDate,
//     this.unit
//   });
//
//   // ✅ Computed getters as fallback
//   double get calculatedAmount => totalPrice ?? (quantity * price);
//
//   double get calculatedGstAmount =>
//       gstAmount ?? ((calculatedAmount * gstRate) / 100);
//
//   double get calculatedAmountWithGst =>
//       amountWithGst ?? (calculatedAmount + calculatedGstAmount);
//
//   Map<String, dynamic> toMap() {
//     return {
//       'description': description,
//       'quantity': quantity,
//       'price': price,
//       'gstRate': gstRate,
//       'gstAmount': calculatedGstAmount,
//       'amountWithGst': calculatedAmountWithGst,
//       'itemId': itemId,
//       'customerId': customerId,
//       'itemName': itemName,
//       'totalPrice': calculatedAmount,
//       'challanDate': challanDate
//     };
//   }
//
//   factory ChallanItem.fromJson(Map<String, dynamic> map) {
//     print("=== PARSING CHALLAN ITEM ===");
//     print("Raw map data: $map");
//
//     // Parse GST with multiple fallbacks
//     double gstRate = double.tryParse(
//       map['gstRate']?.toString() ??
//           map['GstRate']?.toString() ??
//           map['gst_rate']?.toString() ??
//           '0.0',
//     ) ??
//         0.0;
//     double? gstAmount = double.tryParse(map['gstAmount']?.toString() ?? '');
//     double? amountWithGst =
//     double.tryParse(map['amountWithGst']?.toString() ?? '');
//     double? totalPrice =
//     double.tryParse(map['totalPrice']?.toString() ?? '');
//
//     print("✅ Parsed gstRate: $gstRate");
//     print("✅ Parsed gstAmount: $gstAmount");
//     print("✅ Parsed amountWithGst: $amountWithGst");
//     print("✅ Parsed totalPrice: $totalPrice");
//
//     return ChallanItem(
//       description: map['description']?.toString() ?? '',
//       quantity: int.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
//       price: double.tryParse(map['price']?.toString() ?? '0.0') ?? 0.0,
//       itemId: map['itemId']?.toString() ?? '',
//       customerId: map['customerId']?.toString() ?? '',
//       itemName: map['itemName']?.toString() ?? '',
//       totalPrice: double.tryParse(map['totalPrice']?.toString() ?? '0.0') ??
//           null,
//       // ✅ From data
//       gstRate: gstRate,
//       gstAmount: gstAmount,
//       // ✅ From data
//       amountWithGst: amountWithGst,
//       // ✅ From data
//       challanId: map['challanId']?.toString() ?? map['ChallanId']?.toString() ??
//           '',
//       challanDate: map['challanDate'] != null
//           ? DateTime.tryParse(map['challanDate'].toString())
//           : null,
//     );
//   }
//
//
//   ChallanItem copyWith({
//     String? description,
//     int? quantity,
//     double? price,
//     double? gstRate,
//     double? gstAmount,
//     double? amountWithGst,
//     double? totalPrice,
//     String? customerId,
//     String? itemId,
//     String? itemName,
//     DateTime? challanDate,
//     String? unit,
//   }) {
//     return ChallanItem(
//       description: description ?? this.description,
//       quantity: quantity ?? this.quantity,
//       price: price ?? this.price,
//       gstRate: gstRate ?? this.gstRate,
//       gstAmount: gstAmount ?? this.gstAmount,
//       amountWithGst: amountWithGst ?? this.amountWithGst,
//       totalPrice: totalPrice ?? this.totalPrice,
//       customerId: customerId ?? this.customerId,
//       itemId: itemId ?? this.itemId,
//       itemName: itemName ?? this.itemName,
//       challanDate: challanDate ?? this.challanDate,
//       unit: unit ?? this.unit,
//     );
//   }
// }


////

// class ChallanItem {
//   final String description;
//   final int quantity;
//   final double price;
//   final double gstRate;        // ✅ new
//   final double gstAmount;      // ✅ new
//   final double amountWithGst;  // ✅ new
//   final String itemId;
//   final String customerId;
//   final String itemName;
//   final double totalPrice;
//   String? challanId;
//   DateTime? challanDate;
//
//   ChallanItem({
//     required this.description,
//     required this.quantity,
//     required this.price,
//     this.gstRate = 0.0,
//     required this.itemId,
//     required this.customerId,
//     required this.itemName,
//     required this.totalPrice,
//     this.challanId,
//     this.challanDate
//   }): gstAmount = (quantity * price) * (gstRate / 100),
//         amountWithGst = (quantity * price) + ((quantity * price) * (gstRate / 100));
//
//   double get amount => quantity * price;
//
//
//
//   Map<String, dynamic> toMap() {
//     return {
//       'description': description,
//       'quantity': quantity,
//       'price': price,
//       'gstRate': gstRate,
//       'gstAmount': gstAmount,
//       'amountWithGst': amountWithGst,
//       'itemId': itemId,
//       'customerId': customerId,
//       'itemName': itemName,
//       'totalPrice': totalPrice,
//       'challanDate': challanDate
//     };
//   }
//
//   factory ChallanItem.fromJson(Map<String, dynamic> map) {
//     return ChallanItem(
//       description: map['description']?.toString() ?? '',
//       quantity: int.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
//       price: double.tryParse(map['price']?.toString() ?? '0.0') ?? 0.0,
//       itemId: map['itemId']?.toString() ?? '',
//       customerId: map['customerId']?.toString() ?? '',
//       itemName: map['itemName']?.toString() ?? '',
//       totalPrice: double.tryParse(map['totalPrice']?.toString() ?? '0.0') ?? 0.0,
//       gstRate: double.tryParse(map['gstRate']?.toString() ?? '0.0') ?? 0.0,
//       challanId: map['challanId']?.toString() ?? map['ChallanId']?.toString() ?? '',
//       challanDate: map['challanDate'] != null
//           ? DateTime.tryParse(map['challanDate'].toString())
//           : null,
//     );
//   }
//
//   ChallanItem copyWith({
//     String? description,
//     int? quantity,
//     double? price,
//     double? gstRate,
//     String? customerId,
//     String? itemId,
//     String? itemName,
//     double? totalPrice,
//     double? gstAmount,
//     double? amountWithGst,
//     DateTime? challanDate
//   }) {
//     return ChallanItem(
//       description: description ?? this.description,
//       quantity: quantity ?? this.quantity,
//       price: price ?? this.price,
//       gstRate: gstRate ?? this.gstRate,
//       customerId: customerId ?? this.itemId,
//       itemId: itemId ?? this.itemId,
//       itemName: itemName ?? this.itemName,
//       totalPrice: totalPrice ?? this.totalPrice,
//       challanDate: challanDate ?? this.challanDate,
//     );
//   }
