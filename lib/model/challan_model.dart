import 'package:intl/intl.dart';

import 'item_model.dart';

class Challan {
  final String challanId;
   DateTime? challanDate;
  final String customerId;
  final String customerName;
  final String customerMobile;
  final String customerEmail;
  final String customerAddress;
  final String? itemId;
  final String? itemName;
  final int? qty;
  final double? price;
  final double? gst;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
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
    this.customerAddress = '',
     this.itemId,
     this.itemName,
     this.qty,
     this.price,
    this.gst = 0.0,
    required this.subtotal,
    this.taxRate = 0.0,
    this.taxAmount = 0.0,
    this.paymentStatus = 'Pending',
    this.notes = '',
    this.status = 'Draft',
    this.items,
    this.userId
  });

  // Convert Challan object to Map
  Map<String, dynamic> toMap() {
    return {
      'challanId': challanId,
      'challanDate': challanDate?.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'customerMobile': customerMobile,
      'customerEmail': customerEmail,
      'customerAddress': customerAddress,
      'itemId': itemId,
      'itemName': itemName,
      'qty': qty,
      'price': price,
      'gst':gst,
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'paymentStatus': paymentStatus,
      'notes': notes,
      'status': status,
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
      customerAddress: map['customerAddress'] ?? '',
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      qty: map['qty'] != null ? int.parse(map['qty'].toString()) : 0,
      price: map['price'] != null ? double.parse(map['price'].toString()) : 0.0,
      gst: map['gst'] != null ? double.parse(map['gst'].toString()) : 0.0,
      subtotal: map['subtotal'] != null ? double.parse(map['subtotal'].toString()) : 0.0,
      taxRate: map['taxRate'] != null ? double.parse(map['taxRate'].toString()) : 0.0,
      taxAmount: map['taxAmount'] != null ? double.parse(map['taxAmount'].toString()) : 0.0,
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
      customerAddress: json['customerAddress']?.toString() ?? '',
      itemId: json['itemId']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? '',
      qty: json['qty'] != null ? int.tryParse(json['qty'].toString()) ?? 0 : 0,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      gst: json['gst'] != null ? double.tryParse(json['gst'].toString()) ?? 0.0 : 0.0,
      subtotal: json['subtotal'] != null ? double.tryParse(json['subtotal'].toString()) ?? 0.0 : 0.0,
      taxRate: json['taxRate'] != null ? double.tryParse(json['taxRate'].toString()) ?? 0.0 : 0.0,
      taxAmount: json['taxAmount'] != null ? double.tryParse(json['taxAmount'].toString()) ?? 0.0 : 0.0,
      paymentStatus: json['paymentStatus']?.toString() ?? 'Pending',
      notes: json['notes']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Draft',
      items: json['items'] != null
          ? (json['items'] as List).map((item) => ChallanItem.fromJson(item)).toList()
          : [],
    );
  }

  // Optional: Copy with method for easy updates
  Challan copyWith({
    String? challanId,
    DateTime? challanDate,
    String? customerId,
    String? customerName,
    String? customerMobile,
    String? customerEmail,
    String? customerAddress,
    String? itemId,
    String? itemName,
    int? qty,
    double? price,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
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
      customerMobile: customerMobile ?? this.customerMobile,
      customerEmail: customerEmail ?? this.customerEmail,
      customerAddress: customerAddress ?? this.customerAddress,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      items: items,
    );
  }
}


class ChallanItem {
  final String description;
  final int quantity;
  final double price;
  double gst;
  final String itemId;
  final String customerId;
  final String itemName;
  final double totalPrice;
  String? challanId;
  DateTime? challanDate;

  ChallanItem({
    required this.description,
    required this.quantity,
    required this.price,
    this.gst = 0.0,
    required this.itemId,
    required this.customerId,
    required this.itemName,
    required this.totalPrice,
    this.challanId,
    this.challanDate
  });

  double get amount => quantity * price;

  double get amountWithGst => quantity * price * (1 + gst / 100);

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'quantity': quantity,
      'price': price,
      'gst':gst,
      'itemId': itemId,
      'customerId': customerId,
      'itemName': itemName,
      'totalPrice': totalPrice,
      'challanDate': challanDate
    };
  }

  factory ChallanItem.fromJson(Map<String, dynamic> map) {
    return ChallanItem(
      description: map['description']?.toString() ?? '',
      quantity: int.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
      price: double.tryParse(map['price']?.toString() ?? '0.0') ?? 0.0,
      itemId: map['itemId']?.toString() ?? '',
      customerId: map['customerId']?.toString() ?? '',
      itemName: map['itemName']?.toString() ?? '',
      totalPrice: double.tryParse(map['totalPrice']?.toString() ?? '0.0') ?? 0.0,
      challanId: map['challanId']?.toString() ?? map['ChallanId']?.toString() ?? '',
      challanDate: map['challanDate'] != null
          ? DateTime.tryParse(map['challanDate'].toString())
          : null,
    );
  }

  ChallanItem copyWith({
    String? description,
    int? quantity,
    double? price,
    double? gst,
    String? customerId,
    String? itemId,
    String? itemName,
    double? totalPrice,
    DateTime? challanDate
  }) {
    return ChallanItem(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      gst: gst ?? this.gst,
      customerId: customerId ?? this.itemId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      totalPrice: totalPrice ?? this.totalPrice,
      challanDate: challanDate ?? this.challanDate,
    );
  }
}