// Add these new models to your models file

class PurchaseItem {
  final String itemId;
  final String itemName;
  final String description;
  final int quantity;
  final double purchasePrice;
  final String unit;
  final double gstRate;
  final double totalPrice;
  final String vendorId;
  final DateTime createdAt;

  PurchaseItem({
    required this.itemId,
    required this.itemName,
    required this.description,
    required this.quantity,
    required this.purchasePrice,
    required this.unit,
    required this.gstRate,
    required this.totalPrice,
    required this.vendorId,
    required this.createdAt,
  });

  /// 🏗 Factory — Convert from Map (e.g., Firebase, Google Sheet)
  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      itemId: json['itemId'] ?? '',
      itemName: json['itemName'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()) ?? 0,
      purchasePrice: json['purchasePrice'] is double
          ? json['purchasePrice']
          : double.tryParse(json['purchasePrice'].toString()) ?? 0.0,
      unit: json['unit'] ?? '',
      gstRate: json['gstRate'] is double
          ? json['gstRate']
          : double.tryParse(json['gstRate'].toString()) ?? 0.0,
      totalPrice: json['totalPrice'] is double
          ? json['totalPrice']
          : double.tryParse(json['totalPrice'].toString()) ?? 0.0,
      vendorId: json['vendorId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// 📤 Convert to Map (for saving)
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'description': description,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'unit': unit,
      'gstRate': gstRate,
      'totalPrice': totalPrice,
      'vendorId': vendorId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 🧮 Helper: Calculate total price if needed
  double calculateTotal() {
    final gstAmount = (purchasePrice * quantity) * (gstRate / 100);
    return (purchasePrice * quantity) + gstAmount;
  }

  /// 🧪 CopyWith for updates
  PurchaseItem copyWith({
    String? itemId,
    String? itemName,
    String? description,
    int? quantity,
    double? purchasePrice,
    String? unit,
    double? gstRate,
    double? totalPrice,
    String? vendorId,
    DateTime? createdAt,
  }) {
    return PurchaseItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      unit: unit ?? this.unit,
      gstRate: gstRate ?? this.gstRate,
      totalPrice: totalPrice ?? this.totalPrice,
      vendorId: vendorId ?? this.vendorId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


class PurchaseEntry {
  final String? purchaseId;
  final String? vendorId;
  final String? vendorName;
  final String? vendorEmail;
  final String? vendorMobile;
  final String? vendorAddress;
  final DateTime? purchaseDate;
  final double? subtotal;
  final double? gstAmount;
  final double? totalAmount;
  final String? paymentStatus;
  final String? notes;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PurchaseEntry({
    this.purchaseId,
    this.vendorId,
    this.vendorName,
    this.vendorEmail,
    this.vendorMobile,
    this.vendorAddress,
    this.purchaseDate,
    this.subtotal,
    this.gstAmount,
    this.totalAmount,
    this.paymentStatus,
    this.notes,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor - Convert from Map (Firebase, Google Sheets)
  factory PurchaseEntry.fromJson(Map<String, dynamic> json) {
    return PurchaseEntry(
      purchaseId: json['purchaseId'] as String?,
      vendorId: json['vendorId'] as String?,
      vendorName: json['vendorName'] as String?,
      vendorEmail: json['vendorEmail'] as String?,
      vendorMobile: json['vendorMobile'] as String?,
      vendorAddress: json['vendorAddress'] as String?,
      purchaseDate: json['purchaseDate'] != null
          ? json['purchaseDate'] is DateTime
          ? json['purchaseDate'] as DateTime
          : DateTime.tryParse(json['purchaseDate'].toString())
          : null,
      subtotal: json['subtotal'] != null
          ? (json['subtotal'] is double
          ? json['subtotal'] as double
          : double.tryParse(json['subtotal'].toString()) ?? 0.0)
          : 0.0,
      gstAmount: json['gstAmount'] != null
          ? (json['gstAmount'] is double
          ? json['gstAmount'] as double
          : double.tryParse(json['gstAmount'].toString()) ?? 0.0)
          : 0.0,
      totalAmount: json['totalAmount'] != null
          ? (json['totalAmount'] is double
          ? json['totalAmount'] as double
          : double.tryParse(json['totalAmount'].toString()) ?? 0.0)
          : 0.0,
      paymentStatus: json['paymentStatus'] as String? ?? 'Pending',
      notes: json['notes'] as String?,
      userId: json['userId'] as String?,
      createdAt: json['createdAt'] != null
          ? json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? json['updatedAt'] is DateTime
          ? json['updatedAt'] as DateTime
          : DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Convert to Map (for saving to database)
  Map<String, dynamic> toJson() {
    return {
      'purchaseId': purchaseId,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'vendorEmail': vendorEmail,
      'vendorMobile': vendorMobile,
      'vendorAddress': vendorAddress,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'subtotal': subtotal,
      'gstAmount': gstAmount,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'notes': notes,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// CopyWith - Create a modified copy of this object
  PurchaseEntry copyWith({
    String? purchaseId,
    String? vendorId,
    String? vendorName,
    String? vendorEmail,
    String? vendorMobile,
    String? vendorAddress,
    DateTime? purchaseDate,
    double? subtotal,
    double? gstAmount,
    double? totalAmount,
    String? paymentStatus,
    String? notes,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseEntry(
      purchaseId: purchaseId ?? this.purchaseId,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      vendorEmail: vendorEmail ?? this.vendorEmail,
      vendorMobile: vendorMobile ?? this.vendorMobile,
      vendorAddress: vendorAddress ?? this.vendorAddress,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      subtotal: subtotal ?? this.subtotal,
      gstAmount: gstAmount ?? this.gstAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Equality operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PurchaseEntry &&
              runtimeType == other.runtimeType &&
              purchaseId == other.purchaseId &&
              vendorId == other.vendorId;

  /// Hash code
  @override
  int get hashCode => purchaseId.hashCode ^ vendorId.hashCode;

  /// ToString for debugging
  @override
  String toString() {
    return 'PurchaseEntry(purchaseId: $purchaseId, vendorName: $vendorName, totalAmount: $totalAmount, paymentStatus: $paymentStatus)';
  }

  /// Check if purchase is valid
  bool isValid() {
    return purchaseId != null &&
        purchaseId!.isNotEmpty &&
        vendorId != null &&
        vendorId!.isNotEmpty &&
        vendorName != null &&
        vendorName!.isNotEmpty &&
        totalAmount != null &&
        totalAmount! > 0;
  }

  /// Get formatted purchase date
  String getFormattedDate() {
    if (purchaseDate == null) return 'N/A';
    return '${purchaseDate!.day.toString().padLeft(2, '0')}/${purchaseDate!.month.toString().padLeft(2, '0')}/${purchaseDate!.year}';
  }

  /// Get payment status color (for UI)
  String getPaymentStatusColor() {
    switch (paymentStatus) {
      case 'Paid':
        return 'green';
      case 'Pending':
        return 'orange';
      case 'Partial':
        return 'blue';
      default:
        return 'grey';
    }
  }
}