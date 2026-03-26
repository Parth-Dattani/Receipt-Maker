// import 'dart:convert';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
//
// import '../constant/app_constant.dart';
//
// /// Calls your Google Apps Script web app to create a new spreadsheet,
// /// then saves the returned Sheet ID to Firestore and local prefs.
// /// Used after user registration (Option C).
// class AppsScriptSheetService {
//   /// Creates a new Google Sheet via Apps Script and saves the Sheet ID to
//   /// Firestore `users/[uid]` and to SharedPreferences/AppConstants.
//   ///
//   /// Returns the new [spreadsheetId] on success.
//   /// Throws if [AppConstants.appsScriptCreateSheetUrl] is empty, or on network/Firestore error.
//   static Future<String> createSheetAndSaveForUser(String uid) async {
//     final url = AppConstants.appsScriptCreateSheetUrl.trim();
//     if (url.isEmpty) {
//       print('❌ [CreateSheet] Apps Script URL is empty. Set AppConstants.appsScriptCreateSheetUrl in app_constant.dart');
//       throw Exception(
//         'Apps Script URL not set. Deploy scripts/CreateUserSheet.gs and set AppConstants.appsScriptCreateSheetUrl.',
//       );
//     }
//
//     print('🔄 [CreateSheet] Calling Apps Script: $url');
//     final uri = Uri.parse(url);
//
//     http.Response response;
//     try {
//       // Apps Script web app: doGet() is called for GET. Use GET first.
//       response = await http.get(uri).timeout(
//         const Duration(seconds: 30),
//         onTimeout: () => throw Exception('Create sheet request timed out'),
//       );
//       // If GET returns 405 or wrong content, try POST (doPost)
//       if (response.statusCode == 405 || (response.statusCode == 200 && response.body.trim().isEmpty)) {
//         print('🔄 [CreateSheet] GET failed or empty, trying POST...');
//         response = await http.post(uri).timeout(
//           const Duration(seconds: 30),
//           onTimeout: () => throw Exception('Create sheet request timed out'),
//         );
//       }
//     } catch (e) {
//       print('❌ [CreateSheet] Request failed: $e');
//       rethrow;
//     }
//
//     final bodyStr = response.body;
//     print('📥 [CreateSheet] Response status: ${response.statusCode}, body length: ${bodyStr.length}');
//
//     if (response.statusCode != 200) {
//       print('❌ [CreateSheet] Non-200 response body: $bodyStr');
//       throw Exception('Create sheet failed: ${response.statusCode} ${bodyStr.length > 200 ? "${bodyStr.substring(0, 200)}..." : bodyStr}');
//     }
//
//     Map<String, dynamic>? body;
//     try {
//       final decoded = jsonDecode(bodyStr);
//       if (decoded is Map<String, dynamic>) {
//         body = decoded;
//       } else if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
//         body = Map<String, dynamic>.from(decoded.first as Map);
//       } else {
//         print('❌ [CreateSheet] Unexpected JSON shape: $decoded');
//         throw Exception('Invalid response format from Apps Script');
//       }
//     } catch (e) {
//       if (e is FormatException) {
//         print('❌ [CreateSheet] JSON parse error. Response body: $bodyStr');
//         throw Exception('Apps Script did not return valid JSON. Check script deployment. Body: ${bodyStr.length > 150 ? bodyStr.substring(0, 150) : bodyStr}');
//       }
//       rethrow;
//     }
//
//     final success = body['success'] == true;
//     final spreadsheetId = body['spreadsheetId']?.toString();
//
//     if (!success || spreadsheetId == null || spreadsheetId.isEmpty) {
//       final err = body['error']?.toString();
//       print('❌ [CreateSheet] Script returned error or no ID. success=$success, spreadsheetId=$spreadsheetId, error=$err');
//       throw Exception(err ?? 'Apps Script did not return a spreadsheet ID');
//     }
//
//     print('✅ [CreateSheet] Got spreadsheetId: $spreadsheetId');
//
//     try {
//       await FirebaseFirestore.instance.collection('users').doc(uid).set(
//         {
//           'spreadsheetId': spreadsheetId,
//           'updatedAt': FieldValue.serverTimestamp(),
//         },
//         SetOptions(merge: true),
//       );
//     } catch (e) {
//       print('❌ [CreateSheet] Firestore update failed: $e');
//       rethrow;
//     }
//
//     await AppConstants.setSpreadsheetId(spreadsheetId);
//     return spreadsheetId;
//   }
// }
