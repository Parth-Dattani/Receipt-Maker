// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
// import 'package:logger/logger.dart';
// import '../constant/app_constant.dart';
// import '../model/receipt_model.dart';
//
// class ReceiptService {
//   static final _db = FirebaseFirestore.instance;
//   static final _log = Logger();
//   static const _col = 'receipts';
//
//   // ── Firestore ──────────────────────────────────────
//
//   static Future<int> getNextReceiptNo() async {
//     try {
//       final snap = await _db
//           .collection(_col)
//           .orderBy('recNo', descending: true)
//           .limit(1)
//           .get();
//       if (snap.docs.isEmpty) return 1;
//       return (snap.docs.first['recNo'] as int) + 1;
//     } catch (e) {
//       _log.e('getNextReceiptNo: $e');
//       return 1;
//     }
//   }
//
//   static Future<bool> saveToFirestore(ReceiptModel receipt) async {
//     try {
//       await _db.collection(_col).add(receipt.toJson());
//       return true;
//     } catch (e) {
//       _log.e('saveToFirestore: $e');
//       return false;
//     }
//   }
//
//   static Stream<List<ReceiptModel>> receiptsStream() {
//     return _db
//         .collection(_col)
//         .orderBy('recNo', descending: true)
//         .snapshots()
//         .map((s) => s.docs.map(ReceiptModel.fromFirestore).toList());
//   }
//
//   static Future<List<ReceiptModel>> getReceipts() async {
//     try {
//       final snap = await _db
//           .collection(_col)
//           .orderBy('recNo', descending: true)
//           .get();
//       return snap.docs.map(ReceiptModel.fromFirestore).toList();
//     } catch (e) {
//       _log.e('getReceipts: $e');
//       return [];
//     }
//   }
//
//   // Dashboard stats
//   static Future<Map<String, dynamic>> getDashboardStats() async {
//     try {
//       final snap = await _db.collection(_col).get();
//       final receipts = snap.docs.map(ReceiptModel.fromFirestore).toList();
//
//       final now = DateTime.now();
//       double totalAmount = 0;
//       double monthAmount = 0;
//       double todayAmount = 0;
//
//       for (final r in receipts) {
//         totalAmount += r.amount;
//         if (r.createdAt.year == now.year && r.createdAt.month == now.month) {
//           monthAmount += r.amount;
//         }
//         if (r.createdAt.year == now.year &&
//             r.createdAt.month == now.month &&
//             r.createdAt.day == now.day) {
//           todayAmount += r.amount;
//         }
//       }
//
//       return {
//         'totalReceipts': receipts.length,
//         'totalAmount': totalAmount,
//         'monthAmount': monthAmount,
//         'todayAmount': todayAmount,
//         'recentReceipts': receipts.take(5).toList(),
//       };
//     } catch (e) {
//       _log.e('getDashboardStats: $e');
//       return {};
//     }
//   }
//
//   // ── Google Sheet ──────────────────────────────────
//
//   static Future<bool> saveToSheet(ReceiptModel receipt) async {
//     try {
//       if (AppStrings.appsScriptUrl == 'YOUR_APPS_SCRIPT_WEB_APP_URL') {
//         return false; // Not configured
//       }
//       final response = await http.post(
//         Uri.parse(AppStrings.appsScriptUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'action': 'addReceipt', 'data': receipt.toJson()}),
//       );
//       if (response.statusCode == 200) {
//         final result = jsonDecode(response.body);
//         return result['success'] == true;
//       }
//       return false;
//     } catch (e) {
//       _log.e('saveToSheet: $e');
//       return false;
//     }
//   }
// }
