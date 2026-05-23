import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptModel {
  final String? id;
  final int recNo;
  final String date;
  final String donorName;
  final String panNo;
  final String mobileNo;
  final double amount;
  final String amountInWords;
  final String paymentType;
  final String bankName;
  final String chequeNo;
  final String remarks;
  final String donationType;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReceiptModel({
    this.id,
    required this.recNo,
    required this.date,
    required this.donorName,
    required this.panNo,
    required this.mobileNo,
    required this.amount,
    required this.amountInWords,
    required this.paymentType,
    required this.bankName,
    required this.chequeNo,
    required this.remarks,
    required this.donationType,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'recNo': recNo,
    'date': date,
    'donorName': donorName,
    'panNo': panNo,
    'mobileNo': mobileNo,
    'amount': amount,
    'amountInWords': amountInWords,
    'paymentType': paymentType,
    'bankName': bankName,
    'chequeNo': chequeNo,
    'remarks': remarks,
    'donationType': donationType,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory ReceiptModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReceiptModel(
      id: doc.id,
      recNo: d['recNo'] ?? 0,
      date: d['date'] ?? '',
      donorName: d['donorName'] ?? '',
      panNo: d['panNo'] ?? '',
      mobileNo: d['mobileNo'] ?? '',
      amount: (d['amount'] ?? 0).toDouble(),
      amountInWords: d['amountInWords'] ?? '',
      paymentType: d['paymentType'] ?? 'Cash',
      bankName: d['bankName'] ?? '',
      chequeNo: d['chequeNo'] ?? '',
      remarks: d['remarks'] ?? '',
      donationType: d['donationType'] ?? 'General',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // 🚀 FIXED: No more row[0] or row[1]. This factory now accepts a dynamic map
  // generated straight from the Google Sheet column names!
  factory ReceiptModel.fromDynamicMap(Map<String, dynamic> data) {
    return ReceiptModel(
      id: null,
      recNo: data['RecNo'] ?? 0,
      date: data['Date'] ?? '',
      donorName: data['Donor Name'] ?? '',
      panNo: data['PAN No'] ?? '',
      mobileNo: data['Mobile No'] ?? '',
      amount: (data['Amount'] ?? 0.0).toDouble(),
      amountInWords: data['Amount In Words'] ?? '',
      paymentType: data['Payment Type'] ?? 'Cash',
      bankName: data['Bank Name'] ?? '',
      chequeNo: data['Cheque No'] ?? '',
      remarks: data['Remarks'] ?? '',
      donationType: data['Donation Type'] ?? 'General',
      createdAt: data['Created At'] ?? DateTime.now(),
      updatedAt: data['UpdatedAt'] ?? DateTime.now(),
    );
  }

  // Used only for generating initial list arrays safely
  List<dynamic> toSheetRow() => [
    recNo, date, donorName, panNo, mobileNo, amount, amountInWords,
    paymentType, bankName, chequeNo, remarks, donationType,
    createdAt.toIso8601String(), updatedAt.toIso8601String()
  ];

  static ReceiptModel dummy() {
    return ReceiptModel(
      id: 'dummy',
      recNo: 0,
      date: '00/00/0000',
      donorName: 'Loading Name...',
      panNo: '-',
      mobileNo: '0000000000',
      amount: 0,
      amountInWords: '-',
      paymentType: 'Cash',
      bankName: '-',
      chequeNo: '-',
      remarks: '-',
      donationType: 'General',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
