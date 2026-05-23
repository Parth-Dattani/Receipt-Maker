import 'package:cloud_firestore/cloud_firestore.dart';

enum InvoiceType { invoice, quotation }

class Invoice {
  final String invoiceId;
  final String customerName;
  final String? customerAddress;
  final String? mobile;
  final String? customerEmail;
  final String? customerPan;
  final String? customerGst;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final String? status;
  final List<InvoiceItem>? items;
  final double? subtotal;
  final double? gstAmount;
  final double? totalAmount;
  final String? notes;
  final String? itemName; // For simple single-item cases
  final double? price;    // For simple single-item cases
  final double? qty;      // For simple single-item cases
  final double? gst;      // For simple single-item cases
  final String? challanId;

  Invoice({
    required this.invoiceId,
    required this.customerName,
    this.customerAddress,
    this.mobile,
    this.customerEmail,
    this.customerPan,
    this.customerGst,
    this.issueDate,
    this.dueDate,
    this.status,
    this.items,
    this.subtotal,
    this.gstAmount,
    this.totalAmount,
    this.notes,
    this.itemName,
    this.price,
    this.qty,
    this.gst,
    this.challanId,
  });
}

class InvoiceItem {
  final String itemName;
  final String description;
  final double quantity;
  final double? rate;
  final double? gstRate;
  final double? gstAmount;
  final double? totalPrice;
  final String? challanId;

  InvoiceItem({
    required this.itemName,
    this.description = '',
    required this.quantity,
    this.rate,
    this.gstRate,
    this.gstAmount,
    this.totalPrice,
    this.challanId,
  });
}

class Challan {
  final String challanId;
  final DateTime? challanDate;
  final String customerName;
  final String? customerMobile;
  final String? customerAddress;
  final String paymentStatus;
  final String? notes;
  final List<ChallanItem>? items;
  final double? subtotal;
  final double? gstAmount;
  final String? itemName; // Simple case
  final double? price;    // Simple case
  final double? qty;      // Simple case
  final double? gst;      // Simple case

  Challan({
    required this.challanId,
    this.challanDate,
    required this.customerName,
    this.customerMobile,
    this.customerAddress,
    required this.paymentStatus,
    this.notes,
    this.items,
    this.subtotal,
    this.gstAmount,
    this.itemName,
    this.price,
    this.qty,
    this.gst,
  });
}

class ChallanItem {
  final String? itemName;
  final double? quantity;
  final double? price;
  final double? gstRate;
  final double? gstAmount;
  final double? totalPrice;

  ChallanItem({
    this.itemName,
    this.quantity,
    this.price,
    this.gstRate,
    this.gstAmount,
    this.totalPrice,
  });
}
