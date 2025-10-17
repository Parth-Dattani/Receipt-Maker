class InventoryTransaction {
  final String transactionId;
  final String itemId;
  final String itemName;
  final int quantity;
  final String type; // 'add', 'remove', 'sale', 'return', 'adjustment'
  final String reason;
  final DateTime timestamp;
  final String notes;

  InventoryTransaction({
    required this.transactionId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.type,
    required this.reason,
    required this.timestamp,
    required this.notes,
  });

  Map<String, dynamic> toMap() => {
    'transactionId': transactionId,
    'itemId': itemId,
    'itemName': itemName,
    'quantity': quantity,
    'type': type,
    'reason': reason,
    'timestamp': timestamp.toIso8601String(),
    'notes': notes,
  };

  factory InventoryTransaction.fromMap(Map<String, dynamic> map) =>
      InventoryTransaction(
        transactionId: map['transactionId'],
        itemId: map['itemId'],
        itemName: map['itemName'],
        quantity: map['quantity'],
        type: map['type'],
        reason: map['reason'],
        timestamp: DateTime.parse(map['timestamp']),
        notes: map['notes'],
      );
}
