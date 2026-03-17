import 'dart:convert';
import 'dart:math';
import 'dart:math' as Math;

import 'package:GetYourInvoice/constant/app_constant.dart';
import 'package:GetYourInvoice/model/comment_model.dart';
import 'package:GetYourInvoice/services/api.dart';
import 'package:GetYourInvoice/utils/shared_preferences_helper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/model.dart';
import '../utils/pdf_helper.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
///old Working
// class RemoteService{
//
//   static const String appId = "24b22f90-835f-4202-a038-3f1dd7057aa8"; // Replace
//   static const String accessKey = "V2-9NVog-SGuQ6-prAu2-HG5GE-Y6K1d-w40RW-XAlD5-EbLcB"; // Replace
//   static const String invoiceTableName = "Invoice";
//   static const String itemsTableName = "Item"; // Replace
//   static const String apiKey = "cnp1X-AFICA-X25lf-NuAwm-jQfEr-Cj9nr-S9mqj-xOYni";
//
//
//
//   static Future<http.Response> getComment() async {
//     Map<String, String>header = {
//       'Content-Type': 'application/json',
//     };
//
//     final uri = Uri.parse(Apis.commetApi);
//
//     http.Response response = await http.get(
//         headers: header,
//         uri);
//     return response;
//   }
//
//
//   /// Add item to Items table
//   static Future<void> addItem(Item item) async {
//     final url = Uri.parse(
//         "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action");
//
//     final body = jsonEncode({
//       "Action": "Add",
//       "Rows": [item.toMap()],
//     });
//
//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "ApplicationAccessKey": accessKey,
//       },
//       body: body,
//     );
//
//     if (response.statusCode == 200) {
//       print("✅ Item added successfully: ${response.body}");
//     } else {
//       throw Exception("❌ Failed to add item: ${response.body}");
//     }
//   }
//
//
//
//   static Future<void> addInvoice(List<Invoice> invoices) async {
//    checkInvoiceTableStructure();
//     final url = Uri.parse(
//         "https://api.appsheet.com/api/v2/apps/$appId/tables/$invoiceTableName/Action");
//
//     final body = jsonEncode({
//       "Action": "Add",
//       "Rows": invoices.map((e) => e.toMap()).toList(),
//     });
//
//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "ApplicationAccessKey": accessKey, // ✅ must match AppSheet key
//       },
//       body: body,
//     );
//
//     print("AppSheet Response:-saveRespo:---- ${response.statusCode} - ${response.body}");
//
//     if (response.statusCode == 200) {
//       print("-----Error on saveInvoice() in service,,,, e.toString()}");
//       final responseData = jsonDecode(response.body);
//       if (responseData is Map && responseData.containsKey("RowsAffected")) {
//         print("✅ Invoice sent successfully. Rows affected: ${responseData["RowsAffected"]}");
//       }
//       else {
//         print("✅ Invoice sent successfully: ${response.body}");
//       }
//       // ⬇️ Share invoice after success
//       ///await InvoiceHelper.generateAndShareInvoice(invoices);
//     } else {
//       throw Exception("❌ Failed to send invoice: ${response.body}");
//     }
//   }
//
//   // Debug method to check table structure
//   static Future<void> checkInvoiceTableStructure() async {
//     final url = Uri.parse(
//         "https://api.appsheet.com/api/v2/apps/$appId/tables/$invoiceTableName/Action");
//
//     final body = jsonEncode({
//       "Action": "Find",
//       "Properties": {
//         "Locale": "en-US",
//         "Selector": 'Filter(1=1)',
//         "SelectColumns": ["pid", "productName", "qty", "price", "mobile", "userName", "date"]
//       }
//     });
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "ApplicationAccessKey": accessKey,
//         },
//         body: body,
//       );
//
//       print("Table Structure Response: ${response.statusCode} - ${response.body}");
//     } catch (e) {
//       print("Error checking table structure: $e");
//     }
//   }
//
//   static Future<List<Invoice>> fetchInvoices() async {
//     final url =
//     Uri.parse("https://api.appsheet.com/api/v2/apps/$appId/tables/$invoiceTableName/Action");
//
//     final body = jsonEncode({
//       "Action": "Find",
//       "Properties": {
//         "Locale": "en-US",
//         "Selector": 'Sort([{ColumnName: "date", Ascending: false}])',
//       }
//     });
//
//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "ApplicationAccessKey": accessKey,
//       },
//       body: body,
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data is Map && data.containsKey("Rows")) {
//         final rows = data["Rows"] as List;
//         return rows.map((e) => Invoice.fromMap(e)).toList();
//       } else {
//         throw Exception("Invalid response format: ${response.body}");
//       }
//     }  else {
//       throw Exception("❌ Failed to load invoices: ${response.body}");
//     }
//   }
//
//
//   // Get all items from Items table
//   static Future<List<Item>> getItems() async {
//     final url = Uri.parse(
//         "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action");
//
//     final body = jsonEncode({
//       "Action": "Find",
//       "Properties": {},
//       "Rows": []
//     });
//
//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "ApplicationAccessKey": accessKey,
//       },
//       body: body,
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       // final List items = data['Rows'] ?? [];
//       print("------------data:${data}");
//
//
//       // return items.map((e) => Item.fromMap(e)).toList();
//
//       if (data is List) {
//         return data.map((e) => Item.fromMap(e)).toList();
//       }
//        else if (data is Map && data["Rows"] is List) {
//         final rows = data["Rows"] as List;
//         return rows.map((e) => Item.fromMap(e)).toList();
//       }
//       else {
//         throw Exception("Invalid response format: ${response.body}");
//       }
//     } else {
//       throw Exception("❌ Failed to load items: ${response.body}");
//     }
//   }
//
//   static Future<void> addSingleInvoice(Map<String, dynamic> invoiceRow) async {
//   final url = Uri.parse(
//       "https://api.appsheet.com/api/v2/apps/$appId/tables/Invoice/Action");
//   final body = jsonEncode({
//     "Action": "Add",
//     "Rows": [invoiceRow],
//   });
//
//   final response = await http.post(
//     url,
//     headers: {
//       "ApplicationAccessKey": accessKey,
//       "Content-Type": "application/json",
//     },
//     body: body,
//   );
//
//   print("AppSheet Response: ${response.statusCode} - ${response.body}");
//
//   if (response.statusCode != 200) {
//     throw Exception("❌ Failed to send invoice: ${response.body}");
//   }
// }
//
//   static Future<void> editItem(String itemId, String newName, double newPrice) async {
//     final url = Uri.parse(
//       "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action",
//     );
//
//     final body = jsonEncode({
//       "Action": "Edit",
//       "Rows": [
//         {
//           "itemId": itemId,
//           "itemName": newName,
//           "price": newPrice.toStringAsFixed(2), // keeping 2 decimals
//         }
//       ]
//     });
//
//     print("Editing item: $body");
//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "ApplicationAccessKey": accessKey,
//       },
//       body: body,
//     );
//
//     print("Edit Item Response: ${response.statusCode} - ${response.body}");
//     if (response.statusCode != 200) {
//       throw Exception("❌ Failed to edit item: ${response.body}");
//     }
//   }
// }
import 'package:googleapis_auth/auth_io.dart';

///new
class RemoteService {

  String userId = AppConstants.userId;

  //static const String appId = "7c98235e-c3c5-45f5-8eb5-821e663cfb18";
  static  String appId = "${AppConstants.appId}";
  static  String accessKey = "${AppConstants.accessKey}";
  //static const String accessKey = "V2-5d3Ce-l3bYG-DdBdG-YeamP-d2BeZ-f9ono-4x5TT-CfCJP";
  static const String invoiceTableName = "Invoice";
  static const String invoiceItemTableName = "InvoiceItems";
  static const String challanItemTableName = "ChallanItems";
  static const String itemsTableName = "Item";
  static const String challanTableName = "Challan";
  ///static const String itemsTableName2 = "Item_";
  static const String apiKey = "cnp1X-AFICA-X25lf-NuAwm-jQfEr-Cj9nr-S9mqj-xOYni";


  static Future<http.Response> getComment() async {
    Map<String, String> header = {
      'Content-Type': 'application/json',
    };

    final uri = Uri.parse(Apis.commetApi);

    http.Response response = await http.get(headers: header, uri);
    return response;
  }
  /// its Workig With AppSheet
  /// Add item to Items table with enhanced fields
  // static Future<void> addItem(String userId,Item item) async {
  //   final dynamicTableName = "${itemsTableName}_$userId";
  //   print("Dynamic Item Tabel name   :--------- ${dynamicTableName}");
  //   final url = Uri.parse(
  //       "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action"
  //       ///"https://api.appsheet.com/api/v2/apps/$appId/tables/$dynamicTableName/Action"
  //   );
  //
  //   print("Dynamic Item Tabel Api Url :--------- ${url}");
  //
  //   // Ensure userId is included in the item data
  //   final itemData = {
  //     ...item.toMap(),
  //     "userId": userId, // Make sure this matches your column name exactly
  //   };
  //
  //   final body = jsonEncode({
  //     "Action": "Add",
  //     "Rows": [
  //       itemData
  //      ],
  //   });
  //
  //   print("Adding item with data-01: $itemData");
  //   print("Adding item with data: ${item.toMap()}");
  //
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Content-Type": "application/json",
  //       "ApplicationAccessKey": accessKey,
  //     },
  //     body: body,
  //   );
  //
  //   print("Add Item Response: ${response.statusCode} - ${response.body}");
  //
  //   if (response.statusCode == 200) {
  //     print("Item added successfully: ${response.body}");
  //   } else {
  //     throw Exception("Failed to add item: ${response.body}");
  //   }
  // }



  /// its Workig With AppSheet
  // static Future<void> addInvoice(dynamic invoiceData, String userId) async {
  //   checkInvoiceTableStructure();
  //   final url = Uri.parse(
  //       "https://api.appsheet.com/api/v2/apps/$appId/tables/$invoiceTableName/Action");
  //
  //   List<Map<String, dynamic>> rowsToSend = [];
  //
  //   if (invoiceData is Map<String, dynamic>) {
  //     // Single invoice with items
  //     if (invoiceData.containsKey('items') && invoiceData['items'] is List) {
  //       invoiceData['items'] = jsonEncode(invoiceData['items']);
  //     }
  //     rowsToSend.add({
  //       ...invoiceData,
  //       "userId": userId,
  //     });
  //   } else if (invoiceData is List<Invoice>) {
  //     // Multiple invoice rows (legacy format)
  //     rowsToSend = invoiceData.map((inv) {
  //       return {
  //         ...inv.toMap(),
  //         "userId": userId,
  //       };
  //     }).toList();
  //   }
  //
  //   final body = jsonEncode({
  //     "Action": "Add",
  //     "Rows": rowsToSend,
  //   });
  //
  //   print("Sending to AppSheet: ${jsonEncode(body)}");
  //
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Content-Type": "application/json",
  //       "ApplicationAccessKey": accessKey,
  //     },
  //     body: body,
  //   );
  //
  //   print("AppSheet Response: ${response.statusCode} - ${response.body}");
  //
  //   if (response.statusCode == 200) {
  //     final responseData = jsonDecode(response.body);
  //     if (responseData is Map && responseData.containsKey("RowsAffected")) {
  //       print("Invoice sent successfully. Rows affected: ${responseData["RowsAffected"]}");
  //     } else {
  //       print("Invoice sent successfully: ${response.body}");
  //     }
  //   } else {
  //     throw Exception("Failed to send invoice: ${response.body}");
  //   }
  // }

  /// its Workig With AppSheet
  // static Future<void> addInvoiceItem(Map<String, dynamic> itemData, String userId) async {
  //   try {
  //     print("Adding invoice item: ${jsonEncode(itemData)}");
  //
  //     final url = Uri.parse(
  //         "https://api.appsheet.com/api/v2/apps/$appId/tables/$invoiceItemTableName/Action");
  //
  //     final Map<String, dynamic> requestBody = {
  //       "Action": "Add",
  //       "Properties": {
  //         "Locale": "en-US",
  //       },
  //       "Rows": [
  //      {   ...itemData,
  //        //"userId": userId,
  //     }    ]
  //     };
  //
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         "Content-Type": "application/json",
  //         "ApplicationAccessKey": accessKey, // Use the same access key as addInvoice
  //       },
  //       body: jsonEncode(requestBody),
  //     );
  //
  //     print("Add Invoice Item Response: ${response.statusCode} - ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);
  //       if (responseData is Map && responseData.containsKey("RowsAffected")) {
  //         print("Invoice item sent successfully. Rows affected: ${responseData["RowsAffected"]}");
  //       } else {
  //         print("Invoice item sent successfully: ${response.body}");
  //       }
  //     } else {
  //       throw Exception("Failed to add invoice item: ${response.statusCode} - ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Error adding invoice item: $e");
  //     rethrow;
  //   }
  // }


  /// its Workig With AppSheet
  // static Future<void> addChallan(dynamic challanData, String userId) async {
  //   checkChallanTableStructure();
  //   try {
  //     print("=== STARTING ADD CHALLAN ===");
  //
  //     final url = Uri.parse(
  //         "https://api.appsheet.com/api/v2/apps/$appId/tables/$challanTableName/Action");
  //
  //     // Print the actual URL being called
  //     print("API URL: $url");
  //     print("App ID: $appId");
  //     print("Table Name: $challanTableName");
  //
  //     List<Map<String, dynamic>> rowsToSend = [];
  //
  //     if (challanData is Map<String, dynamic>) {
  //       if (challanData.containsKey('items') && challanData['items'] is List) {
  //         challanData['items'] = jsonEncode(challanData['items']);
  //       }
  //       rowsToSend.add({
  //         ...challanData,
  //         "userId": userId,
  //       });
  //     } else if (challanData is List<Challan>) {
  //       print("Processing as Challan object");
  //       rowsToSend = challanData.map((chal){
  //         return {
  //           ...chal.toMap(),
  //           "userId": userId,
  //         };
  //       }).toList();
  //     }
  //
  //     print("Rows to send: ${jsonEncode(rowsToSend)}");
  //
  //     final body = jsonEncode({
  //       "Action": "Add",
  //       // "Properties": {
  //       //   "Locale": "en-US",
  //       // },
  //       "Rows": rowsToSend,
  //     });
  //
  //     print("Sending to AppSheet: ${jsonEncode(body)}");
  //
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         "Content-Type": "application/json",
  //         "ApplicationAccessKey": accessKey,
  //       },
  //       body: body,
  //     );
  //
  //     print("=== RESPONSE ===");
  //     print("Status Code: ${response.statusCode}");
  //     print("Response Body: ${response.body}");
  //     print("Response Headers: ${response.headers}");
  //
  //     if (response.statusCode == 200) {
  //       if (response.body.isNotEmpty) {
  //         try {
  //           final responseData = jsonDecode(response.body);
  //           if (responseData is Map && responseData.containsKey("RowsAffected")) {
  //             print("Challan sent successfully. Rows affected: ${responseData["RowsAffected"]}");
  //           } else {
  //             print("Challan sent successfully: ${response.body}");
  //           }
  //         } catch (e) {
  //           print("⚠️ Could not decode response JSON: $e");
  //         }
  //       } else {
  //         print("✅ Challan added successfully (empty response body).");
  //       }
  //     }
  //
  //   } catch (e) {
  //     print("❌ ERROR in addChallan: $e");
  //     rethrow;
  //   }
  // }

  /// its Workig With AppSheet
  // static Future<void> addChallanItem(Map<String, dynamic> challanData, String userId) async {
  //
  //   try {
  //     print("Adding challan item: ${jsonEncode(challanData)}");
  //
  //     final url = Uri.parse(
  //         "https://api.appsheet.com/api/v2/apps/$appId/tables/$challanItemTableName/Action");
  //
  //     final Map<String, dynamic> requestBody = {
  //       "Action": "Add",
  //       "Properties": {
  //         "Locale": "en-US",
  //       },
  //       "Rows": [
  //         {
  //           ...challanData,
  //           //"userId": userId,
  //         }
  //       ]
  //     };
  //
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         "Content-Type": "application/json",
  //         "ApplicationAccessKey": accessKey,
  //       },
  //       body: jsonEncode(requestBody),
  //     );
  //
  //     print("Add Challan Item Response: ${response.statusCode} - ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       // ✅ ADD THIS CHECK FOR EMPTY RESPONSE
  //       if (response.body.isNotEmpty) {
  //         final responseData = jsonDecode(response.body);
  //         if (responseData is Map && responseData.containsKey("RowsAffected")) {
  //           print("Challan item sent successfully. Rows affected: ${responseData["RowsAffected"]}");
  //         } else {
  //           print("Challan item sent successfully: ${response.body}");
  //         }
  //       } else {
  //         // ✅ HANDLE EMPTY RESPONSE AS SUCCESS
  //         print("Challan item sent successfully. Empty response received.");
  //       }
  //     } else {
  //       throw Exception("Failed to add challan item: ${response.statusCode} - ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Error adding challan item: $e");
  //     rethrow;
  //   }
  // }

  /// its Workig With AppSheet
  // static Future<List<Challan>> getChallans() async {
  //   print("🔄 Fetching challans from AppSheet API...");
  //
  //   final url = Uri.parse(
  //       "https://api.appsheet.com/api/v2/apps/$appId/tables/$challanTableName/Action");
  //
  //   final Map<String, dynamic> requestBody = {
  //     "Action": "Find",
  //     "Properties": {
  //       "Locale": "en-US",
  //     }
  //   };
  //
  //   print("Challan request body: ${jsonEncode(requestBody)}");
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         "Content-Type": "application/json",
  //         "ApplicationAccessKey": accessKey,
  //       },
  //       body: jsonEncode(requestBody),
  //     );
  //
  //     print("Challan response status: ${response.statusCode}");
  //
  //     if (response.statusCode == 200) {
  //       // Check for empty response
  //       if (response.body.trim().isEmpty || response.body.trim() == "[]") {
  //         print("Challan method returned empty data");
  //         return <Challan>[];
  //       }
  //
  //       dynamic data;
  //       try {
  //         data = jsonDecode(response.body);
  //         print("Challan parsed data type: ${data.runtimeType}");
  //       } catch (jsonError) {
  //         print("Challan JSON decode error: $jsonError");
  //         print("Raw response: ${response.body}");
  //         return <Challan>[];
  //       }
  //
  //       List<dynamic> challanData = [];
  //
  //       // Handle different response structures
  //       if (data is List) {
  //         challanData = data;
  //         print("Direct list with ${challanData.length} challans");
  //       } else if (data is Map) {
  //         if (data.containsKey("Rows")) {
  //           challanData = data["Rows"] ?? [];
  //           print("Map with Rows: ${challanData.length} challans");
  //         } else if (data.containsKey("Records")) {
  //           challanData = data["Records"] ?? [];
  //           print("Map with Records: ${challanData.length} challans");
  //         } else if (data.containsKey("data")) {
  //           challanData = data["data"] ?? [];
  //           print("Map with data: ${challanData.length} challans");
  //         } else {
  //           print("Unknown map structure: ${data.keys}");
  //           // Try to extract any list-like values
  //           var listKeys = data.keys.where((key) => data[key] is List).toList();
  //           if (listKeys.isNotEmpty) {
  //             challanData = data[listKeys.first] ?? [];
  //             print("Using first list key '${listKeys.first}': ${challanData.length} items");
  //           } else {
  //             // If it's a single record, wrap it in a list
  //             challanData = [data];
  //             print("Wrapping single record in list");
  //           }
  //         }
  //       } else {
  //         print("Unexpected data type: ${data.runtimeType}");
  //         return <Challan>[];
  //       }
  //
  //       // Handle empty data
  //       if (challanData.isEmpty) {
  //         print("No challan data found in response");
  //         return <Challan>[];
  //       }
  //
  //       // Convert to Challan objects with enhanced error handling
  //       List<Challan> challans = [];
  //       for (int i = 0; i < challanData.length; i++) {
  //         try {
  //           var item = challanData[i];
  //
  //           if (item is Map<String, dynamic>) {
  //             print("Processing challan $i: $item");
  //             Challan challan = Challan.fromJson(item);
  //             challans.add(challan);
  //           } else if (item is Map) {
  //             // Convert dynamic map to String key map
  //             var convertedMap = Map<String, dynamic>.from(item);
  //             print("Processing challan $i: $convertedMap");
  //             Challan challan = Challan.fromJson(convertedMap);
  //             challans.add(challan);
  //           } else {
  //             print("Skipping invalid challan data at index $i: ${item.runtimeType}");
  //             print("Problematic item: $item");
  //           }
  //         } catch (e) {
  //           print("Error parsing challan item $i: $e");
  //           print("Problematic item: ${challanData[i]}");
  //           // Continue with other items instead of failing completely
  //           continue;
  //         }
  //       }
  //
  //       print("Successfully parsed ${challans.length} challans");
  //       return challans;
  //
  //     } else {
  //       print("Challan HTTP error: ${response.statusCode}");
  //       print("Error response: ${response.body}");
  //       throw Exception('Failed to load challans: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print("Error in getChallans(): $e");
  //     rethrow;
  //   }
  // }

  /// its Workig With AppSheet
  // static Future<List<ChallanItem>> getChallanItemsByChallanId(String challanId) async {
  //   try {
  //     print("Fetching challan items for challan: $challanId");
  //
  //     final Map<String, dynamic> requestBody = {
  //       "Action": "Find",
  //       "Properties": {
  //         "Locale": "en-US",
  //       },
  //       "Filters": [
  //         ["challanId", "equals", challanId] // FIX: Changed "invoiceId" to "challanId"
  //       ]
  //     };
  //
  //     final response = await http.post(
  //       Uri.parse('https://api.appsheet.com/api/v2/apps/$appId/tables/$challanItemTableName/Action'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'ApplicationAccessKey': accessKey,
  //       },
  //       body: jsonEncode(requestBody),
  //     );
  //
  //     print("Challan Items Response: ${response.statusCode} - ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final dynamic responseData = jsonDecode(response.body);
  //
  //       // FIX: AppSheet returns a Map, not a List directly
  //       List<dynamic> itemsData = [];
  //
  //       if (responseData is Map<String, dynamic>) {
  //         // Check if response has 'data' field (common in AppSheet)
  //         if (responseData.containsKey('data')) {
  //           itemsData = responseData['data'] ?? [];
  //         } else {
  //           // If no 'data' field, try to use the response as list
  //           itemsData = responseData.values.toList();
  //         }
  //       } else if (responseData is List) {
  //         itemsData = responseData;
  //       }
  //
  //       print("API returned ${itemsData.length} items total");
  //
  //       // No need for additional filtering - the API filter should handle it
  //       return itemsData.map((item) {
  //         if (item is Map<String, dynamic>) {
  //           return ChallanItem.fromJson(item);
  //         } else {
  //           print("Invalid item format: $item");
  //           return ChallanItem.fromJson({}); // Return empty item
  //         }
  //       }).toList();
  //     } else {
  //       throw Exception('Failed to fetch challan items: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print("Error fetching Challan items: $e");
  //     rethrow;
  //   }
  // }

  ///
  static Future<List<InvoiceItem>> getInvoiceItemsByInvoiceId(String invoiceId) async {
    try {
      print("Fetching invoice items for invoice: $invoiceId");

      final Map<String, dynamic> requestBody = {
        "Action": "Find",
        "Properties": {
          "Locale": "en-US",
        },
        "Filters": [
          ["invoiceId", "equals", invoiceId]
        ]
      };

      final response = await http.post(
        Uri.parse('https://api.appsheet.com/api/v2/apps/$appId/tables/InvoiceItems/Action'),
        headers: {
          'Content-Type': 'application/json',
          'ApplicationAccessKey': accessKey,
        },
        body: jsonEncode(requestBody),
      );

      print("Invoice Items Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        print("API returned ${responseData.length} items total");

        // FILTER ITEMS BY INVOICE ID - THIS IS THE KEY FIX!
        final List<dynamic> filteredItems = responseData.where((item) {
          if (item is Map<String, dynamic>) {
            return item['invoiceId'] == invoiceId;
          }
          return false;
        }).toList();

        print("Found ${filteredItems.length} items for invoice $invoiceId");

        return filteredItems.map((item) {
          if (item is Map<String, dynamic>) {
            return InvoiceItem.fromJson(item);
          } else {
            throw Exception('Invalid item format: $item');
          }
        }).toList();
      } else {
        throw Exception('Failed to fetch invoice items: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching invoice items: $e");
      rethrow;
    }
  }



  /// In your ApiService class
  static Future<List<Challan>> getChallansByDateRange({
    required DateTime fromDate,
    required DateTime toDate,
    required String userId,
  }) async {
    try {
      // First get all challans for this user
      final filterString = '[UserId] = "$userId",---- fromDate- :$fromDate, ----toDAte : $toDate ';
      print("-------------Filter String: $filterString");

      final requestBody = {
        "Action": "Find",
        "Properties": {
          "Locale": "en-US"
        },
        "Filters": [
          {
            "Filter": filterString
          }
        ]
      };

      final response = await http.post(
        Uri.parse('https://api.appsheet.com/api/v2/apps/$appId/tables/$challanTableName/Action'),
        headers: {
          'Content-Type': 'application/json',
          'ApplicationAccessKey': accessKey,
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        List<dynamic> rows;

        if (decodedData is List) {
          rows = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('Rows')) {
          rows = decodedData['Rows'] ?? [];
        } else {
          rows = [];
        }

        // Filter locally by date
        final filteredRows = rows.where((challan) {
          try {
            // Parse the date string from AppSheet (MM/dd/yyyy format)
            final dateStr = challan['challanDate'] as String;
            final dateParts = dateStr.split('/');
            final month = int.parse(dateParts[0]);
            final day = int.parse(dateParts[1]);
            final year = int.parse(dateParts[2]);
            final challanDate = DateTime(year, month, day);

            // Check if date is within range
            return challanDate.isAfter(fromDate.subtract(Duration(days: 1))) &&
                challanDate.isBefore(toDate.add(Duration(days: 1)));
          } catch (e) {
            return false;
          }
        }).toList();

        print("-------------Filtered Rows: ${filteredRows.length}");
        return filteredRows.map((json) => Challan.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load challans: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load challans: $e');
    }
  }

  ///  In your ApiService class
  static Future<List<Challan>> getChallansWithItemsByCustomer(String customerName) async {
    try {
      // First get all challans for this customer
      List<Challan> customerChallans = await GoogleSheetService.getChallansByDateRange(
        fromDate: DateTime.now().subtract(Duration(days: 365)), // wider date range
        toDate: DateTime.now(),
        userId: AppConstants.userId,
      );

      // Filter by customer name
      customerChallans = customerChallans.where((challan) =>
      challan.customerName == customerName).toList();

      print("Processing ${customerChallans.length} challans for $customerName to fetch items...");

      // For each challan, fetch its items
      for (int i = 0; i < customerChallans.length; i++) {
        print("Fetching items for challan ${i + 1}/${customerChallans.length}: ${customerChallans[i].challanId}");

        List<ChallanItem> items = await GoogleSheetService.getChallanItemsByChallanId(customerChallans[i].challanId);

        // Update the challan with items
        customerChallans[i] = customerChallans[i].copyWith(items: items);

        print("Added ${items.length} items to challan ${customerChallans[i].challanId}");
      }

      return customerChallans;
    } catch (e) {
      print('Error fetching challans with items for customer $customerName: $e');
      return [];
    }
  }




  ///unUsed Api
  ///
  ///
  ///

  /// In RemoteService
  // static Future<List<Challan>> getChallansWithItems() async {
  //   try {
  //     // First get all challans
  //     List<Challan> challans = await getChallansByDateRange(
  //       fromDate: DateTime.now().subtract(Duration(days: 30)),
  //       toDate: DateTime.now(),
  //       userId: AppConstants.userId,
  //     );
  //
  //     print("Processing ${challans.length} challans to fetch items...");
  //
  //     // For each challan, fetch its items from ChallanItems table
  //     for (int i = 0; i < challans.length; i++) {
  //       print("Fetching items for challan ${i + 1}/${challans.length}: ${challans[i].challanId}");
  //
  //       List<ChallanItem> items = await getChallanItemsByChallanId(challans[i].challanId);
  //
  //       // Update the challan with items
  //       challans[i] = challans[i].copyWith(items: items);
  //
  //       print("Added ${items.length} items to challan ${challans[i].challanId}");
  //     }
  //
  //     return challans;
  //   } catch (e) {
  //     print('Error fetching challans with items: $e');
  //     return [];
  //   }
  // }

  /// Alternative 3: Delete and Add (as last resort)
  static Future<void> editItemAlternative3(String userId, Item item) async {
    print("=== TRYING ALTERNATIVE 3: DELETE AND ADD ===");

    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action");

    // Step 1: Delete the existing item
    final deleteBody = jsonEncode({
      "Action": "Delete",
      "Rows": [
        {"itemId": item.itemId}
      ],
    });

    print("Delete request: $deleteBody");

    final deleteResponse = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "ApplicationAccessKey": accessKey,
      },
      body: deleteBody,
    );

    print("Delete response: ${deleteResponse.statusCode} - ${deleteResponse.body}");

    if (deleteResponse.statusCode != 200) {
      throw Exception("Failed to delete item: ${deleteResponse.body}");
    }

    // Step 2: Add the updated item
    await Future.delayed(Duration(seconds: 1)); // Small delay

    final addBody = jsonEncode({
      "Action": "Add",
      "Rows": [
        {
          "itemId": item.itemId,
          "itemName": item.itemName,
          "price": item.price,
          "unitOfMeasurement": item.unitOfMeasurement,
          "currentStock": item.currentStock,
          "detailRequirement": item.detailRequirement ?? "",
          "isActive": item.isActive,
          "userId": userId,
        }
      ],
    });

    print("Add request: $addBody");

    final addResponse = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "ApplicationAccessKey": accessKey,
      },
      body: addBody,
    );

    print("Add response: ${addResponse.statusCode} - ${addResponse.body}");

    if (addResponse.statusCode != 200) {
      throw Exception("Failed to re-add item: ${addResponse.body}");
    }
  }

  static Future<void> deleteInvoiceItems(String invoiceId) async {
    try {
      // First get all items for this invoice
      List<InvoiceItem> items = await getInvoiceItemsByInvoiceId(invoiceId);

      String url = 'https://api.appsheet.com/api/v2/apps/$appId/tables/$invoiceItemTableName/Action';

      // Delete each item (you might need to adjust this based on your AppSheet setup)
      for (var item in items) {
        Map<String, dynamic> requestBody = {
          "Action": "Delete",
          "Properties": {},
          "Rows": [
            {
              "invoiceId": invoiceId,
              "itemId": item.itemId,
            }
          ]
        };

        await http.post(
          Uri.parse(url),
          headers: {
            'ApplicationAccessKey': accessKey,
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );
      }

      print("Deleted ${items.length} invoice items for invoice $invoiceId");
    } catch (e) {
      print('Error deleting invoice items: $e');
      throw Exception('Failed to delete invoice items: $e');
    }
  }

  static Future<void> listAllChallans() async {
    try {
      print("=== LISTING ALL CHALLANS ===");

      final url = Uri.parse(
          "https://api.appsheet.com/api/v2/apps/$appId/tables/$challanTableName/Action");

      final body = jsonEncode({
        "Action": "Find",
        "Properties": {
          "Locale": "en-US",
        },
        "Rows": [] // Empty to get all rows
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: body,
      );

      print("List all challans response: ${response.statusCode} - ${response.body}");
    } catch (e) {
      print("Error in listAllChallans: $e");
    }
  }

  static Future<List<Invoice>> fetchInvoices() async {
    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$invoiceTableName/Action");

    final body = jsonEncode({
      "Action": "Find",
      "Properties": {
        "Locale": "en-US",
        "Selector": 'Sort([{ColumnName: "date", Ascending: false}])',
      }
    });

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "ApplicationAccessKey": accessKey,
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey("Rows")) {
        final rows = data["Rows"] as List;
        return rows.map((e) => Invoice.fromMap(e)).toList();
      } else {
        throw Exception("Invalid response format: ${response.body}");
      }
    } else {
      throw Exception("Failed to load invoices: ${response.body}");
    }
  }

  /// Method 3: Try different AppSheet API approach
  static Future<List<Item>> getItemsAlternative(String userId) async {
    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action");

    // Try different Action types
    final actions = ["Find", "Read"];

    for (String action in actions) {
      print("=== TRYING ACTION: $action ===");

      final body = jsonEncode({
        "Action": action,
        "Properties": {
          "Locale": "en-US",
          "Selector": 'Filter([userId] = "$userId")',
        }
      });

      try {
        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "ApplicationAccessKey": accessKey,
          },
          body: body,
        );

        print("$action Response: ${response.statusCode} - ${response.body}");

        if (response.statusCode == 200 &&
            response.body.trim().isNotEmpty &&
            response.body.trim() != "[]") {

          final data = jsonDecode(response.body);

          if (data is List && data.isNotEmpty) {
            print("Success with $action! Found ${data.length} items");
            return data.map((e) => Item.fromMap(e as Map<String, dynamic>)).toList();
          }
        }
      } catch (e) {
        print("Error with $action: $e");
      }
    }

    print("All alternative methods failed, falling back to manual filter");
    return await getAllAndFilterManually(userId);
  }

  /// Method 1: Force AppSheet to sync before filtering
  static Future<List<Item>> getItems({String? userId}) async {
    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action");

    // First, let's try without any selector to see if we can get data
    Map<String, dynamic> requestBody = {
      "Action": "Find",
      "Properties": {
        "Locale": "en-US",
      }
    };

    // Only add selector if we have a userId
    if (userId != null && userId.isNotEmpty) {
      // Try the exact format that should work
      requestBody["Properties"]["Selector"] = 'Filter([userId] = "$userId")';
    }

    final body = jsonEncode(requestBody);
    print("Request body: $body");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: body,
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: '${response.body}'");
      print("Response Body Length: ${response.body.length}");

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty || response.body.trim() == "[]") {
          print("Empty response received");
          return <Item>[];
        }

        dynamic data;
        try {
          data = jsonDecode(response.body);
          print("Parsed data: $data");
        } catch (jsonError) {
          print("JSON decode error: $jsonError");
          throw Exception("Failed to parse response: $jsonError");
        }

        List<dynamic> itemsData = [];

        if (data is List) {
          itemsData = data;
          print("Direct list with ${itemsData.length} items");
        } else if (data is Map) {
          if (data.containsKey("Rows")) {
            itemsData = data["Rows"];
            print("Map with Rows: ${itemsData.length} items");
          } else if (data.containsKey("Records")) {
            itemsData = data["Records"];
            print("Map with Records: ${itemsData.length} items");
          } else {
            print("Unknown map structure: ${data.keys}");
          }
        }

        // If we have userId but no filtered results, get all and filter manually
        if (userId != null && userId.isNotEmpty && itemsData.isEmpty) {
          print("No filtered results, trying to get all data and filter manually...");
          return await getAllAndFilterManually(userId);
        }

        return itemsData.map((e) => Item.fromMap(e as Map<String, dynamic>)).toList();

      } else {
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Error in getItems: $e");
      rethrow;
    }
  }

  /// Method 2: Get all data and filter manually (fallback)
  static Future<List<Item>> getAllAndFilterManually(String userId) async {
    print("=== MANUAL FILTERING FALLBACK ===");

    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action");

    final body = jsonEncode({
      "Action": "Find",
      "Properties": {
        "Locale": "en-US",
        // No selector - get all data
      }
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: body,
      );

      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final data = jsonDecode(response.body);

        List<dynamic> allItems = [];
        if (data is List) {
          allItems = data;
        } else if (data is Map && data.containsKey("Rows")) {
          allItems = data["Rows"];
        }

        print("Got ${allItems.length} total items, filtering for userId: $userId");

        // Filter manually
        final filteredItems = allItems.where((item) {
          final map = item as Map<String, dynamic>;
          final itemUserId = map['userId']?.toString() ?? '';
          print("Checking item userId: '$itemUserId' vs target: '$userId'");
          return itemUserId == userId;
        }).toList();

        print("Manual filter found ${filteredItems.length} matching items");

        return filteredItems.map((e) => Item.fromMap(e as Map<String, dynamic>)).toList();
      }

      return <Item>[];
    } catch (e) {
      print("Error in manual filtering: $e");
      return <Item>[];
    }
  }

  static Future<List<ChallanItem>> getChallanItems(String challanId) async {
    try {
      final Map<String, dynamic> requestBody = {
        "Action": "Find",
        "Properties": {
          "Locale": "en-US",
        },
        "Rows": [
          {
            "ChallanId": challanId // Filter by challanId
          }
        ]
      };

      final response = await http.post(
        Uri.parse('https://api.appsheet.com/api/v2/apps/$appId/tables/ChallanItems/Action'),
        headers: {
          'Content-Type': 'application/json',
          'ApplicationAccessKey': accessKey, // Add your AppSheet access key
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];

        print("Found ${data.length} items for challan $challanId");

        return data.map((item) => ChallanItem.fromJson(item)).toList();
      } else {
        print("Failed to load challan items. Status: ${response.statusCode}");
        throw Exception('Failed to load challan items');
      }
    } catch (e) {
      print('Error fetching challan items: $e');
      return [];
    }
  }

  /// Get all items from Items table with enhanced fields
  static Future<List<Item>> getItemsoldwork() async {
    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action");

    final body = jsonEncode({
      "Action": "Find",
      "Properties": {
        "Locale": "en-US",
        "Selector": 'Filter(1=1)', // Get all items
        "SelectColumns": [
          "itemId",
          "itemName",
          "price",
          "unitOfMeasurement",
          "currentStock",
          "detailRequirement",
          "isActive"
        ]
      }
    });

    print("Fetching items with request: $body");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "ApplicationAccessKey": accessKey,
      },
      body: body,
    );

    print("Get Items Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data.map((e) => Item.fromMap(e)).toList();
      } else if (data is Map && data["Rows"] is List) {
        final rows = data["Rows"] as List;
        return rows.map((e) => Item.fromMap(e)).toList();
      } else {
        throw Exception("Invalid response format: ${response.body}");
      }
    } else {
      throw Exception("Failed to load items: ${response.body}");
    }
  }

  static Future<List<Item>> getItems1() async {
    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action");

    final body = jsonEncode({
      "Action": "Find",
      "Properties": {
        "Locale": "en-US",
        "Selector": 'Filter([userId] = "${AppConstants.userId}")'
        //"Selector": 'Filter(1=1)' , // Get just one specific item
       // "Selector": "Filter([itemId] = '1756881063842')",
        // "Selector": 'Filter(1=1)', // Get all items
        // "SelectColumns": [
        //   "itemId",
        //   "itemName",
        //   "price",
        //   "unitOfMeasurement",
        //   "currentStock",
        //   "detailRequirement",
        //   "isActive"
        // ]
      }
    });

    print("Fetching items with request: $body");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: body,
      );

      print("Get Items Response: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print("Response Body Length: ${response.body.length}");
      print("Response Body: '${response.body}'"); // Added quotes to see exact content

      if (response.statusCode == 200) {
        // Check if response body is empty or just whitespace

        print("------=-=:${response.body.trim().isEmpty}");
        if (response.body.trim().isEmpty) {
          print("Warning: Response body is empty, returning empty list");
          return <Item>[];
        }

        dynamic data;
        try {
          data = jsonDecode(response.body);
          print("dattta:------------${data}");
        } catch (jsonError) {
          print("JSON Decode Error: $jsonError");
          print("Raw response body: ${response.body.codeUnits}"); // Show as code units for debugging
          throw Exception("Failed to parse JSON response: $jsonError");
        }

        print("Parsed data type: ${data.runtimeType}");
        print("Parsed data: $data");

        if (data is List) {
          print("Processing data as direct list with ${data.length} items");
          return data.map((e) {
            print("Processing item: $e");
            return Item.fromMap(e as Map<String, dynamic>);
          }).toList();
        }
        else if (data is Map && data["Rows"] is List) {
          final rows = data["Rows"] as List;
          print("Processing data as map with Rows containing ${rows.length} items");
          return rows.map((e) {
            print("Processing row: $e");
            return Item.fromMap(e as Map<String, dynamic>);
          }).toList();
        }
        else if (data is Map && data.isEmpty) {
          print("Received empty map, returning empty list");
          return <Item>[];
        }
        else {
          print("Unexpected data structure received");
          print("Data keys: ${data is Map ? data.keys.toList() : 'Not a map'}");
          throw Exception("Invalid response format. Expected List or Map with 'Rows', got: ${data.runtimeType}");
        }
      }
      else {
        print("HTTP Error: ${response.statusCode}");
        print("Error response: ${response.body}");
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Network or processing error: $e");
      rethrow;
    }
  }


  String? getCurrentUserId() {
    // DEBUG: Print what you're returning
    String? userId = "your_actual_user_id"; // Replace with your actual method

    print("getCurrentUserId() returning: '$userId'");
    return userId;
  }

  /// Optional: Add method to get user-specific items
  static Future<List<Item>> getUserItems(String userId) async {
    print("=== DEBUG getUserItems ===");
    print("UserId: $userId");
    print("AppId: $appId");
    print("Table Name: $itemsTableName");
    print("Access Key: ${accessKey.substring(0, 10)}...");

    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action"
    );

    print("API URL: $url");

    // Try different approaches based on your AppSheet setup
    final body = jsonEncode({
      "Action": "Find",
      "Properties": {
    "Locale": "en-US"
        // Option 1: If using security filters
        //"Selector": "SELECT($itemsTableName[userId], [userId] = '$userId')",

        // Option 2: Alternative selector (uncomment if option 1 doesn't work)
         //"Selector": "Filter($itemsTableName, [userId] = '$userId')",

        // Option 3: If you want all columns (uncomment if needed)
        // "Selector": "SELECT($itemsTableName[*], [userId] = '$userId')",
      },
    });

    print("Request Body: $body");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: body,
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Parsed Response Data: $responseData");

        // Check different possible response structures
        List<dynamic> rows = [];

        if (responseData is List) {
          rows = responseData;
        } else if (responseData is Map) {
          rows = responseData['Rows'] ??
              responseData['rows'] ??
              responseData['data'] ??
              responseData['result'] ?? [];
        }

        print("Extracted Rows: $rows");
        print("Number of rows: ${rows.length}");

        if (rows.isEmpty) {
          print("WARNING: No rows found for userId: $userId");

          // Let's also try to get ALL items to see what's in the table
          await debugGetAllItems();
        }

        List<Item> items = [];
        for (var row in rows) {
          try {
            print("Processing row: $row");
            Item item = Item.fromMap(row);
            items.add(item);
          } catch (e) {
            print("Error parsing row $row: $e");
          }
        }

        print("Successfully parsed ${items.length} items");
        return items;
      } else {
        print("ERROR: HTTP ${response.statusCode}");
        print("Error Body: ${response.body}");
        throw Exception("Failed to fetch items: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("EXCEPTION in getUserItems: $e");
      rethrow;
    }
  }

  /// Debug method to get all items (for testing)
  static Future<void> debugGetAllItems() async {
    print("=== DEBUG: Fetching ALL items ===");

    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action"
    );

    final body = jsonEncode({
      "Action": "Find",
      "Properties": {
        "Selector": "SELECT($itemsTableName[*])",
      },
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("ALL ITEMS in table: $responseData");
      } else {
        print("Failed to fetch all items: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error fetching all items: $e");
    }
  }

// Alternative approach using different API pattern
  static Future<List<Item>> getUserItemsAlternative(String userId) async {
    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action"
    );

    // Try the Read action instead of Find
    final body = jsonEncode({
      "Action": "Read",
      "Properties": {
        "Locale": "en-US",
        "Timezone": "Pacific Standard Time"
      },
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Read All Response: $responseData");

        // Filter on client side
        List<dynamic> rows = responseData is List ? responseData : (responseData['Rows'] ?? []);
        List<dynamic> filteredRows = rows.where((row) => row['userId'] == userId).toList();

        return filteredRows.map((row) => Item.fromMap(row)).toList();
      } else {
        throw Exception("Failed to fetch items: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in alternative method: $e");
      return [];
    }
  }

  static Future<void> addSingleInvoice(Map<String, dynamic> invoiceRow) async {
    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/Invoice/Action");
    final body = jsonEncode({
      "Action": "Add",
      "Rows": [invoiceRow],
    });

    final response = await http.post(
      url,
      headers: {
        "ApplicationAccessKey": accessKey,
        "Content-Type": "application/json",
      },
      body: body,
    );

    print("AppSheet Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to send invoice: ${response.body}");
    }
  }

  /// Update only stock for an item
  static Future<void> updateItemStock(String itemId, int newStock) async {
    final url = Uri.parse(
      "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action",
    );

    final body = jsonEncode({
      "Action": "Edit",
      "Rows": [
        {
          "itemId": itemId,
          "currentStock": newStock,
        }
      ]
    });

    print("Updating stock for item $itemId to $newStock");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "ApplicationAccessKey": accessKey,
      },
      body: body,
    );

    print("Update Stock Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to update stock: ${response.body}");
    }
  }

  /// Delete item (set as inactive)
  static Future<void> deleteItem(String itemId) async {
    final url = Uri.parse(
      "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action",
    );

    final body = jsonEncode({
      "Action": "Edit",
      "Rows": [
        {
          "itemId": itemId,
          "isActive": 0, // Set as inactive instead of deleting
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "ApplicationAccessKey": accessKey,
      },
      body: body,
    );

    print("Delete Item Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to delete item: ${response.body}");
    }
  }

  /// Check if item table structure is correct for enhanced fields
  static Future<void> checkItemTableStructure() async {
    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action");

    final body = jsonEncode({
      "Action": "Find",
      "Properties": {
        "Locale": "en-US",
        "Selector": 'Filter(1=1)',
        "SelectColumns": [
          "itemId",
          "itemName",
          "price",
          "unitOfMeasurement",
          "currentStock",
          "detailRequirement",
          "isActive"
        ]
      }
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: body,
      );

      print("Item Table Structure Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode != 200) {
        print("Warning: Item table may not have all required columns");
        print("Expected columns: itemId, itemName, price, unitOfMeasurement, currentStock, detailRequirement, isActive");
      }
    } catch (e) {
      print("Error checking item table structure: $e");
    }
  }
}



class GoogleSheetService {
  // Always use current value so after login we use the right sheet
  static String get spreadsheetId => AppConstants.spreadsheetId;
  static const itemSheetName = "Item"; // your sheet/tab name
  static const invoiceSheetName = "Invoice"; // your sheet/tab name
  static const invoiceItemSheetName = "InvoiceItems"; // your sheet/tab name
  static const challanSheetName = "Challan"; // your sheet/tab name
  static const challanItemSheetName = "ChallanItems"; // your sheet/tab name
  static const inventoryTransactionSheetName = "InventoryTransactions"; // Create this sheet in Google Sheets

  static const purchaseSheetName = "Purchase";
  static const purchaseItemSheetName = "PurchaseItems";
  static const customerSheetName = "Customer";

  /// Company logo URL per company (store in sheet - Firebase free plan)
  static const companyLogoSheetName = "CompanyLogo";

  static List<String>? _cachedHeaders;
  static final Map<String, List<ChallanItem>> _challanCache = {};
  static final Map<String, List<InvoiceItem>> _invoiceItemCache = {};
  static final Map<String, List<PurchaseItem>> _purchaseItemCache = {};

  // Cache sheet titles to avoid frequent spreadsheets.get (quota heavy).
  static String? _sheetTitlesForSpreadsheetId;
  static Set<String> _cachedSheetTitles = <String>{};
  static DateTime? _sheetTitlesFetchedAt;
  static const Duration _sheetTitlesCacheDuration = Duration(minutes: 10);

  static final Map<String, List<dynamic>> _itemCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static final Map<String, List<Invoice>> _invoiceListCache = {};
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  static const Duration _invoiceListCacheDuration = Duration(minutes: 2);

  /// True when error is "Project #XXX has been deleted" (GCP project deleted, SA key invalid).
  static bool isProjectDeletedError(Object e) {
    final msg = e.toString();
    return msg.contains('403') && msg.contains('has been deleted');
  }

  /// User message when Service Account's Google Cloud project was deleted.
  static String get projectDeletedUserMessage =>
      'Google Cloud project was deleted. Create new project, new Service Account key, replace assets JSON. See docs/SERVICE_ACCOUNT_DELETED_PROJECT_FIX.md';

  /// Create a new Google Sheet: with [accessToken] = in user's Drive (folder InvoiceSathi); with [userEmail] only = Service Account creates and shares with user (email/password flow).
  /// Returns (spreadsheetId, folderId) on success. folderId empty for email/password flow.
  static Future<(String spreadsheetId, String folderId)?> createNewUserSpreadsheet(
    String uid, {
    String? accessToken,
    String? username,
    String? existingFolderId,
    String? userEmail,
  }) async {
    // Email/password flow: Service Account creates sheet and shares with user's email
    if ((accessToken == null || accessToken.isEmpty) && userEmail != null && userEmail.trim().isNotEmpty) {
      return await _createSheetWithServiceAccountAndShare(uid, userEmail.trim(), username ?? 'user');
    }
    if (accessToken == null || accessToken.isEmpty) return null;
    try {
      final baseUrl = 'https://www.googleapis.com/drive/v3/files';
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      String? folderId;
      const folderName = 'InvoiceSathi';

      if (existingFolderId != null && existingFolderId.isNotEmpty) {
        folderId = existingFolderId;
      } else {
        final driveQuery = "name='$folderName' and mimeType='application/vnd.google-apps.folder' and 'root' in parents and trashed=false";
        final listUrl = Uri.parse('$baseUrl?q=${Uri.encodeComponent(driveQuery)}&fields=files(id,name)');
        final listRes = await http.get(listUrl, headers: headers);
        if (listRes.statusCode == 200) {
          final listData = jsonDecode(listRes.body) as Map<String, dynamic>;
          final files = listData['files'] as List<dynamic>?;
          if (files != null && files.isNotEmpty) {
            folderId = (files.first as Map<String, dynamic>)['id'] as String?;
          }
        }
        if (folderId == null || folderId.isEmpty) {
          final createFolderRes = await http.post(
            Uri.parse(baseUrl),
            headers: headers,
            body: jsonEncode({'name': folderName, 'mimeType': 'application/vnd.google-apps.folder'}),
          );
          if (createFolderRes.statusCode != 200) {
            print('❌ Drive API create folder failed: ${createFolderRes.statusCode} ${createFolderRes.body}');
            return null;
          }
          final folderData = jsonDecode(createFolderRes.body) as Map<String, dynamic>;
          folderId = folderData['id'] as String?;
          if (folderId == null || folderId.isEmpty) return null;
          print('✅ Created folder "$folderName" in user Drive: $folderId');
        }
      }

      final parentId = folderId!;
      final now = DateTime.now();
      final fyStart = now.month >= 4 ? now.year : now.year - 1;
      final fyEnd = fyStart + 1;
      final fyStr = '$fyStart-${fyEnd.toString().substring(2)}';
      final safeName = (username ?? 'user').replaceAll(RegExp(r'[^\w\-.]'), '_');
      final sheetName = '${safeName}_${uid}_$fyStr';

      final sheetBody = jsonEncode({
        'name': sheetName,
        'mimeType': 'application/vnd.google-apps.spreadsheet',
        'parents': [parentId],
      });
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: sheetBody,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final id = data['id'] as String?;
        if (id != null && id.isNotEmpty) {
          print('✅ Created spreadsheet "$sheetName" in folder $folderName: $id');
          try {
            final credStr = await _loadServiceAccountJson();
            final credJson = jsonDecode(credStr) as Map<String, dynamic>;
            final serviceAccountEmail = credJson['client_email'] as String?;
            if (serviceAccountEmail != null && serviceAccountEmail.isNotEmpty) {
              final permUrl = Uri.parse('https://www.googleapis.com/drive/v3/files/$id/permissions').replace(queryParameters: {'sendNotificationEmail': 'false'});
              final permRes = await http.post(
                permUrl,
                headers: headers,
                body: jsonEncode({
                  'type': 'user',
                  'role': 'writer',
                  'emailAddress': serviceAccountEmail,
                }),
              );
              if (permRes.statusCode >= 200 && permRes.statusCode < 300) {
                print('✅ Shared spreadsheet with Service Account');
              } else {
                print('⚠️ Could not share sheet with Service Account: ${permRes.statusCode} ${permRes.body}');
              }
            }
          } catch (shareErr) {
            print('⚠️ Share with Service Account failed: $shareErr');
          }
          return (id, parentId);
        }
      }
      print('❌ Drive API create sheet failed: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      print('❌ createNewUserSpreadsheet error: $e');
      return null;
    }
  }

  /// Share an existing spreadsheet with the Service Account so it can write Item, Customer, Invoice etc.
  static Future<bool> shareSpreadsheetWithServiceAccount(String spreadsheetId, String accessToken) async {
    try {
      final credStr = await _loadServiceAccountJson();
      final credJson = jsonDecode(credStr) as Map<String, dynamic>;
      final serviceAccountEmail = credJson['client_email'] as String?;
      if (serviceAccountEmail == null || serviceAccountEmail.isEmpty) return false;
      final permUrl = Uri.parse('https://www.googleapis.com/drive/v3/files/$spreadsheetId/permissions').replace(queryParameters: {'sendNotificationEmail': 'false'});
      final permRes = await http.post(
        permUrl,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': 'user',
          'role': 'writer',
          'emailAddress': serviceAccountEmail,
        }),
      );
      if (permRes.statusCode >= 200 && permRes.statusCode < 300) {
        print('✅ Shared existing spreadsheet with Service Account');
        return true;
      }
      print('⚠️ Share existing sheet failed: ${permRes.statusCode} ${permRes.body}');
      return false;
    } catch (e) {
      print('⚠️ shareSpreadsheetWithServiceAccount: $e');
      return false;
    }
  }

  /// Email/password flow: Service Account creates spreadsheet and shares with user's email.
  static Future<(String spreadsheetId, String folderId)?> _createSheetWithServiceAccountAndShare(String uid, String userEmail, String username) async {
    try {
      final client = await _getAuthClientWithDrive();
      final sheetsApi = SheetsApi(client);
      final now = DateTime.now();
      final fyStart = now.month >= 4 ? now.year : now.year - 1;
      final fyEnd = fyStart + 1;
      final fyStr = '$fyStart-${fyEnd.toString().substring(2)}';
      final safeName = username.replaceAll(RegExp(r'[^\w\-.]'), '_');
      final title = 'Invoice Sathi - ${safeName}_${uid}_$fyStr';
      final request = Spreadsheet()
        ..properties = (SpreadsheetProperties()..title = title);
      final spreadsheet = await sheetsApi.spreadsheets.create(request);
      final id = spreadsheet.spreadsheetId;
      if (id == null || id.isEmpty) return null;
      print('✅ Created spreadsheet via Service Account: $id');
      final driveApi = drive.DriveApi(client);
      await driveApi.permissions.create(
        drive.Permission()
          ..type = 'user'
          ..role = 'writer'
          ..emailAddress = userEmail,
        id,
        sendNotificationEmail: false,
      );
      print('✅ Shared spreadsheet with $userEmail');
      return (id, '');
    } catch (e) {
      print('❌ _createSheetWithServiceAccountAndShare: $e');
      return null;
    }
  }

  /// Create a new Google Spreadsheet for a specific financial year (separate sheet per FY).
  /// When [accessToken] is provided (e.g. from Google Sign-In), creates in user's Drive (same as first sheet) to avoid 403.
  /// When [accessToken] is null, uses Service Account (requires Drive API enabled in Cloud Console).
  /// Returns (spreadsheetId, folderId) on success. Caller should then ensureSheetsExist() and save to Firestore.
  static Future<(String spreadsheetId, String folderId)?> createNewSpreadsheetForFy(
    String uid,
    String userEmail,
    String username, {
    required String fy,
    String? accessToken,
  }) async {
    // Same path as first sheet: create in user's Drive with their token (no 403)
    if (accessToken != null && accessToken.trim().isNotEmpty) {
      final result = await _createFySheetInUserDrive(uid, username, fy, accessToken);
      if (result != null) return result;
      print('❌ createNewSpreadsheetForFy (Drive API) failed, falling back to Service Account');
    }
    // Email/password or token failed: Service Account creates and shares with user
    try {
      final client = await _getAuthClientWithDrive();
      final sheetsApi = SheetsApi(client);
      final safeName = username.replaceAll(RegExp(r'[^\w\-.]'), '_');
      final title = 'Invoice Sathi - ${safeName}_${uid}_$fy';
      final request = Spreadsheet()
        ..properties = (SpreadsheetProperties()..title = title);
      final spreadsheet = await sheetsApi.spreadsheets.create(request);
      final id = spreadsheet.spreadsheetId;
      if (id == null || id.isEmpty) return null;
      print('✅ Created FY spreadsheet "$title": $id');
      final driveApi = drive.DriveApi(client);
      await driveApi.permissions.create(
        drive.Permission()
          ..type = 'user'
          ..role = 'writer'
          ..emailAddress = userEmail,
        id,
        sendNotificationEmail: false,
      );
      print('✅ Shared FY spreadsheet with $userEmail');
      return (id, '');
    } catch (e) {
      print('❌ createNewSpreadsheetForFy: $e');
      return null;
    }
  }

  /// Create FY sheet in user's Drive using their access token (same flow as first sheet).
  static Future<(String spreadsheetId, String folderId)?> _createFySheetInUserDrive(String uid, String username, String fy, String accessToken) async {
    try {
      final baseUrl = 'https://www.googleapis.com/drive/v3/files';
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
      const folderName = 'InvoiceSathi';
      String? folderId;
      final driveQuery = "name='$folderName' and mimeType='application/vnd.google-apps.folder' and 'root' in parents and trashed=false";
      final listUrl = Uri.parse('$baseUrl?q=${Uri.encodeComponent(driveQuery)}&fields=files(id,name)');
      final listRes = await http.get(listUrl, headers: headers);
      if (listRes.statusCode == 200) {
        final listData = jsonDecode(listRes.body) as Map<String, dynamic>;
        final files = listData['files'] as List<dynamic>?;
        if (files != null && files.isNotEmpty) {
          folderId = (files.first as Map<String, dynamic>)['id'] as String?;
        }
      }
      if (folderId == null || folderId.isEmpty) {
        final createFolderRes = await http.post(
          Uri.parse(baseUrl),
          headers: headers,
          body: jsonEncode({'name': folderName, 'mimeType': 'application/vnd.google-apps.folder'}),
        );
        if (createFolderRes.statusCode != 200) {
          print('❌ Drive API create folder failed: ${createFolderRes.statusCode} ${createFolderRes.body}');
          return null;
        }
        final folderData = jsonDecode(createFolderRes.body) as Map<String, dynamic>;
        folderId = folderData['id'] as String?;
        if (folderId == null || folderId.isEmpty) return null;
        print('✅ Created folder "$folderName" in user Drive: $folderId');
      }
      final parentId = folderId!;
      final safeName = username.replaceAll(RegExp(r'[^\w\-.]'), '_');
      final sheetName = '${safeName}_${uid}_$fy';
      final sheetBody = jsonEncode({
        'name': sheetName,
        'mimeType': 'application/vnd.google-apps.spreadsheet',
        'parents': [parentId],
      });
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: sheetBody,
      );
      if (response.statusCode != 200) {
        print('❌ Drive API create FY sheet failed: ${response.statusCode} ${response.body}');
        return null;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final id = data['id'] as String?;
      if (id == null || id.isEmpty) return null;
      print('✅ Created FY spreadsheet "$sheetName" in folder $folderName: $id');
      try {
        final credStr = await _loadServiceAccountJson();
        final credJson = jsonDecode(credStr) as Map<String, dynamic>;
        final serviceAccountEmail = credJson['client_email'] as String?;
        if (serviceAccountEmail != null && serviceAccountEmail.isNotEmpty) {
          final permUrl = Uri.parse('https://www.googleapis.com/drive/v3/files/$id/permissions').replace(queryParameters: {'sendNotificationEmail': 'false'});
          final permRes = await http.post(
            permUrl,
            headers: headers,
            body: jsonEncode({
              'type': 'user',
              'role': 'writer',
              'emailAddress': serviceAccountEmail,
            }),
          );
          if (permRes.statusCode >= 200 && permRes.statusCode < 300) {
            print('✅ Shared FY spreadsheet with Service Account');
          } else {
            print('⚠️ Could not share FY sheet with Service Account: ${permRes.statusCode} ${permRes.body}');
          }
        }
      } catch (shareErr) {
        print('⚠️ Share FY sheet with Service Account failed: $shareErr');
      }
      return (id, parentId);
    } catch (e) {
      print('❌ _createFySheetInUserDrive: $e');
      return null;
    }
  }

  /// Auth client with Sheets + Drive scopes (for creating sheet and sharing).
  static Future<AuthClient> _getAuthClientWithDrive() async {
    final credentialsJson = await _loadServiceAccountJson();
    final accountCredentials = ServiceAccountCredentials.fromJson(jsonDecode(credentialsJson));
    final scopes = [SheetsApi.spreadsheetsScope, drive.DriveApi.driveScope];
    return await clientViaServiceAccount(accountCredentials, scopes);
  }

  /// Call this when app starts or when you need to ensure all sheets exist
  static Future<void> ensureSheetsExist() async {
    print("🔍 Checking if sheets need to be initialized...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Check if main sheets exist (retry once after delay for Drive permission propagation)
      dynamic spreadsheet;
      try {
        spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      } catch (e) {
        print("❌ First get failed (may be propagation delay): $e");
        await Future.delayed(const Duration(seconds: 3));
        spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      }

      bool needsInit = false;
      List<String> requiredSheets = [];
      if (AppConstants.businessType == 'Trading') {
        requiredSheets = [
          itemSheetName,
          invoiceSheetName,
          invoiceItemSheetName,
          challanSheetName,
          challanItemSheetName,
          purchaseSheetName,
          purchaseItemSheetName,
          inventoryTransactionSheetName,
          customerSheetName,
          companyLogoSheetName,
        ];
      } else {
        // Limited sheets for non-Trading businesses
        requiredSheets = [
          itemSheetName,
          invoiceSheetName,
          invoiceItemSheetName,
          customerSheetName,
        ];
      }

      for (var requiredSheet in requiredSheets) {
        bool exists = false;
        for (var sheet in (spreadsheet.sheets ?? [])) {
          if (sheet.properties?.title == requiredSheet) {
            exists = true;
            break;
          }
        }
        if (!exists) {
          needsInit = true;
          print("⚠️ Missing sheet: $requiredSheet");
          break;
        }
      }

      if (needsInit) {
        print("🔨 Initializing sheets...");
        await initializeAllSheets();
      } else {
        print("✅ All required sheets already exist");
        // Re-apply header format (blue + white text) so existing sheets get white header text
        await _applyHeaderFormatToAllSheets(sheetsApi);
      }

    } catch (e) {
      print("❌ Error checking sheets: $e");
      if (isProjectDeletedError(e)) {
        print("⚠️ FIX: Replace Service Account key - see docs/SERVICE_ACCOUNT_DELETED_PROJECT_FIX.md");
        throw Exception(projectDeletedUserMessage);
      }
      try {
        await initializeAllSheets();
      } catch (e2) {
        print("❌ initializeAllSheets also failed: $e2");
        if (isProjectDeletedError(e2)) {
          throw Exception(projectDeletedUserMessage);
        }
        rethrow;
      }
    }
  }

  /// Check if a sheet (tab) exists in the spreadsheet
  static Future<bool> _sheetExists(SheetsApi sheetsApi, String sheetName) async {
    try {
      print("🔍 Checking if sheet '$sheetName' exists in spreadsheet: $spreadsheetId");

      // Reset cache if spreadsheet changed.
      if (_sheetTitlesForSpreadsheetId != spreadsheetId) {
        _sheetTitlesForSpreadsheetId = spreadsheetId;
        _cachedSheetTitles = <String>{};
        _sheetTitlesFetchedAt = null;
      }

      // Use cached titles when fresh (cuts quota usage a lot).
      final now = DateTime.now();
      if (_sheetTitlesFetchedAt != null &&
          now.difference(_sheetTitlesFetchedAt!) < _sheetTitlesCacheDuration &&
          _cachedSheetTitles.isNotEmpty) {
        final exists = _cachedSheetTitles.contains(sheetName);
        print("⚡ Sheet title cache hit: '$sheetName' exists=$exists");
        return exists;
      }

      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);

      print("📊 Spreadsheet access successful!");
      print("   Title: ${spreadsheet.properties?.title}");
      print("   Total sheets: ${spreadsheet.sheets?.length ?? 0}");

      _cachedSheetTitles = <String>{};
      for (var sheet in spreadsheet.sheets ?? []) {
        print("   - Sheet found: ${sheet.properties?.title}");
        final title = sheet.properties?.title;
        if (title != null && title.trim().isNotEmpty) {
          _cachedSheetTitles.add(title);
        }
        if (sheet.properties?.title == sheetName) {
          print("✅ Sheet '$sheetName' exists");
          _sheetTitlesFetchedAt = DateTime.now();
          return true;
        }
      }

      print("⚠️ Sheet '$sheetName' does not exist");
      _sheetTitlesFetchedAt = DateTime.now();
      return false;
    } catch (e) {
      if (e.toString().contains('404')) {
        print("❌ 404 Error - Possible causes:");
        print("   1. Spreadsheet ID incorrect: $spreadsheetId");
        print("   2. Service account doesn't have access");
        print("   3. Spreadsheet was deleted");
      }
      print("❌ Error checking if sheet exists: $e");
      return false;
    }
  }

  static Future<bool> testSpreadsheetAccess() async {
    print("🧪 Testing spreadsheet access...");
    print("📋 Spreadsheet ID: $spreadsheetId");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Try to get spreadsheet metadata
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);

      print("✅ Spreadsheet access successful!");
      print("   Name: ${spreadsheet.properties?.title}");
      print("   Sheets: ${spreadsheet.sheets?.length ?? 0}");

      // Use FIRST sheet's actual name (not hardcoded "Sheet1" - locale may differ)
      final firstSheetName = spreadsheet.sheets?.isNotEmpty == true
          ? (spreadsheet.sheets!.first.properties?.title ?? "Sheet1")
          : "Sheet1";

      // Try to read a cell (tests read permission)
      try {
        await sheetsApi.spreadsheets.values.get(spreadsheetId, "$firstSheetName!A1");
        print("✅ Read permission confirmed");
      } catch (e) {
        print("⚠️ Could not read $firstSheetName!A1 (this is OK for new spreadsheet)");
      }

      // Try to write (tests write permission)
      try {
        final testData = ValueRange.fromJson({
          "values": [["Test"]]
        });
        await sheetsApi.spreadsheets.values.update(
          testData,
          spreadsheetId,
          "$firstSheetName!A1",
          valueInputOption: "RAW",
        );
        print("✅ Write permission confirmed");
        return true;
      } catch (e) {
        print("❌ Write permission denied: $e");
        print("   → Please give Editor access to:");
        print("   → ${AppConstants.serviceAccountEmailForDisplay}");
        return false;
      }

    } catch (e) {
      print("❌ Failed to access spreadsheet: $e");

      if (e.toString().contains('404')) {
        print("🔍 404 Error means:");
        print("   1. Wrong spreadsheet ID, OR");
        print("   2. Service account has NO access");
        print("");
        print("🔧 Fix: Share spreadsheet with:");
        print("   ${AppConstants.serviceAccountEmailForDisplay}");
      }

      return false;
    }
  }
  /// Create a new sheet (tab) in the spreadsheet
  static Future<void> _createSheet(SheetsApi sheetsApi, String sheetName) async {
    try {
      print("🔨 Creating new sheet: $sheetName");

      final request = BatchUpdateSpreadsheetRequest()
        ..requests = [
          Request()
            ..addSheet = (AddSheetRequest()
              ..properties = (SheetProperties()
                ..title = sheetName
                ..gridProperties = (GridProperties()
                  ..rowCount = 1000
                  ..columnCount = 26
                  ..frozenRowCount = 1))) // Freeze header row
        ];

      await sheetsApi.spreadsheets.batchUpdate(request, spreadsheetId);

      print("✅ Sheet '$sheetName' created successfully");
      if (_sheetTitlesForSpreadsheetId == spreadsheetId) {
        _cachedSheetTitles.add(sheetName);
        _sheetTitlesFetchedAt ??= DateTime.now();
      }
    } catch (e) {
      // Sheets API returns 400 if a sheet with the same title already exists.
      // Treat that case as success to make sheet creation idempotent.
      final msg = e.toString();
      if (msg.contains('already exists') &&
          msg.contains('addSheet') &&
          msg.contains(sheetName)) {
        print("ℹ️ Sheet '$sheetName' already exists. Skipping creation.");
        if (_sheetTitlesForSpreadsheetId == spreadsheetId) {
          _cachedSheetTitles.add(sheetName);
          _sheetTitlesFetchedAt ??= DateTime.now();
        }
        return;
      }
      print("❌ Error creating sheet '$sheetName': $e");
      rethrow;
    }
  }

  static bool _isQuotaOrRateLimitError(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains(' 429') ||
        s.contains('status: 429') ||
        s.contains('quota exceeded') ||
        s.contains('rate limit') ||
        s.contains('user-rate limit') ||
        s.contains('ratelimitexceeded');
  }

  static bool _isServiceUnavailableError(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains(' 503') || s.contains('status: 503') || s.contains('service unavailable');
  }

  static Future<T> _withSheetsRetry<T>(
    Future<T> Function() op, {
    String? opName,
    int maxAttempts = 5,
  }) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        return await op();
      } catch (e) {
        final retriable = _isQuotaOrRateLimitError(e) || _isServiceUnavailableError(e);
        if (!retriable || attempt >= maxAttempts) rethrow;

        // Exponential backoff with a small cap to avoid long UI freezes.
        final delayMs = (500 * (1 << (attempt - 1))).clamp(500, 8000);
        print("⚠️ Sheets API throttled${opName != null ? ' ($opName)' : ''}. "
            "Retrying in ${delayMs}ms (attempt $attempt/$maxAttempts)...");
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
  }

  static Future<List<dynamic>> _ensureHeadersExist(
      SheetsApi sheetsApi,
      String sheetName,
      List<String> expectedHeaders,
      ) async {
    // ✅ USE YOUR EXISTING METHOD - it already does everything!
    return await _getOrCreateSheetAndHeaders(
      sheetsApi,
      sheetName,
      expectedHeaders,
    );
  }

  static Future<void> _createHeaders(
      SheetsApi sheetsApi,
      String sheetName,
      List<String> headers,
      ) async {
    await sheetsApi.spreadsheets.values.update(
      ValueRange.fromJson({"values": [headers]}),
      spreadsheetId,
      "$sheetName!A1",
      valueInputOption: "USER_ENTERED",
    );
    print("✅ Headers created for $sheetName");
  }


  /// Get or create sheet (tab) and headers dynamically
  static Future<List<dynamic>> _getOrCreateSheetAndHeaders(
      SheetsApi sheetsApi,
      String sheetName,
      List<String> expectedHeaders,
      ) async {
    try {
      // Step 1: Check if sheet exists, if not create it
      final sheetExists = await _withSheetsRetry(
        () => _sheetExists(sheetsApi, sheetName),
        opName: "sheetExists:$sheetName",
      );
      bool createdSheet = false;
      bool createdOrUpdatedHeaders = false;

      if (!sheetExists) {
        await _withSheetsRetry(
          () => _createSheet(sheetsApi, sheetName),
          opName: "createSheet:$sheetName",
        );
        createdSheet = true;
        // Wait a moment for sheet creation to propagate
        await Future.delayed(Duration(milliseconds: 500));
      }

      // Step 2: Check if headers exist
      List<dynamic> headers = [];

      try {
        final headerResponse = await _withSheetsRetry(
          () => sheetsApi.spreadsheets.values.get(spreadsheetId, "$sheetName!1:1"),
          opName: "getHeaders:$sheetName",
        );

        if (headerResponse.values == null || headerResponse.values!.isEmpty) {
          print("⚠️ Creating headers for $sheetName sheet...");
          headers = expectedHeaders;
          createdOrUpdatedHeaders = true;

          // Create header row
          await _withSheetsRetry(
            () => sheetsApi.spreadsheets.values.update(
              ValueRange.fromJson({"values": [headers]}),
              spreadsheetId,
              "$sheetName!A1",
              valueInputOption: "USER_ENTERED",
            ),
            opName: "updateHeaders:$sheetName",
          );

          print("✅ Headers created for $sheetName: $headers");
        } else {
          headers = headerResponse.values![0];
          print("✅ Headers found for $sheetName: $headers");
        }
      } catch (e) {
        // If error reading headers, create them
        print("⚠️ Error reading headers, creating new ones: $e");
        headers = expectedHeaders;
        createdOrUpdatedHeaders = true;

        await _withSheetsRetry(
          () => sheetsApi.spreadsheets.values.update(
            ValueRange.fromJson({"values": [headers]}),
            spreadsheetId,
            "$sheetName!A1",
            valueInputOption: "USER_ENTERED",
          ),
          opName: "updateHeadersCatch:$sheetName",
        );

        print("✅ Headers created for $sheetName: $headers");
      }

      // Applying formatting requires extra spreadsheet metadata calls. Do it only when
      // we actually created the sheet or created/updated headers to reduce quota usage.
      if (createdSheet || createdOrUpdatedHeaders) {
        await _withSheetsRetry(
          () => _applyHeaderRowBlueBackground(sheetsApi, sheetName, (headers as List).length),
          opName: "formatHeaders:$sheetName",
          maxAttempts: 3,
        );
      }

      return headers;
    } catch (e) {
      print("❌ Error in _getOrCreateSheetAndHeaders for $sheetName: $e");
      rethrow;
    }
  }

  /// Apply blue background to the first row (header) of a sheet
  static Future<void> _applyHeaderRowBlueBackground(SheetsApi sheetsApi, String sheetName, [int columnCount = 26]) async {
    try {
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      int? targetSheetId;
      for (var sheet in spreadsheet.sheets ?? []) {
        if (sheet.properties?.title == sheetName) {
          targetSheetId = sheet.properties?.sheetId ?? 0;
          break;
        }
      }
      if (targetSheetId == null) return;
      final endCol = columnCount > 0 ? columnCount : 26;
      final cellData = CellData()
        ..userEnteredFormat = (CellFormat()
          ..backgroundColor = (Color()
            ..red = 0.22
            ..green = 0.45
            ..blue = 0.82)
          ..textFormat = (TextFormat()
            ..foregroundColor = (Color()
              ..red = 1.0
              ..green = 1.0
              ..blue = 1.0)
            ..bold = true
            ..fontSize = 14));
      final repeatCellRequest = RepeatCellRequest()
        ..range = (GridRange()
          ..sheetId = targetSheetId
          ..startRowIndex = 0
          ..endRowIndex = 1
          ..startColumnIndex = 0
          ..endColumnIndex = endCol)
        ..cell = cellData
        ..fields = "userEnteredFormat.backgroundColor,userEnteredFormat.textFormat";
      final batchRequest = BatchUpdateSpreadsheetRequest()
        ..requests = [Request()..repeatCell = repeatCellRequest];
      await sheetsApi.spreadsheets.batchUpdate(batchRequest, spreadsheetId);
    } catch (e) {
      print("⚠️ Could not apply header blue background for $sheetName: $e");
    }
  }

  /// Apply blue background + white bold text to header row of all standard sheets (e.g. when sheets already exist).
  static Future<void> _applyHeaderFormatToAllSheets(SheetsApi sheetsApi) async {
    List<String> sheetNames = [];
    if (AppConstants.businessType == 'Trading') {
      sheetNames = [
        itemSheetName,
        invoiceSheetName,
        invoiceItemSheetName,
        challanSheetName,
        challanItemSheetName,
        purchaseSheetName,
        purchaseItemSheetName,
        inventoryTransactionSheetName,
        customerSheetName,
        companyLogoSheetName,
      ];
    } else {
      // Limited sheets for non-Trading businesses
      sheetNames = [
        itemSheetName,
        invoiceSheetName,
        invoiceItemSheetName,
        customerSheetName,
      ];
    }
    
    for (var sheetName in sheetNames) {
      try {
        await _applyHeaderRowBlueBackground(sheetsApi, sheetName, 26);
      } catch (_) {}
    }
  }

  /// Deprecated - use _getOrCreateSheetAndHeaders instead
  /// Get or create headers dynamically for any sheet
  static Future<List<dynamic>> _getOrCreateHeaders(
      SheetsApi sheetsApi,
      String sheetName,
      List<String> expectedHeaders,
      ) async {
    // This now calls the new method that also creates sheets
    return await _getOrCreateSheetAndHeaders(sheetsApi, sheetName, expectedHeaders);
  }

  /// Initialize all standard sheets with headers in one go
  static Future<void> initializeAllSheets() async {
    print("🚀 Initializing all standard sheets...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Define all standard sheets with their expected headers
      final sheetsConfig = {
        itemSheetName: [
          'itemId',
          'itemName',
          'price',
          'sellPrice',
          'gstPercent',
          'unitOfMeasurement',
          'currentStock',
          'detailRequirement',
          'isActive',
          'userId',
          'createdAt',
          'updatedAt',
        ],
        invoiceSheetName: [
          'invoiceId',
          'customerId',
          'customerName',
          'customerEmail',
          'mobile',
          'customerAddress',
          'issueDate',
          'dueDate',
          'subtotal',
          'gstRate',
          'gstAmount',
          'totalAmount',
          'receivedAmount',
          'pendingAmount',
          'status',
          'notes',
          'userId',
          'isDeleted',
        ],
        invoiceItemSheetName: [
          'invoiceId',
          'itemId',
          'itemName',
          'description',
          'quantity',
          'price',
          'gstRate',
          'gstAmount',
          'totalPrice',
          'amountWithGst',
        ],
        challanSheetName: [
          'challanId',
          'customerId',
          'customerName',
          'customerEmail',
          'customerMobile',
          'customerAddress',
          'challanDate',
          'subtotal',
          'gstRate',
          'gstAmount',
          'totalAmount',
          'status',
          'paymentStatus',
          'notes',
          'userId',
        ],
        challanItemSheetName: [
          'challanId',
          'customerId',
          'itemId',
          'itemName',
          'description',
          'quantity',
          'price',
          'challanDate',
          'gstRate',
          'gstAmount',
          'amountWithGst',
          'totalPrice',
        ],
        purchaseSheetName: [
          'purchaseId',
          'vendorId',
          'vendorName',
          'vendorEmail',
          'vendorMobile',
          'vendorAddress',
          'purchaseDate',
          'dueDate',
          'subtotal',
          'gstRate',
          'gstAmount',
          'totalAmount',
          'paidAmount',
          'pendingAmount',
          'paymentStatus',
          'notes',
          'userId',
        ],
        purchaseItemSheetName: [
          'purchaseId',
          'vendorId',
          'itemId',
          'itemName',
          'description',
          'quantity',
          'purchasePrice',
          'purchaseDate',
          'gstRate',
          'totalPrice',
          'unit',
          'userId',
        ],
        inventoryTransactionSheetName: [
          'transactionId',
          'itemId',
          'itemName',
          'quantity',
          'type',
          'reason',
          'timestamp',
          'notes',
          'userId',
        ],
        customerSheetName: [
          'customerId',
          'companyId',
          'name',
          'address',
          'city',
          'state',
          'country',
          'pincode',
          'gst',
          'pan',
          'businessName',
          'businessType',
          'mobile1',
          'mobile2',
          'email',
          'website',
          'notes',
          'sundryType',
          'isActive',
          'createdAt',
          'updatedAt',
        ],
        companyLogoSheetName: [
          'companyId',
          'companyName',
          'logoUrl',
        ],
      };

      int successCount = 0;
      int errorCount = 0;

      // Filter sheetsConfig based on businessType
      Map<String, List<String>> activeSheetsConfig = {};
      if (AppConstants.businessType == 'Trading') {
        activeSheetsConfig = sheetsConfig;
      } else {
        // Only include limited sheets for non-Trading businesses
        final allowedSheets = [
          itemSheetName,
          invoiceSheetName,
          invoiceItemSheetName,
          customerSheetName,
        ];
        activeSheetsConfig = Map.fromEntries(
          sheetsConfig.entries.where((entry) => allowedSheets.contains(entry.key))
        );
      }

      // Create all sheets with headers
      for (var entry in activeSheetsConfig.entries) {
        final sheetName = entry.key;
        final headers = entry.value;

        try {
          await _getOrCreateSheetAndHeaders(sheetsApi, sheetName, headers);
          successCount++;
          print("✅ [$successCount/${sheetsConfig.length}] $sheetName ready");
        } catch (e) {
          errorCount++;
          print("❌ Error initializing $sheetName: $e");
        }
      }

      print("");
      print("=" * 50);
      print("📊 Initialization Summary:");
      print("   ✅ Success: $successCount sheets");
      print("   ❌ Errors: $errorCount sheets");
      print("   📋 Total: ${sheetsConfig.length} sheets");
      print("=" * 50);

      if (errorCount == 0) {
        print("🎉 All sheets initialized successfully!");
      } else if (errorCount == sheetsConfig.length) {
        print("❌ All sheet initializations failed - Service Account may not have access.");
        throw Exception('All sheet initializations failed - Service Account may not have access.');
      }

    } catch (e) {
      print("❌ Error in initializeAllSheets: $e");
      if (isProjectDeletedError(e)) {
        throw Exception(projectDeletedUserMessage);
      }
      rethrow;
    }
  }

  /// Check the status of all sheets
  static Future<Map<String, bool>> checkAllSheetsStatus() async {
    print("🔍 Checking status of all sheets...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      List<String> sheetNames = [];
      if (AppConstants.businessType == 'Trading') {
        sheetNames = [
          itemSheetName,
          invoiceSheetName,
          invoiceItemSheetName,
          challanSheetName,
          challanItemSheetName,
          purchaseSheetName,
          purchaseItemSheetName,
          inventoryTransactionSheetName,
        ];
      } else {
        sheetNames = [
          itemSheetName,
          invoiceSheetName,
          invoiceItemSheetName,
        ];
      }

      Map<String, bool> status = {};

      for (var sheetName in sheetNames) {
        status[sheetName] = await _sheetExists(sheetsApi, sheetName);
      }

      print("\n📋 Sheet Status:");
      print("=" * 50);
      status.forEach((name, exists) {
        final icon = exists ? "✅" : "❌";
        final statusText = exists ? "EXISTS" : "MISSING";
        print("$icon $name: $statusText");
      });
      print("=" * 50);

      return status;
    } catch (e) {
      print("❌ Error checking sheets status: $e");
      return {};
    }
  }


  /// Load credentials from assets/credentials.json
  static Future<String> _loadServiceAccountJson() async {
    final path = "assets/${AppConstants.serviceAccountJsonPath}";
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      print("❌ Service account file NOT FOUND: $path");
      print("   → Add the JSON file to assets/ folder.");
      print("   → Then run: flutter clean && flutter pub get && flutter run");
      rethrow;
    }
  }

  static Future<AuthClient> _getAuthClient() async {
    final credentialsJson = await _loadServiceAccountJson();

    final accountCredentials =
    ServiceAccountCredentials.fromJson(jsonDecode(credentialsJson));
    final scopes = [SheetsApi.spreadsheetsScope];

    return await clientViaServiceAccount(accountCredentials, scopes);
  }

  /// Get company logo URL from CompanyLogo sheet (by companyId). Returns null if not found or sheet empty.
  static Future<String?> getCompanyLogoUrl(String companyId) async {
    if (companyId.isEmpty) return null;
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);
      final exists = await _sheetExists(sheetsApi, companyLogoSheetName);
      if (!exists) return null;
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$companyLogoSheetName!A:C",
      );
      final rows = response.values ?? [];
      if (rows.length < 2) return null;
      final header = (rows.first).map((e) => e.toString().toLowerCase().trim()).toList();
      final companyIdIdx = header.indexOf('companyid');
      final logoUrlIdx = header.indexOf('logourl');
      if (companyIdIdx < 0 || logoUrlIdx < 0) return null;
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length > companyIdIdx && row.length > logoUrlIdx) {
          final cid = row[companyIdIdx].toString().trim();
          final url = row[logoUrlIdx].toString().trim();
          if (cid == companyId && url.isNotEmpty) return url;
        }
      }
      return null;
    } catch (e) {
      print("⚠️ getCompanyLogoUrl: $e");
      return null;
    }
  }

  /// Add or update company logo URL in CompanyLogo sheet (companyId is key; updates row if exists).
  static Future<void> addOrUpdateCompanyLogo(String companyId, String companyName, String logoUrl) async {
    if (companyId.isEmpty) return;
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);
      final headers = await _getOrCreateSheetAndHeaders(
        sheetsApi,
        companyLogoSheetName,
        ['companyId', 'companyName', 'logoUrl'],
      );
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$companyLogoSheetName!A:C",
      );
      final rows = response.values ?? [];
      final header = rows.isNotEmpty ? (rows.first).map((e) => e.toString().toLowerCase().trim()).toList() : <String>[];
      final companyIdIdx = header.indexOf('companyid');
      if (companyIdIdx < 0) return;
      int rowIndex = -1;
      for (var i = 1; i < rows.length; i++) {
        if (rows[i].length > companyIdIdx && rows[i][companyIdIdx].toString().trim() == companyId) {
          rowIndex = i + 1;
          break;
        }
      }
      final rowData = [companyId, companyName, logoUrl];
      if (rowIndex > 0) {
        await sheetsApi.spreadsheets.values.update(
          ValueRange.fromJson({"values": [rowData]}),
          spreadsheetId,
          "$companyLogoSheetName!A$rowIndex:C$rowIndex",
          valueInputOption: "USER_ENTERED",
        );
        print("✅ Company logo updated in sheet for $companyId");
      } else {
        await sheetsApi.spreadsheets.values.append(
          ValueRange.fromJson({"values": [rowData]}),
          spreadsheetId,
          "$companyLogoSheetName!A:C",
          valueInputOption: "USER_ENTERED",
        );
        print("✅ Company logo added to sheet for $companyId");
      }
    } catch (e) {
      print("⚠️ addOrUpdateCompanyLogo: $e");
    }
  }

  /// Add a new item row to Google Sheet
  static Future<void> addItem(String userId, Item item) async {
    print("🔄 Adding Item to Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // ✅ Define expected headers for the Items sheet
      final expectedHeaders = [
        'itemId',
        'itemName',
        'price',
        'sellPrice',
        'gstPercent',
        'unitOfMeasurement',
        'currentStock',
        'detailRequirement',
        'isActive',
        'userId',
        'createdAt',
        'updatedAt',
      ];

      // ✅ Ensure sheet and headers exist (auto-create if missing)
      final headers = await _getOrCreateHeaders(
        sheetsApi,
        itemSheetName,
        expectedHeaders,
      );

      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');
      final now = DateTime.now();

      // Prepare item data map
      final Map<String, dynamic> itemData = {
        'itemId': item.itemId,
        'itemName': item.itemName,
        'price': item.price.toString(),
        'sellPrice': item.sellPrice.toString(),
        'gstPercent': item.gstPercent.toString(),
        'unitOfMeasurement': item.unitOfMeasurement,
        'currentStock': item.currentStock.toString(),
        'detailRequirement': item.detailRequirement,
        'isActive': item.isActive ? "TRUE" : "FALSE",
        'userId': userId,
        'createdAt': _dateFormatter.format(now),
        'updatedAt': _dateFormatter.format(now),
      };

      // Normalize for case-insensitive mapping
      Map<String, dynamic> _normalize(Map<String, dynamic> data) {
        return {
          for (var entry in data.entries)
            entry.key.toString().trim().toLowerCase(): entry.value
        };
      }

      final normalized = _normalize(itemData);

      // Build row according to header order
      List<dynamic> rowData = [];
      for (var header in headers) {
        final key = header.toString().trim().toLowerCase();
        rowData.add(normalized[key]?.toString() ?? '');
      }

      print("🧾 Prepared item row: $rowData");

      // Append to Google Sheet
      final valueRange = ValueRange.fromJson({"values": [rowData]});
      await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        "$itemSheetName!A:Z",
        valueInputOption: "USER_ENTERED",
      );

      print("✅ Item added successfully to Google Sheet");
    } catch (e) {
      print("❌ Error adding Item: $e");
      throw Exception("Failed to add Item: ${e.toString()}");
    }
  }


  // Get items from Google Sheet with optional user filtering
  static Future<List<Item>> getItems({String? userId}) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      print("---------========Sheets API Get Items...........-----");
      print("📋 Spreadsheet ID: $spreadsheetId | Sheet: $itemSheetName | Filter userId: '${userId ?? ''}'");

      // Ensure sheet + headers exist (and auto-create if missing) so we don't read empty/missing sheets.
      final expectedHeaders = [
        'itemId',
        'itemName',
        'price',
        'sellPrice',
        'gstPercent',
        'unitOfMeasurement',
        'currentStock',
        'detailRequirement',
        'isActive',
        'userId',
        'createdAt',
        'updatedAt',
      ];
      await _withSheetsRetry(
        () => _getOrCreateSheetAndHeaders(sheetsApi, itemSheetName, expectedHeaders),
        opName: "ensureItemSheetAndHeaders",
      );

      // 1. Get Headers first to map columns dynamically
      String activeSheetName = itemSheetName;
      ValueRange headerResponse;
      try {
        headerResponse = await _withSheetsRetry(
          () => sheetsApi.spreadsheets.values.get(spreadsheetId, "$itemSheetName!1:1"),
          opName: "getItemHeaders",
        );
      } catch (e) {
        // Fallback: some older sheets may have tab named "Items".
        if (e.toString().toLowerCase().contains('unable to parse range') ||
            e.toString().toLowerCase().contains('notfound')) {
          const altName = "Items";
          print("⚠️ Could not read '$itemSheetName' headers. Trying fallback sheet '$altName'...");
          activeSheetName = altName;
          headerResponse = await _withSheetsRetry(
            () => sheetsApi.spreadsheets.values.get(spreadsheetId, "$altName!1:1"),
            opName: "getItemHeadersFallback",
          );
        } else {
          rethrow;
        }
      }

      if (headerResponse.values == null || headerResponse.values!.isEmpty) {
        print("No headers found in Item sheet");
        return <Item>[];
      }

      final headers = headerResponse.values![0]
          .map((h) => h.toString().toLowerCase().trim())
          .toList();

      // 2. Get Data (Start from Row 2)
      ValueRange response = await _withSheetsRetry(
        () => sheetsApi.spreadsheets.values.get(spreadsheetId, "$activeSheetName!A2:Z"),
        opName: "getItemRows:$activeSheetName",
      );

      // If the "Item" tab exists but has no rows, older workbooks may store data in "Items".
      if ((response.values == null || response.values!.isEmpty) && activeSheetName == itemSheetName) {
        const altName = "Items";
        print("⚠️ '$activeSheetName' has no rows. Trying data fallback sheet '$altName'...");
        try {
          final alt = await _withSheetsRetry(
            () => sheetsApi.spreadsheets.values.get(spreadsheetId, "$altName!A2:Z"),
            opName: "getItemRowsFallback:$altName",
            maxAttempts: 3,
          );
          if (alt.values != null && alt.values!.isNotEmpty) {
            activeSheetName = altName;
            response = alt;
            print("✅ Using '$activeSheetName' for item rows (fallback worked).");
          }
        } catch (_) {}
      }

      print("Response values length: ${response.values?.length ?? 0}");

      if (response.values == null || response.values!.isEmpty) {
        print("No data found in sheet");
        return <Item>[];
      }

      // Parse all rows first, then filter (helps debug + avoids over-filtering).
      List<Item> allItems = [];
      List<Item> items = [];
      int totalParsed = 0;
      int matchedByUser = 0;
      int includedEmptyUserId = 0;
      int mismatchedUserId = 0;

      for (int i = 0; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.isEmpty) continue;

        // Map row data to headers
        Map<String, String> rowMap = {};
        for (int j = 0; j < headers.length; j++) {
          if (j < row.length) {
            rowMap[headers[j]] = row[j].toString();
          }
        }

        try {
          // Parse row data
          final rawIsActive = rowMap['isactive']?.toString().trim().toLowerCase();
          final isActive = rawIsActive == null ||
              rawIsActive.isEmpty ||
              rawIsActive == 'true' ||
              rawIsActive == '1' ||
              rawIsActive == 'yes' ||
              rawIsActive == 'y';

          final item = Item(
            itemId: rowMap['itemid'] ?? '',
            itemName: rowMap['itemname'] ?? '',
            price: double.tryParse(rowMap['price'] ?? '0') ?? 0.0,
            sellPrice: double.tryParse(rowMap['sellprice'] ?? '0') ?? 0.0, // ✅ Read Sell Price
            gstPercent: double.tryParse(rowMap['gstpercent'] ?? '0') ?? 0.0,
            unitOfMeasurement: ((rowMap['unitofmeasurement'] ?? '').toString().trim().isEmpty)
                ? 'pcs'
                : (rowMap['unitofmeasurement'] ?? 'pcs').toString(),
            currentStock: double.tryParse((rowMap['currentstock'] ?? '0').toString().trim()) ?? 0.0,
            detailRequirement: rowMap['detailrequirement'] ?? '',
            isActive: isActive,
          );

          totalParsed++;
          allItems.add(item);

          // Filter by userId if provided (trim both to avoid mismatch from spaces)
          if (userId != null && userId.isNotEmpty) {
            String rowUserId = (rowMap['userid'] ?? '').toString().trim();
            if (rowUserId == userId.trim()) {
              items.add(item);
              matchedByUser++;
            } else if (rowUserId.isEmpty) {
              // Backward-compat: older rows might not have userId populated.
              // In that case, include them for the currently logged-in user.
              items.add(item);
              includedEmptyUserId++;
            } else {
              mismatchedUserId++;
            }
          } else {
            // No filter, add all items
            items.add(item);
          }

        } catch (e) {
          print("Error parsing item at row ${i + 2}: $e");
          // print("Row map: $rowMap");
          continue;
        }
      }

      // If we parsed rows but userId filter removed everything, show all items instead.
      if ((userId != null && userId.isNotEmpty) && items.isEmpty && allItems.isNotEmpty) {
        print("⚠️ Items parsed ($totalParsed) but 0 after userId filter. "
            "Returning all items (likely userId mismatch in sheet).");
        items = allItems;
      }

      if (userId != null && userId.isNotEmpty) {
        print("✅ Retrieved ${items.length} items from Google Sheet "
            "(sheet=$activeSheetName, totalParsed=$totalParsed, matchedByUser=$matchedByUser, includedEmptyUserId=$includedEmptyUserId, mismatchedUserId=$mismatchedUserId)");
      } else {
        print("✅ Retrieved ${items.length} items from Google Sheet (sheet=$activeSheetName, totalParsed=$totalParsed)");
      }
      return items;

    } catch (e) {
      print("Error in getItems: $e");
      rethrow;
    }
  }

  /// Edit item using Google Sheets API (delete and re-add approach)
  // static Future<void> editItemAlternative3(String userId, Item item) async {
  //   print("=== TRYING ALTERNATIVE 3: DELETE AND ADD (Google Sheets) ===");
  //
  //   try {
  //     final client = await _getAuthClient();
  //     final sheetsApi = SheetsApi(client);
  //
  //
  //     // Get sheet metadata to find the correct sheetId (safer than hardcoding 0)
  //     final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
  //     final sheet = spreadsheet.sheets!
  //         .firstWhere((s) => s.properties?.title == itemSheetName);
  //     final sheetId = sheet.properties!.sheetId!;
  //     // Step 1: Find and delete the existing item
  //     print("Step 1: Finding item to delete...");
  //
  //     final response = await sheetsApi.spreadsheets.values.get(
  //       spreadsheetId,
  //       "$itemSheetName!A:K",
  //     );
  //
  //     if (response.values == null || response.values!.isEmpty) {
  //       throw Exception("No data found in sheet");
  //     }
  //
  //     int? targetRowIndex;
  //     for (int i = 1; i < response.values!.length; i++) {
  //       final row = response.values![i];
  //       if (row.isNotEmpty && row[0]?.toString() == item.itemId) {
  //         targetRowIndex = i; // 0-based index for delete operation
  //         break;
  //       }
  //     }
  //
  //     if (targetRowIndex == null) {
  //       throw Exception("Item with ID ${item.itemId} not found");
  //     }
  //
  //     print("Found item at row index: $targetRowIndex");
  //
  //     // Delete the row using batch update
  //     final deleteRequests = [
  //       Request()
  //         ..deleteDimension = (DeleteDimensionRequest()
  //           ..range = (DimensionRange()
  //             ..sheetId = sheetId // Adjust if your sheet has different ID
  //             ..dimension = 'ROWS'
  //             ..startIndex = targetRowIndex
  //             ..endIndex = targetRowIndex + 1))
  //     ];
  //
  //     final deleteBatchRequest = BatchUpdateSpreadsheetRequest()
  //       ..requests = deleteRequests;
  //
  //     print("Deleting row...");
  //     await sheetsApi.spreadsheets.batchUpdate(
  //       deleteBatchRequest,
  //       spreadsheetId,
  //     );
  //
  //     print("Delete successful");
  //
  //     // Step 2: Add the updated item (small delay for consistency)
  //     await Future.delayed(Duration(seconds: 1));
  //
  //     print("Step 2: Adding updated item...");
  //
  //     // Prepare updated row values
  //     final values = [
  //       item.itemId,
  //       item.itemName,
  //       item.price.toString(),
  //       item.gstPercent.toString(),
  //       item.unitOfMeasurement,
  //       item.currentStock.toString(),
  //       item.detailRequirement,
  //       item.isActive ? "TRUE" : "FALSE",
  //       userId,
  //     ];
  //
  //     print("Adding values: $values");
  //
  //     // Append the updated row
  //     await sheetsApi.spreadsheets.values.append(
  //       ValueRange.fromJson({
  //         "values": [values]
  //       }),
  //       spreadsheetId,
  //       "$itemSheetName!A:H",
  //       valueInputOption: "RAW",
  //     );
  //
  //     print("Add successful - Item edited using delete and add approach");
  //
  //   } catch (e) {
  //     print("Error in editItemAlternative3: $e");
  //     rethrow;
  //   }
  // }

  static Future<void> editItemAlternative3(String userId, Item item) async {
    print("=== UPDATING ITEM (Delete & Add Method) ===");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // 1. Get Headers
      final headerResponse = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$itemSheetName!1:1",
      );

      if (headerResponse.values == null || headerResponse.values!.isEmpty) {
        throw Exception("No headers found in Item sheet");
      }

      final headers = headerResponse.values![0].map((h) => h.toString().trim()).toList();
      final headersLower = headers.map((h) => h.toString().toLowerCase()).toList();

      // 2. Find and Delete Row (Existing logic)
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      final sheet = spreadsheet.sheets!
          .firstWhere((s) => s.properties?.title == itemSheetName);
      final sheetId = sheet.properties!.sheetId!;

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$itemSheetName!A:Z",
      );

      if (response.values == null) throw Exception("Sheet is empty");

      int? targetRowIndex;
      final itemIdIndex = headersLower.indexOf('itemid');

      if (itemIdIndex == -1) throw Exception("itemId column not found");

      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length > itemIdIndex && row[itemIdIndex]?.toString() == item.itemId) {
          targetRowIndex = i; // 0-based index for API
          break;
        }
      }

      if (targetRowIndex != null) {
        final deleteRequest = Request()
          ..deleteDimension = (DeleteDimensionRequest()
            ..range = (DimensionRange()
              ..sheetId = sheetId
              ..dimension = 'ROWS'
              ..startIndex = targetRowIndex
              ..endIndex = targetRowIndex + 1));

        await sheetsApi.spreadsheets.batchUpdate(
          BatchUpdateSpreadsheetRequest()..requests = [deleteRequest],
          spreadsheetId,
        );
        print("🗑️ Old item row deleted");
      } else {
        print("⚠️ Item not found to delete, will just add new row.");
      }

      // 3. Add Updated Item (Using Dynamic Mapping)
      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');
      final now = DateTime.now();

      // Map item data to header keys
      Map<String, dynamic> itemMap = {
        'itemid': item.itemId,
        'itemname': item.itemName,
        'price': item.price.toString(),
        'sellprice': item.sellPrice.toString(), // ✅ Added
        'gstpercent': item.gstPercent.toString(),
        'unitofmeasurement': item.unitOfMeasurement,
        'currentstock': item.currentStock.toString(),
        'detailrequirement': item.detailRequirement,
        'isactive': item.isActive ? "TRUE" : "FALSE",
        'userid': userId,
        'updatedat': _dateFormatter.format(now),
        // We don't overwrite createdAt if we don't have it, but for new row we might need it.
        // Ideally fetch old createdAt, but for now using current time is acceptable for this flow
        'createdat': _dateFormatter.format(now),
      };

      List<dynamic> newRow = [];
      for (var header in headers) {
        // Use lowercase header to lookup in itemMap
        newRow.add(itemMap[header.toString().toLowerCase()] ?? '');
      }

      await sheetsApi.spreadsheets.values.append(
        ValueRange.fromJson({"values": [newRow]}),
        spreadsheetId,
        "$itemSheetName!A:Z",
        valueInputOption: "USER_ENTERED",
      );

      print("✅ Item Updated Successfully with Sell Price");

    } catch (e) {
      print("Error in editItemAlternative3: $e");
      rethrow;
    }
  }

  // static Future<List<Invoice>> getInvoices({String? type}) async {
  //   print("🔄 Fetching invoices from Google Sheet...");
  //
  //   try {
  //     final client = await _getAuthClient();
  //     final sheetsApi = SheetsApi(client);
  //
  //     // Get header row
  //     final headerResponse = await sheetsApi.spreadsheets.values.get(
  //       spreadsheetId,
  //       "$invoiceSheetName!1:1",
  //     );
  //
  //     if (headerResponse.values == null || headerResponse.values!.isEmpty) {
  //       print("No header row found in sheet");
  //       return <Invoice>[];
  //     }
  //
  //     final headers = headerResponse.values![0];
  //     final columnIndices = {
  //       for (int i = 0; i < headers.length; i++) headers[i].toString().toLowerCase(): i,
  //     };
  //
  //     // Get all data
  //     final response = await sheetsApi.spreadsheets.values.get(
  //       spreadsheetId,
  //       "$invoiceSheetName!A:Z",
  //     );
  //
  //     if (response.values == null || response.values!.isEmpty || response.values!.length <= 1) {
  //       print("No invoice data found in sheet");
  //       return <Invoice>[];
  //     }
  //
  //     List<Invoice> invoices = [];
  //
  //     // Skip header row
  //     for (int i = 1; i < response.values!.length; i++) {
  //       final row = response.values![i];
  //       if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) continue;
  //
  //       try {
  //         Map<String, dynamic> rowData = {};
  //         for (int j = 0; j < min(row.length, headers.length); j++) {
  //           rowData[headers[j].toString()] = row[j];
  //         }
  //
  //         final invoice = Invoice.fromMap(rowData);
  //
  //         // 🔑 Apply filter
  //         if (type == "INV" && !invoice.invoiceId.startsWith("INV")) continue;
  //         if (type == "QUO" && !invoice.invoiceId.startsWith("QUO")) continue;
  //
  //         invoices.add(invoice);
  //
  //       } catch (e) {
  //         print("Error parsing invoice row ${i}: $e");
  //         continue;
  //       }
  //     }
  //
  //     print("✅ Retrieved ${invoices.length} invoices from Google Sheet (filter: $type)");
  //     return invoices;
  //
  //   } catch (e) {
  //     print("❌ Error in getInvoices: $e");
  //     rethrow;
  //   }
  // }

  static const String _invoiceListCacheKeyPrefix = 'invoices_';

  static void _clearInvoiceListCache() {
    _invoiceListCache.clear();
    _cacheTimestamps.removeWhere((k, _) => k.startsWith(_invoiceListCacheKeyPrefix));
    print("🗑️ Cleared invoice list cache");
  }

  /// Call when switching financial year so dashboard and lists load data from the new sheet instead of cached data.
  static void clearInvoiceListCacheForNewFy() {
    _clearInvoiceListCache();
  }

  static Future<List<Invoice>> getInvoices({String? type}) async {
    final cacheKey = '${_invoiceListCacheKeyPrefix}${type ?? 'all'}';
    final now = DateTime.now();
    if (_invoiceListCache.containsKey(cacheKey) && _cacheTimestamps.containsKey(cacheKey)) {
      final age = now.difference(_cacheTimestamps[cacheKey]!);
      if (age < _invoiceListCacheDuration) {
        print("⚡ Returning cached invoices ($type) (${age.inSeconds}s old)");
        return _invoiceListCache[cacheKey]!;
      }
    }

    try {
      return await _getInvoicesFromSheet(type: type, cacheKey: cacheKey);
    } catch (e) {
      final is429 = e.toString().contains('429') || e.toString().toLowerCase().contains('quota exceeded');
      if (is429) {
        print("⚠️ Quota exceeded (429), retrying after 60s...");
        await Future.delayed(const Duration(seconds: 60));
        try {
          return await _getInvoicesFromSheet(type: type, cacheKey: cacheKey);
        } catch (e2) {
          print("❌ Error in getInvoices (after retry): $e2");
          rethrow;
        }
      }
      print("❌ Error in getInvoices: $e");
      rethrow;
    }
  }

  static Future<List<Invoice>> _getInvoicesFromSheet({String? type, required String cacheKey}) async {
    print("🔄 Fetching invoices from Google Sheet...");

    final client = await _getAuthClient();
    final sheetsApi = SheetsApi(client);

    // Get header row
    final headerResponse = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      "$invoiceSheetName!1:1",
    );

    if (headerResponse.values == null || headerResponse.values!.isEmpty) {
      print("No header row found in sheet");
      return <Invoice>[];
    }

    final headers = headerResponse.values![0];

    // Get all data
    final response = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      "$invoiceSheetName!A:Z",
    );

    if (response.values == null || response.values!.isEmpty || response.values!.length <= 1) {
      print("No invoice data found in sheet");
      return <Invoice>[];
    }

    List<Invoice> invoices = [];
    const int yieldEvery = 100;

    for (int i = 1; i < response.values!.length; i++) {
      if (i > 1 && (i - 1) % yieldEvery == 0) {
        await Future.delayed(Duration.zero);
      }
      final row = response.values![i];
      if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) continue;

      try {
        Map<String, dynamic> rowData = {};
        for (int j = 0; j < min(row.length, headers.length); j++) {
          final headerKey = headers[j].toString();
          final cellValue = row[j];

          if (headerKey.toLowerCase() == 'issuedate' || headerKey.toLowerCase() == 'duedate') {
            if (cellValue != null && cellValue.toString().isNotEmpty) {
              final parsedDate = _parseDate(cellValue.toString());
              rowData[headerKey] = parsedDate;
            } else {
              rowData[headerKey] = null;
            }
          } else if (headerKey.toLowerCase().replaceAll(' ', '').replaceAll('_', '') == 'updatedat') {
            if (cellValue != null && cellValue.toString().trim().isNotEmpty) {
              rowData['updatedAt'] = _parseDateOrDateTime(cellValue.toString());
            } else {
              rowData['updatedAt'] = null;
            }
          } else {
            rowData[headerKey] = cellValue;
          }
        }

        final invoice = Invoice.fromMap(rowData);

        // Skip soft-deleted invoices
        if (invoice.isDeleted == 1) continue;

        if (type == "INV" && !invoice.invoiceId.startsWith("INV")) continue;
        if (type == "QUO" && !invoice.invoiceId.startsWith("QUO")) continue;

        invoices.add(invoice);

      } catch (e) {
        continue;
      }
    }

    _invoiceListCache[cacheKey] = invoices;
    _cacheTimestamps[cacheKey] = DateTime.now();
    print("✅ Retrieved ${invoices.length} invoices from Google Sheet (filter: $type)");
    return invoices;
  }

// 🔹 Helper method to parse dates from Google Sheets
  static DateTime? _parseDate(String dateString) {
    if (dateString.isEmpty) return null;

    try {
      // Format: dd/MM/yyyy (most common in Google Sheets)
      if (dateString.contains("/")) {
        final parts = dateString.split("/");
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]), // yyyy
            int.parse(parts[1]), // MM
            int.parse(parts[0]), // dd
          );
        }
      }

      // Format: yyyy-MM-dd (ISO format)
      if (dateString.contains("-")) {
        return DateTime.tryParse(dateString);
      }

      print("⚠️ Could not parse date: $dateString");
      return null;
    } catch (e) {
      print("❌ Error parsing date '$dateString': $e");
      return null;
    }
  }

  /// Parse date or datetime string (e.g. dd/MM/yyyy HH:mm:ss) for updatedAt
  static DateTime? _parseDateOrDateTime(String value) {
    if (value.trim().isEmpty) return null;
    final s = value.trim();
    final datePart = s.contains(" ") ? s.split(" ").first : s;
    if (datePart.contains("/")) {
      final parts = datePart.split("/");
      if (parts.length == 3) {
        try {
          return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        } catch (_) {}
      }
    }
    return DateTime.tryParse(datePart) ?? _parseDate(s);
  }

// Add invoice to Google Sheet
  static Future<void> addInvoice(dynamic invoiceData, String userId) async {
    print("🔄 Adding Invoice to Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // ✅ Define expected headers for the Invoice sheet (paymentMethod, paymentStatus removed per user request)
      final expectedHeaders = [
        'invoiceId',
        'customerId',
        'customerName',
        'customerEmail',
        'mobile',
        'customerAddress',
        'issueDate',
        'dueDate',
        'subtotal',
        'gstAmount',
        'totalAmount',
        'receivedAmount',
        'pendingAmount',
        'status',
        'paymentMode',
        'notes',
        'profit',
        'invoiceType',
        'userId',
        'companyId',
        'createdAt',
        'updatedAt',
      ];

      // ✅ Ensure sheet and headers exist (auto-create if missing)
      final headers = await _withSheetsRetry(
        () => _getOrCreateHeaders(sheetsApi, invoiceSheetName, expectedHeaders),
        opName: "ensureInvoiceSheetAndHeaders",
      );

      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');

      // Format date safely
      String _formatDate(dynamic value) {
        if (value == null || value.toString().isEmpty) return "";
        try {
          if (value is DateTime) return _dateFormatter.format(value);
          return _dateFormatter.format(DateTime.parse(value.toString()));
        } catch (e) {
          return value.toString();
        }
      }

      // Normalize keys for consistent lookups
      Map<String, dynamic> _normalize(Map<String, dynamic> data) {
        return {
          for (var entry in data.entries)
            entry.key.toString().trim().toLowerCase(): entry.value
        };
      }

      // Prepare invoice rows
      List<List<dynamic>> rowsToAdd = [];

      // Handle different data types
      if (invoiceData is Map<String, dynamic>) {
        rowsToAdd.add(_prepareInvoiceRow(invoiceData, userId, headers, _formatDate, _normalize));
      } else if (invoiceData is List<Invoice>) {
        for (Invoice invoice in invoiceData) {
          rowsToAdd.add(_prepareInvoiceRow(invoice.toMap(), userId, headers, _formatDate, _normalize));
        }
      } else if (invoiceData is Invoice) {
        rowsToAdd.add(_prepareInvoiceRow(invoiceData.toMap(), userId, headers, _formatDate, _normalize));
      }

      print("🧾 Prepared invoice rows: $rowsToAdd");

      // Append to Google Sheet
      final valueRange = ValueRange.fromJson({"values": rowsToAdd});

      await _withSheetsRetry(
        () => sheetsApi.spreadsheets.values.append(
          valueRange,
          spreadsheetId,
          "$invoiceSheetName!A:Z",
          valueInputOption: "USER_ENTERED",
        ),
        opName: "appendInvoiceRows",
      );

      print("✅ Invoice(s) added successfully to Google Sheet");
      _clearInvoiceListCache();
    } catch (e) {
      print("❌ Error adding invoice: $e");
      throw Exception("Failed to add invoice: ${e.toString()}");
    }
  }


// 🔧 Helper: Prepares a single invoice row in header order
  static List<dynamic> _prepareInvoiceRow(
      Map<String, dynamic> invoiceData,
      String userId,
      List<dynamic> headers,
      String Function(dynamic) _formatDate,
      Map<String, dynamic> Function(Map<String, dynamic>) _normalize,
      ) {
    final normalized = _normalize(invoiceData);
    final now = DateTime.now();

    // Add timestamps
    normalized['createdat'] ??= _formatDate(now);
    normalized['updatedat'] ??= _formatDate(now);
    normalized['userid'] ??= userId;
    normalized['isdeleted'] ??= '0'; // Soft delete: 0=active, 1=deleted

    // Fill data in header order
    List<dynamic> row = [];
    for (var header in headers) {
      final key = header.toString().trim().toLowerCase();
      row.add(normalized[key]?.toString() ?? '');
    }

    return row;
  }





  /// At aTime all
  static Future<void> addInvoiceItemsBatch(
      List<Map<String, dynamic>> itemsData,
      String userId,
      ) async {
    print("🔄 Adding ${itemsData.length} invoice items in batch...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      final expectedHeaders = [
        'invoiceId',
        'customerId',
        'itemId',
        'itemName',
        'description',
        'quantity',
        'rate',
        'price',
        'issueDate',
        'gstRate',
        'gstAmount',
        'totalPrice',
        'unit',
        'userId',
      ];

      // ✅ Ensure headers exist
      final headers = await _ensureHeadersExist(
        sheetsApi,
        invoiceItemSheetName,
        expectedHeaders,
      );

      List<List<dynamic>> rows = [];

      for (var itemData in itemsData) {
        List<dynamic> rowData = [];

        for (var header in headers) {
          final headerName = header.toString();
          final headerNameLower = headerName.toLowerCase();

          if (headerNameLower.contains('userid')) {
            rowData.add(userId);
          } else {
            var value = '';
            if (itemData.containsKey(headerName)) {
              value = itemData[headerName]?.toString() ?? '';
            } else {
              for (var key in itemData.keys) {
                if (key.toString().toLowerCase() == headerNameLower) {
                  value = itemData[key]?.toString() ?? '';
                  break;
                }
              }
            }
            rowData.add(value);
          }
        }

        rows.add(rowData);
      }

      final valueRange = ValueRange.fromJson({"values": rows});

      await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        "$invoiceItemSheetName!A:Z",
        valueInputOption: "USER_ENTERED",
      );

      print("✅ ${rows.length} invoice items added successfully");
    } catch (e) {
      print("❌ Error adding invoice items: $e");
      rethrow;
    }
  }



  ///it is Working 17-10 10:34 i just Change For inventory
  // static Future<void> updateInvoice(
  //     Map<String, dynamic> invoiceData, String userId) async {
  //   print("🔄 Updating invoice in Google Sheet...");
  //
  //   try {
  //     final client = await _getAuthClient();
  //     final sheetsApi = SheetsApi(client);
  //     const targetSheetName = "Invoice";
  //
  //     // 1. Get headers
  //     final headerResponse = await sheetsApi.spreadsheets.values.get(
  //       spreadsheetId,
  //       "$targetSheetName!1:1",
  //     );
  //     final headers = headerResponse.values![0];
  //
  //     // 2. Find row number
  //     final allRows = await sheetsApi.spreadsheets.values.get(
  //       spreadsheetId,
  //       "$targetSheetName!A:Z",
  //     );
  //
  //     int rowIndex = -1;
  //     List<dynamic>? oldRow;
  //
  //     for (int i = 1; i < (allRows.values?.length ?? 0); i++) {
  //       final row = allRows.values![i];
  //       if (row.isNotEmpty && row[0].toString() == invoiceData['invoiceId']) {
  //         rowIndex = i + 1;
  //         oldRow = row;
  //         break;
  //       }
  //     }
  //
  //     if (rowIndex == -1) {
  //       throw Exception("Invoice ID not found: ${invoiceData['invoiceId']}");
  //     }
  //
  //     // 3. Merge values
  //     final mergedRow = _prepareInvoiceUpdateRow(
  //       invoiceData,
  //       userId,
  //       headers,
  //       oldRow ?? [],
  //     );
  //
  //     // 4. Update row
  //     final valueRange = ValueRange.fromJson({
  //       "values": [mergedRow],
  //     });
  //
  //     await sheetsApi.spreadsheets.values.update(
  //       valueRange,
  //       spreadsheetId,
  //       "$targetSheetName!A$rowIndex:Z$rowIndex",
  //       valueInputOption: "USER_ENTERED",
  //     );
  //
  //     print("✅ Invoice updated at row $rowIndex");
  //   } catch (e, st) {
  //     print("❌ Error updating invoice: $e\n$st");
  //     throw Exception("Failed to update invoice: ${e.toString()}");
  //   }
  // }





  static Future<void> updateInvoice(
      Map<String, dynamic> invoiceData, String userId) async {
    print("🔄 Updating invoice in Google Sheet (Partial Update)...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);
      const targetSheetName = "Invoice";

      // 1. Get headers
      final headerResponse = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$targetSheetName!1:1",
      );

      if (headerResponse.values == null || headerResponse.values!.isEmpty) {
        throw Exception("No headers found in sheet");
      }

      final headers = headerResponse.values![0];

      // 2. Find row number AND Get Existing Data
      final allRows = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$targetSheetName!A:Z",
      );

      int rowIndex = -1;
      List<Object?>? existingRow; // ✅ જૂનો ડેટા સાચવવા માટે

      for (int i = 1; i < (allRows.values?.length ?? 0); i++) {
        final row = allRows.values![i];
        if (row.isNotEmpty && row[0].toString() == invoiceData['invoiceId']) {
          rowIndex = i + 1; // Google Sheets is 1-based
          existingRow = row; // ✅ આખી રો (Row) નો ડેટા લઈ લીધો
          break;
        }
      }

      if (rowIndex == -1) {
        throw Exception("Invoice ID not found: ${invoiceData['invoiceId']}");
      }

      print("🎯 Found invoice at row $rowIndex");

      // 3. Build complete row data (Merge Logic)
      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
      List<dynamic> rowData = [];

      for (int i = 0; i < headers.length; i++) {
        String header = headers[i].toString();
        String headerLower = header.toLowerCase().trim();

        // ✅ Get Existing Value from Sheet
        String existingValue = "";
        if (existingRow != null && i < existingRow.length) {
          existingValue = existingRow[i]?.toString() ?? "";
        }

        // ✅ Get New Value from Input Map
        String? newValue;

        if (headerLower.contains('invoiceid')) {
          newValue = invoiceData['invoiceId']?.toString();
        } else if (headerLower.contains('customerid')) {
          newValue = invoiceData['customerId']?.toString();
        } else if (headerLower.contains('customername')) {
          newValue = invoiceData['customerName']?.toString();
        } else if (headerLower.contains('customeremail')) {
          newValue = invoiceData['customerEmail']?.toString();
        } else if (headerLower == 'mobile') {
          newValue = invoiceData['mobile']?.toString();
        } else if (headerLower.contains('customeraddress')) {
          newValue = invoiceData['customerAddress']?.toString();
        } else if (headerLower.contains('issuedate')) {
          if (invoiceData['issueDate'] != null) {
            // ... date parsing logic ...
            // (તમારો ડેટ લોજિક અહીં વાપરી શકો છો)
            newValue = invoiceData['issueDate'].toString();
          }
        } else if (headerLower.contains('duedate')) {
          if (invoiceData['dueDate'] != null) {
            newValue = invoiceData['dueDate'].toString();
          }
        } else if (headerLower == 'subtotal') {
          newValue = invoiceData['subtotal']?.toString();
        } else if (headerLower.contains('gstamount')) {
          newValue = invoiceData['gstAmount']?.toString();
        } else if (headerLower.contains('totalamount')) {
          newValue = invoiceData['totalAmount']?.toString();
        } else if (headerLower.contains('receivedamount')) {
          // ✅ Amounts હંમેશા અપડેટ થવી જોઈએ
          newValue = invoiceData['receivedAmount']?.toString();
        } else if (headerLower.contains('pendingamount')) {
          newValue = invoiceData['pendingAmount']?.toString();
        } else if (headerLower == 'status') {
          newValue = invoiceData['status']?.toString();
        } else if (headerLower.contains('paymentmode')) {
          newValue = invoiceData['paymentMode']?.toString();
        } else if (headerLower.contains('updatedat')) {
          newValue = invoiceData['updatedAt']?.toString();
        } else if (headerLower == 'notes') {
          newValue = invoiceData['notes']?.toString();
        } else if (headerLower.contains('userid')) {
          newValue = userId;
        } else if (headerLower.contains('profit')) {
          newValue = invoiceData['profit']?.toString();
        } else if (headerLower.contains('invoicetype')) {
          newValue = invoiceData['invoiceType']?.toString();
        } else if (headerLower.contains('customerpan') || headerLower == 'pan') {
          newValue = invoiceData['customerPan']?.toString() ?? invoiceData['pan']?.toString();
        } else if (headerLower.contains('customergst') || headerLower == 'gst') {
          newValue = invoiceData['customerGst']?.toString() ?? invoiceData['gst']?.toString();
        }

        // ✅✅✅ MAIN FIX: MERGE LOGIC ✅✅✅
        // જો નવો ડેટા (newValue) null હોય, તો જૂનો ડેટા (existingValue) વાપરો
        // અપવાદ: જો આપણે explicitly કંઈક ખાલી કરવા માંગતા હોઈએ (પણ અત્યારે સેફ્ટી માટે જૂનો ડેટા રાખવો સારો)

        if (newValue != null) {
          rowData.add(newValue);
        } else {
          rowData.add(existingValue); // Keep old data if new is null
        }
      }

      print("📝 Final merged row: $rowData");

      // 4. Update row
      final valueRange = ValueRange.fromJson({
        "values": [rowData],
      });

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        "$targetSheetName!A$rowIndex:Z$rowIndex",
        valueInputOption: "USER_ENTERED",
      );

      print("✅ Invoice merged & updated successfully at row $rowIndex");
      _clearInvoiceListCache();
    } catch (e, st) {
      print("❌ Error updating invoice: $e\n$st");
      throw Exception("Failed to update invoice: ${e.toString()}");
    }
  }

  static List<dynamic> _prepareInvoiceUpdateRow(
      Map<String, dynamic> invoiceData,
      String userId,
      List<dynamic> headers,
      List<dynamic> sheetRow) {
    final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

    String _formatDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return "";
      try {
        if (value is DateTime) return _dateFormatter.format(value);
        return _dateFormatter.format(DateTime.parse(value.toString()));
      } catch (e) {
        return value.toString();
      }
    }

    List<dynamic> rowData = [];

    for (int j = 0; j < headers.length; j++) {
      String headerStr = headers[j].toString().toLowerCase();
      final newVal = invoiceData[headers[j].toString()]?.toString();

      if (headerStr.contains('issuedate')) {
        rowData.add(newVal?.isNotEmpty == true
            ? _formatDate(newVal)
            : (j < sheetRow.length ? sheetRow[j]?.toString() ?? "" : ""));
      } else if (headerStr.contains('duedate')) {
        rowData.add(newVal?.isNotEmpty == true
            ? _formatDate(newVal)
            : (j < sheetRow.length ? sheetRow[j]?.toString() ?? "" : ""));
      } else if (headerStr.contains('totalamount') ||
          headerStr.contains('subtotal') ||
          headerStr.contains('taxamount') ||
          headerStr.contains('discountamount')) {
        // ✅ Always overwrite with recalculated values
        rowData.add(newVal ?? "0");
      } else if (newVal != null && newVal.isNotEmpty) {
        rowData.add(newVal);
      } else if (j < sheetRow.length) {
        rowData.add(sheetRow[j]?.toString() ?? "");
      } else {
        rowData.add("");
      }
    }

    return rowData;
  }


  /// Clear cache for a specific invoice
  static void clearInvoiceItemCache(String invoiceId) {
    if (_invoiceItemCache.containsKey(invoiceId)) {
      _invoiceItemCache.remove(invoiceId);
      print("🗑️ Cleared cache for invoice: $invoiceId");
    }
  }

  /// Clear entire invoice items cache
  static void clearAllInvoiceItemCache() {
    _invoiceItemCache.clear();
    print("🗑️ Cleared all invoice item cache");
  }

// Update your existing updateInvoiceItems method - add cache clear at the end:
  static Future<void> updateInvoiceItems(
      String invoiceId, List<Map<String, dynamic>> items, String userId) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);
      const String itemSheet = "InvoiceItems";

      final headerRes = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$itemSheet!1:1",
      );
      final headers = headerRes.values![0];

      final allRows = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        itemSheet,
      );

      final values = allRows.values ?? [];
      final rowsToUpdate = <int>[];

      for (int i = 1; i < values.length; i++) {
        if (values[i].isNotEmpty &&
            values[i][0].toString().trim() == invoiceId) {
          rowsToUpdate.add(i + 1);
        }
      }

      for (int i = 0; i < rowsToUpdate.length; i++) {
        final sheetRow = values[rowsToUpdate[i] - 1];

        if (i < items.length) {
          final item = items[i];
          item['invoiceId'] = invoiceId;
          item['userId'] = userId;

          final rowValues = <String>[];
          for (int j = 0; j < headers.length; j++) {
            final key = headers[j].toString().trim();
            final newVal = item[key]?.toString();

            if (newVal != null && newVal.isNotEmpty) {
              rowValues.add(newVal);
            } else if (j < sheetRow.length) {
              rowValues.add(sheetRow[j]?.toString() ?? "");
            } else {
              rowValues.add("");
            }
          }

          final range =
              "$itemSheet!A${rowsToUpdate[i]}:${_columnLetter(headers.length)}${rowsToUpdate[i]}";

          await sheetsApi.spreadsheets.values.update(
            ValueRange(values: [rowValues]),
            spreadsheetId,
            range,
            valueInputOption: "USER_ENTERED",
          );
        } else {
          final range =
              "$itemSheet!A${rowsToUpdate[i]}:${_columnLetter(headers.length)}${rowsToUpdate[i]}";
          await sheetsApi.spreadsheets.values.clear(
            ClearValuesRequest(),
            spreadsheetId,
            range,
          );
        }
      }

      if (items.length > rowsToUpdate.length) {
        for (int i = rowsToUpdate.length; i < items.length; i++) {
          final item = items[i];
          item['invoiceId'] = invoiceId;
          item['userId'] = userId;

          final rowValues = headers.map((h) {
            final key = h.toString().trim();
            return item[key]?.toString() ?? "";
          }).toList();

          await sheetsApi.spreadsheets.values.append(
            ValueRange(values: [rowValues]),
            spreadsheetId,
            itemSheet,
            valueInputOption: "USER_ENTERED",
          );
        }
      }

      print("✅ InvoiceItems updated for $invoiceId");

      // ✅ CRITICAL: Clear cache after successful update
      clearInvoiceItemCache(invoiceId);
      print("✅ Cache cleared after update");

    } catch (e, st) {
      print("❌ Error in updateInvoiceItems: $e\n$st");
      rethrow;
    }
  }



// 🔹 Helper to convert column index → Excel letter
  static String _columnLetter(int colIndex) {
    var dividend = colIndex;
    var columnName = '';
    while (dividend > 0) {
      var modulo = (dividend - 1) % 26;
      columnName = String.fromCharCode(65 + modulo) + columnName;
      dividend = ((dividend - modulo) ~/ 26);
    }
    return columnName;
  }


  static Future<void> updateStockAfterInvoice(List<InvoiceItem> invoiceItems) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Fetch all stock rows once
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$itemSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        throw Exception("Stock sheet is empty");
      }

      final headers = response.values![0];
      final itemIdIndex = headers.indexOf("itemId");
      final stockIndex = headers.indexOf("currentStock");
      final userIdIndex = headers.indexOf("userId");

      if (itemIdIndex == -1 || stockIndex == -1 || userIdIndex == -1) {
        throw Exception("Missing required columns in Stock sheet");
      }

      for (var item in invoiceItems) {
        int? rowToUpdate;
        double currentStock = 0.0;

        // Find row for this itemId + userId
        for (int i = 1; i < response.values!.length; i++) {
          final row = response.values![i];
          if (row.length > itemIdIndex &&
              row[itemIdIndex].toString() == item.itemId.toString() &&
              row[userIdIndex].toString() == AppConstants.userId) {
            rowToUpdate = i + 1; // rows are 1-based
            if (row.length > stockIndex) {
              currentStock = double.tryParse(row[stockIndex].toString().replaceAll(',', '.')) ?? 0.0;
            }
            break;
          }
        }

        if (rowToUpdate == null) {
          print("⚠️ Item ${item.itemId} not found in stock sheet.");
          continue;
        }

        final newStock = currentStock - item.quantity;
        if (newStock < 0) {
          print("⚠️ Stock for item ${item.itemId} would go negative, forcing 0.");
        }

        final range =
            "$itemSheetName!${String.fromCharCode(65 + stockIndex)}$rowToUpdate";
        final valueRange = ValueRange.fromJson({
          "values": [
            [newStock < 0 ? 0 : newStock] // prevent negative stock
          ]
        });

        await sheetsApi.spreadsheets.values.update(
          valueRange,
          spreadsheetId,
          range,
          valueInputOption: "USER_ENTERED",
        );

        print("✅ Stock updated (Invoice): ${item.itemId} → $newStock (was $currentStock)");
      }
    } catch (e) {
      print("❌ Error updating stock after invoice: $e");
    }
  }

  static Future<List<InvoiceItem>> getInvoiceItems({String? invoiceId}) async {
    print("🔄 Fetching invoice items from Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get all rows from InvoiceItem sheet
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$invoiceItemSheetName!A:Z", // adjust range as needed
      );

      if (response.values == null || response.values!.isEmpty) {
        print("⚠️ No invoice items found in sheet");
        return [];
      }

      // First row = headers
      final headers = response.values!.first.map((h) => h.toString()).toList();
      final rows = response.values!.skip(1); // skip header row

      print("✅ Headers: $headers");
      List<InvoiceItem> items = [];

      for (var row in rows) {
        Map<String, dynamic> rowMap = {};
        for (int i = 0; i < headers.length; i++) {
          if (i < row.length) {
            rowMap[headers[i]] = row[i];
          }
        }

        try {
          final item = InvoiceItem.fromJson(rowMap);

          // ✅ If filtering by invoiceId
          if (invoiceId == null || item.invoiceId == invoiceId) {
            items.add(item);
          }
        } catch (e) {
          print("❌ Error parsing invoice item row: $rowMap");
          print("Error: $e");
        }
      }

      print("✅ Loaded ${items.length} invoice items");
      return items;
    } catch (e) {
      print("❌ Error fetching invoice items: $e");
      throw Exception("Failed to fetch invoice items: ${e.toString()}");
    }
  }

  /// Returns true if status updated, false if invoiceId not found.
  static Future<bool> updateInvoiceStatus(
      String invoiceId, String newStatus, {
        String? sheetName,
      }) async {
    final targetSheetName = sheetName ?? invoiceSheetName;
    print("🔄 updateInvoiceStatus -> sheet: $targetSheetName, invoiceId: $invoiceId, newStatus: $newStatus");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // 1) Read header row
      final headerResponse = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$targetSheetName!1:1",
      );

      if (headerResponse.values == null || headerResponse.values!.isEmpty) {
        print("❌ Couldn't read headers from sheet $targetSheetName");
        throw Exception("No headers found in $targetSheetName");
      }

      final rawHeaders = headerResponse.values![0];
      final headers = rawHeaders.map((h) => h.toString()).toList();
      print("📋 Headers: $headers");

      // 2) Normalize header strings for searching
      List<String> normalized = headers
          .map((h) => h.toString().toLowerCase().replaceAll(RegExp(r'\s+'), ''))
          .toList();

      // 3) Find invoiceId column index (heuristic)
      int invoiceIdIndex = -1;
      for (int i = 0; i < normalized.length; i++) {
        final h = normalized[i];
        if ((h.contains('invoice') && h.contains('id')) ||
            h == 'invoiceid' ||
            h == 'invoice') {
          invoiceIdIndex = i;
          break;
        }
      }
      // fallback: try 'id' column
      if (invoiceIdIndex == -1) {
        for (int i = 0; i < normalized.length; i++) {
          if (normalized[i] == 'id') {
            invoiceIdIndex = i;
            break;
          }
        }
      }
      // last fallback: assume first column
      if (invoiceIdIndex == -1) {
        print("⚠️ invoiceId column not detected - falling back to first column (index 0)");
        invoiceIdIndex = 0;
      }

      // 4) Find status column index, if missing we'll append it
      int statusIndex = -1;
      for (int i = 0; i < normalized.length; i++) {
        final h = normalized[i];
        if (h.contains('status') || h.contains('state') || h.contains('paymentstatus')) {
          statusIndex = i;
          break;
        }
      }

      bool appendedStatusHeader = false;
      if (statusIndex == -1) {
        // Append a 'status' header to header row so we can update that cell later
        final newHeaders = List<dynamic>.from(headers)..add('status');
        final lastColLetter = _columnLetter(newHeaders.length);
        final updateRange = "$targetSheetName!A1:${lastColLetter}1";
        await sheetsApi.spreadsheets.values.update(
          ValueRange.fromJson({"values": [newHeaders]}),
          spreadsheetId,
          updateRange,
          valueInputOption: "USER_ENTERED",
        );
        print("ℹ️ Appended 'status' header at column ${newHeaders.length} (range: $updateRange)");
        statusIndex = newHeaders.length - 1;
        appendedStatusHeader = true;

        // Update local variables so we can continue. Also update headers/normalized for logging.
        headers.add('status');
        normalized.add('status');
      } else {
        print("🔎 status column detected at index $statusIndex (header: ${headers[statusIndex]})");
      }

      // 5) Read full sheet to find row with invoiceId
      final allRowsResp = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$targetSheetName!A:Z",
      );
      final allRows = allRowsResp.values ?? [];
      if (allRows.isEmpty) {
        print("❌ Sheet has no rows.");
        return false;
      }

      // Normalize the search key
      final normInvoiceId = invoiceId.toString().trim();

      int foundRow = -1; // 1-based row number in spreadsheet
      // First try to match using invoiceIdIndex column (fast and preferred)
      for (int r = 1; r < allRows.length; r++) {
        final row = allRows[r];
        String cellValue = '';
        if (row.length > invoiceIdIndex) {
          cellValue = row[invoiceIdIndex]?.toString()?.trim() ?? '';
        }
        if (cellValue.isNotEmpty && (cellValue == normInvoiceId || cellValue.replaceAll('"', '') == normInvoiceId)) {
          foundRow = r + 1; // spreadsheet rows are 1-based
          break;
        }
      }

      // If not found in column, scan full rows (tolerant search)
      if (foundRow == -1) {
        print("ℹ️ Not found in invoiceId column, scanning rows for a match...");
        for (int r = 1; r < allRows.length; r++) {
          final row = allRows[r];
          bool match = false;
          for (int c = 0; c < row.length; c++) {
            final cell = row[c]?.toString()?.trim() ?? '';
            if (cell.isEmpty) continue;
            // exact or contained (trim quotes)
            if (cell == normInvoiceId || cell.replaceAll('"', '') == normInvoiceId || cell.contains(normInvoiceId)) {
              match = true;
              break;
            }
          }
          if (match) {
            foundRow = r + 1;
            break;
          }
        }
      }

      if (foundRow == -1) {
        print("⚠️ Invoice '$invoiceId' not found in sheet '$targetSheetName'. No update performed.");
        return false;
      }

      print("✅ Found invoice '$invoiceId' at sheet row $foundRow");

      // 6) Update only the status cell
      final statusColLetter = _columnLetter(statusIndex + 1); // 1-based column -> letter
      final statusRange = "$targetSheetName!$statusColLetter$foundRow";

      // If we appended the status header this run, ensure we update the header values were accepted before updating row.
      // (small safety delay rarely needed; usually not required)

      final valueRange = ValueRange.fromJson({
        "values": [
          [newStatus]
        ],
      });

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        statusRange,
        valueInputOption: "USER_ENTERED",
      );

      print("✅ Updated status for invoice '$invoiceId' -> '$newStatus' at $statusRange");
      _clearInvoiceListCache();
      return true;
    } catch (e, st) {
      print("❌ Error updating invoice status: $e\n$st");
      rethrow;
    }
  }



  ///Challan
  static Future<void> addChallan(dynamic challanData, String userId) async {
    print("🔄 Adding Challan to Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // ✅ Define expected headers for the Challan sheet
      final expectedHeaders = [
        'challanId',
        'customerId',
        'customerName',
        'customerEmail',
        'customerPhone',
        'customerAddress',
        'challanDate',
        'items',
        'subtotal',
        'gstRate',
        'gstAmount',
        'totalAmount',
        'status',
        'statusProgress',
        'notes',
        'userId',
        'createdAt',
        'updatedAt',
      ];

      // ✅ Ensure sheet and headers exist (auto-create if missing)
      final headers = await _getOrCreateHeaders(
        sheetsApi,
        challanSheetName,
        expectedHeaders,
      );

      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');

      // Safe date formatting
      String _formatDate(dynamic value) {
        if (value == null || value.toString().isEmpty) return "";
        try {
          if (value is DateTime) return _dateFormatter.format(value);
          return _dateFormatter.format(DateTime.parse(value.toString()));
        } catch (e) {
          return value.toString();
        }
      }

      // Normalize keys for case-insensitive access
      Map<String, dynamic> _normalize(Map<String, dynamic> data) {
        return {
          for (var entry in data.entries)
            entry.key.toString().trim().toLowerCase(): entry.value
        };
      }

      // Prepare all rows
      List<Map<String, dynamic>> rowsToSend = [];

      if (challanData is Map<String, dynamic>) {
        if (challanData.containsKey('items') && challanData['items'] is List) {
          challanData['items'] = jsonEncode(challanData['items']);
        }

        challanData['challanDate'] = _formatDate(challanData['challanDate']);
        challanData['createdAt'] = _formatDate(DateTime.now());
        challanData['updatedAt'] = _formatDate(DateTime.now());
        challanData['userId'] = userId;

        rowsToSend.add(challanData);
      } else if (challanData is List<Challan>) {
        rowsToSend = challanData.map((chal) {
          final map = chal.toMap();

          if (map.containsKey('items') && map['items'] is List) {
            map['items'] = jsonEncode(map['items']);
          }

          map['challanDate'] = _formatDate(map['challanDate']);
          map['createdAt'] = _formatDate(DateTime.now());
          map['updatedAt'] = _formatDate(DateTime.now());
          map['userId'] = userId;

          return map;
        }).toList();
      }

      // Convert all rows to header-aligned data
      List<List<dynamic>> values = [];
      for (var row in rowsToSend) {
        final normalized = _normalize(row);
        List<dynamic> rowData = [];
        for (var header in headers) {
          final key = header.toString().trim().toLowerCase();
          rowData.add(normalized[key]?.toString() ?? '');
        }
        values.add(rowData);
      }

      print("🧾 Prepared Challan rows: $values");

      // Append to Google Sheet
      final valueRange = ValueRange.fromJson({"values": values});
      await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        "$challanSheetName!A:Z",
        valueInputOption: "USER_ENTERED",
      );

      print("✅ Challan(s) added successfully to Google Sheet");
    } catch (e) {
      print("❌ Error adding Challan: $e");
      throw Exception("Failed to add Challan: ${e.toString()}");
    }
  }


  static Future<void> addChallanItem(Map<String, dynamic> challanData, String userId) async {
    print("🔄 Adding challan item to Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Date formatter
      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

      // Get header row
      final headerResponse = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanItemSheetName!1:1",
      );

      if (headerResponse.values == null || headerResponse.values!.isEmpty) {
        throw Exception("No header row found in sheet '$challanItemSheetName'");
      }

      final headers = headerResponse.values![0];
      print("ChallanItems headers: $headers");

      // Prepare row data based on exact header names
      List<dynamic> rowData = [];

      for (var header in headers) {
        final headerName = header.toString();
        final headerNameLower = headerName.toLowerCase();

        if (headerNameLower.contains('userid')) {
          // Add userId
          rowData.add(userId);
        }
        else if (headerNameLower.contains('date')) {
          // Handle date field
          dynamic dateValue = challanData['challanDate'] ??
              challanData['challainDate'] ??
              challanData['date'] ??
              DateTime.now();

          try {
            if (dateValue is DateTime) {
              rowData.add(_dateFormatter.format(dateValue));
            } else if (dateValue is String) {
              rowData.add(_dateFormatter.format(DateTime.parse(dateValue)));
            } else {
              rowData.add(_dateFormatter.format(DateTime.now()));
            }
          } catch (e) {
            rowData.add(_dateFormatter.format(DateTime.now()));
          }
        }
        else {
          // Add other fields
          var value = '';
          for (var key in challanData.keys) {
            if (key.toLowerCase() == headerNameLower) {
              value = challanData[key]?.toString() ?? '';
              break;
            }
          }
          rowData.add(value);
        }
      }

      print("Prepared challan item row: $rowData");

      // Append row
      final valueRange = ValueRange.fromJson({
        "values": [rowData],
      });

      final response = await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        "$challanItemSheetName!A:Z",
        valueInputOption: "USER_ENTERED",
      );

      if (response.updates?.updatedRows != null) {
        print("✅ Challan item added successfully. Rows affected: ${response.updates!.updatedRows}");
      } else {
        print("✅ Challan item added successfully.");
      }
    } catch (e) {
      print("❌ Error adding challan item: $e");
      throw Exception("Failed to add challan item: ${e.toString()}");
    }
  }

  ///at atimr all Data
  static Future<void> addChallanItemsBatch(
      List<Map<String, dynamic>> itemsData,
      String userId,
      ) async {
    print("🔄 Adding ${itemsData.length} challan items in batch...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      final expectedHeaders = [
        'challanId',
        'customerId',
        'itemId',
        'itemName',
        'description',
        'quantity',
        'price',
        'challanDate',
        'gstRate',
        'gstAmount',
        'amountWithGst',
        'totalPrice',
        'unit',
        'userId',
      ];

      // ✅ Ensure headers exist
      final headers = await _ensureHeadersExist(
        sheetsApi,
        challanItemSheetName,
        expectedHeaders,
      );

      List<List<dynamic>> rows = [];
      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

      for (var itemData in itemsData) {
        List<dynamic> rowData = [];

        for (var header in headers) {
          final headerName = header.toString();
          final headerNameLower = headerName.toLowerCase();

          if (headerNameLower.contains('userid')) {
            rowData.add(userId);
          } else if (headerNameLower.contains('date')) {
            dynamic dateValue = itemData['challanDate'] ??
                itemData['challainDate'] ??
                itemData['date'] ??
                DateTime.now();

            try {
              if (dateValue is DateTime) {
                rowData.add(_dateFormatter.format(dateValue));
              } else if (dateValue is String) {
                rowData.add(_dateFormatter.format(DateTime.parse(dateValue)));
              } else {
                rowData.add(_dateFormatter.format(DateTime.now()));
              }
            } catch (e) {
              rowData.add(_dateFormatter.format(DateTime.now()));
            }
          } else {
            var value = '';
            if (itemData.containsKey(headerName)) {
              value = itemData[headerName]?.toString() ?? '';
            } else {
              for (var key in itemData.keys) {
                if (key.toString().toLowerCase() == headerNameLower) {
                  value = itemData[key]?.toString() ?? '';
                  break;
                }
              }
            }
            rowData.add(value);
          }
        }

        rows.add(rowData);
      }

      final valueRange = ValueRange.fromJson({"values": rows});

      await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        "$challanItemSheetName!A:Z",
        valueInputOption: "USER_ENTERED",
      );

      print("✅ ${rows.length} challan items added successfully");
    } catch (e) {
      print("❌ Error adding challan items: $e");
      rethrow;
    }
  }


  static Future<void> updateStockAfterDispatch(List<ChallanItem> challanItems) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Fetch all stock rows once for efficiency
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$itemSheetName!A:Z", // whole sheet
      );

      if (response.values == null || response.values!.isEmpty) {
        throw Exception("Stock sheet is empty");
      }

      final headers = response.values![0];
      final itemIdIndex = headers.indexOf("itemId");
      final stockIndex = headers.indexOf("currentStock"); // ✅ FIXED
      final userIdIndex = headers.indexOf("userId");

      if (itemIdIndex == -1 || stockIndex == -1 || userIdIndex == -1) {
        throw Exception("Missing required columns in Stock sheet");
      }

      for (var item in challanItems) {
        int? rowToUpdate;
        double currentStock = 0.0;

        // Find row for this itemId + userId
        for (int i = 1; i < response.values!.length; i++) {
          final row = response.values![i];
          if (row.length > itemIdIndex &&
              row[itemIdIndex].toString() == item.itemId.toString() &&
              row[userIdIndex].toString() == AppConstants.userId) {
            rowToUpdate = i + 1; // rows are 1-based
            if (row.length > stockIndex) {
              currentStock = double.tryParse(row[stockIndex].toString().replaceAll(',', '.')) ?? 0.0;
            }
            break;
          }
        }

        if (rowToUpdate == null) {
          print("⚠️ Item ${item.itemId} not found in stock sheet.");
          continue;
        }

        final newStock = currentStock - item.quantity;
        if (newStock < 0) {
          print("⚠️ Stock for item ${item.itemId} would go negative, forcing 0.");
        }

        final range =
            "$itemSheetName!${String.fromCharCode(65 + stockIndex)}$rowToUpdate";
        final valueRange = ValueRange.fromJson({
          "values": [
            [newStock < 0 ? 0 : newStock] // prevent negative stock
          ]
        });

        await sheetsApi.spreadsheets.values.update(
          valueRange,
          spreadsheetId,
          range,
          valueInputOption: "USER_ENTERED",
        );

        print("✅ Stock updated: ${item.itemId} → $newStock (was $currentStock)");
      }
    } catch (e) {
      print("❌ Error updating stock after challan: $e");
    }
  }


  static Future<List<Challan>> getChallans() async {
    print("🔄 Fetching challans from Google Sheets...");

    try {
      final client = await _getAuthClient(); // ✅ make sure you already implemented
      final sheetsApi = SheetsApi(client);

      // Fetch all challan rows
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanSheetName!A:Z", // whole sheet
      );

      if (response.values == null || response.values!.length <= 1) {
        print("❌ No challans found in sheet.");
        return <Challan>[];
      }

      // Extract headers
      final headers = response.values![0].map((h) => h.toString().trim()).toList();
      print("✅ Headers: $headers");

      List<Challan> challans = [];

      // Iterate rows
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];

        // Map each header → value
        Map<String, dynamic> challanMap = {};
        for (int j = 0; j < headers.length; j++) {

          try {
            Challan challan = Challan.fromMap(challanMap); // ✅ use your model parser
            challans.add(challan);
            print("Processed challan: ${challan.challanId} - ${challan.customerName}");
          } catch (e) {
            print("⚠️ Error parsing challan row $i: $e");
            print("Row data: $challanMap");
          }
        }}

      print("✅ Successfully parsed ${challans.length} challans from Google Sheets");
      return challans;
    } catch (e) {
      print("❌ Error in getChallans(): $e");
      rethrow;
    }
  }

  static Future<List<Challan>> getChallansList() async {
    print("🔄 Fetching challans from Google Sheets...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // ✅ Check if sheet exists first
      final sheetExists = await _sheetExists(sheetsApi, challanSheetName);

      if (!sheetExists) {
        print("⚠️ Challan sheet doesn't exist yet, it will be created on first save");
        return <Challan>[];
      }

      // Fetch all challan rows
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanSheetName!A:Z",
      );

      if (response.values == null || response.values!.length <= 1) {
        print("ℹ️ No challans found in sheet.");
        return <Challan>[];
      }

      // Extract headers from first row
      final headers = response.values![0].map((h) => h.toString().trim()).toList();
      print("✅ Headers: $headers");

      List<Challan> challans = [];

      // Iterate rows (skip header)
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];

        // ✅ Skip completely empty rows
        if (row.isEmpty || row[0].toString().trim().isEmpty) {
          continue;
        }

        // ✅ Build map header → value
        Map<String, dynamic> challanMap = {};
        for (int j = 0; j < headers.length && j < row.length; j++) {
          challanMap[headers[j]] = row[j].toString();
        }

        try {
          Challan challan = Challan.fromMap(challanMap);
          challans.add(challan);
          print("Processed challan: ${challan.challanId} - ${challan.customerName}");
        } catch (e) {
          print("⚠️ Error parsing challan row $i: $e");
          print("Row data: $challanMap");
        }
      }

      print("✅ Successfully parsed ${challans.length} challans from Google Sheets");
      return challans;
    } catch (e) {
      print("⚠️ Error in getChallansList(): $e");
      // Don't throw, return empty list instead
      return <Challan>[];
    }
  }

  /// Clear specific cache for challan items
  static void clearChallanItemCache(String challanId) {
    final cacheKey = 'challan_items_$challanId';
    _itemCache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
    print("🗑️ Cleared cache for challan: $challanId");
  }

  /// Check if cache is valid
  static bool _isCacheValid(String cacheKey) {
    if (!_itemCache.containsKey(cacheKey) || !_cacheTimestamps.containsKey(cacheKey)) {
      return false;
    }

    final cacheTime = _cacheTimestamps[cacheKey]!;
    final now = DateTime.now();
    final isValid = now.difference(cacheTime) < _cacheValidDuration;

    if (!isValid) {
      _itemCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
    }

    return isValid;
  }

  ///at one Time new
  static Future<void> updateChallanStatusBatch(
      List<String> challanIds, String status, String userId) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // 1. Get spreadsheet metadata (to find sheetId for "Challan" tab)
      final spreadsheet =
      await sheetsApi.spreadsheets.get(spreadsheetId);
      final sheet = spreadsheet.sheets!
          .firstWhere((s) => s.properties?.title == challanSheetName);
      final sheetId = sheet.properties!.sheetId!; // <-- integer id

      // 2. Get all challans
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        throw Exception("Challan sheet is empty");
      }

      final headers = response.values![0];
      final challanIdIndex = headers.indexOf("challanId");
      final statusIndex = headers.indexOf("status");
      final userIdIndex = headers.indexOf("userId");

      if (challanIdIndex == -1 || statusIndex == -1 || userIdIndex == -1) {
        throw Exception("Required columns missing in Challan sheet");
      }

      List<Map<String, dynamic>> requests = [];

      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length > challanIdIndex &&
            challanIds.contains(row[challanIdIndex].toString()) &&
            row.length > userIdIndex &&
            row[userIdIndex].toString() == userId) {
          int rowIndex = i; // 0-based index

          requests.add({
            "updateCells": {
              "range": {
                "sheetId": sheetId, // ✅ correct integer sheetId
                "startRowIndex": rowIndex,
                "endRowIndex": rowIndex + 1,
                "startColumnIndex": statusIndex,
                "endColumnIndex": statusIndex + 1,
              },
              "rows": [
                {
                  "values": [
                    {"userEnteredValue": {"stringValue": status}}
                  ]
                }
              ],
              "fields": "userEnteredValue",
            }
          });
        }
      }

      if (requests.isEmpty) {
        print("⚠️ No challans found to update");
        return;
      }

      // 3. Build batch request
      final batchRequest = BatchUpdateSpreadsheetRequest.fromJson({
        "requests": requests,
      });

      await sheetsApi.spreadsheets.batchUpdate(batchRequest, spreadsheetId);

      print("✅ ${requests.length} challans updated to $status in batch.");
    } catch (e) {
      print("❌ Error in batch challan update: $e");
      rethrow;
    }
  }



  /// Fixed updateChallan function in GoogleSheetService
// Modified updateChallan function in GoogleSheetService to preserve GST
  static Future<void> updateChallan(Map<String, dynamic> challanData, String userId) async {
    print("🔄 Updating Challan in Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get all challans
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        throw Exception("❌ Challan sheet is empty");
      }

      final headers = response.values![0];
      final challanIdIndex = headers.indexOf("challanId");
      final userIdIndex = headers.indexOf("userId");

      if (challanIdIndex == -1 || userIdIndex == -1) {
        throw Exception("❌ Missing challanId or userId column in sheet");
      }

      int? rowToUpdate;
      List<Object?> existingRow = [];

      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length > challanIdIndex &&
            row[challanIdIndex].toString() == challanData["challanId"].toString() &&
            row[userIdIndex].toString() == userId) {
          rowToUpdate = i + 1;
          existingRow = row; // Store existing row data
          break;
        }
      }

      if (rowToUpdate == null) {
        throw Exception("❌ Challan not found for update (id: ${challanData["challanId"]})");
      }

      // Get existing GST values from the current row
      final gstRateIndex = headers.indexWhere((h) => h.toString().toLowerCase() == 'gstrate');
      final gstAmountIndex = headers.indexWhere((h) => h.toString().toLowerCase() == 'gstamount');

      String existingGstRate = '';
      String existingGstAmount = '';

      if (gstRateIndex != -1 && existingRow.length > gstRateIndex) {
        existingGstRate = existingRow[gstRateIndex]?.toString() ?? '';
      }
      if (gstAmountIndex != -1 && existingRow.length > gstAmountIndex) {
        existingGstAmount = existingRow[gstAmountIndex]?.toString() ?? '';
      }

      // Build normalized data with all required fields
      Map<String, dynamic> normalized = {};

      for (var header in headers) {
        String key = header.toString().trim().toLowerCase();

        switch (key) {
          case 'challanid':
            normalized[key] = challanData["challanId"] ?? '';
            break;
          case 'customername':
            normalized[key] = challanData["customerName"] ?? '';
            break;
          case 'customeremail':
            normalized[key] = challanData["customerEmail"] ?? '';
            break;
          case 'customerphone':
            normalized[key] = challanData["customerPhone"] ?? '';
            break;
          case 'customeraddress':
            normalized[key] = challanData["customerAddress"] ?? '';
            break;
          case 'challandate':
            normalized[key] = challanData["challanDate"] ?? '';
            break;
          case 'subtotal':
            normalized[key] = challanData["subtotal"] ?? 0;
            break;
          case 'gstrate':
          // Preserve existing GST rate if not explicitly changed
            if (challanData.containsKey("preserveGST") && challanData["preserveGST"] == true) {
              normalized[key] = existingGstRate;
            } else {
              double subtotal = double.tryParse(challanData["subtotal"]?.toString() ?? "0") ?? 0;
              double gstAmount = double.tryParse(challanData["gstAmount"]?.toString() ?? "0") ?? 0;
              double gstRate = subtotal > 0 ? (gstAmount / subtotal * 100) : 0;
              normalized[key] = gstRate.toStringAsFixed(2);
            }
            break;
          case 'gstamount':
          // Preserve existing GST amount if not explicitly changed
            if (challanData.containsKey("preserveGST") && challanData["preserveGST"] == true) {
              normalized[key] = existingGstAmount;
            } else {
              normalized[key] = challanData["gstAmount"] ?? 0;
            }
            break;
          case 'totalamount':
            normalized[key] = challanData["totalAmount"] ?? 0;
            break;
          case 'status':
            normalized[key] = challanData["status"] ?? 'Pending';
            break;
          case 'statusprogress':
            normalized[key] = challanData["statusProgress"] ?? 'InProgress';
            break;
          case 'userid':
            normalized[key] = userId;
            break;
          default:
          // Keep existing value for unknown columns
            int existingIndex = headers.indexWhere((h) => h.toString().toLowerCase() == key);
            if (existingIndex != -1 && existingRow.length > existingIndex) {
              normalized[key] = existingRow[existingIndex]?.toString() ?? '';
            } else {
              normalized[key] = '';
            }
            break;
        }
      }

      // Build row data in the same order as headers
      List<dynamic> rowData = [];
      for (var header in headers) {
        final key = header.toString().trim().toLowerCase();
        rowData.add(normalized[key]?.toString() ?? '');
      }

      final range = "$challanSheetName!A$rowToUpdate:${String.fromCharCode(65 + headers.length - 1)}$rowToUpdate";

      final valueRange = ValueRange(
        values: [rowData],
      );

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: "USER_ENTERED",
      );

      print("✅ Challan updated successfully at row $rowToUpdate");
      print("📊 GST Rate: ${normalized['gstrate']}, GST Amount: ${normalized['gstamount']}");

    } catch (e) {
      print("❌ Error updating Challan: $e");
      rethrow;
    }
  }


  static Future<void> updateChallanItems(
      String challanId, List<Map<String, dynamic>> items, String userId) async {
    print("🔄 Updating Challan Items in Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get current sheet data
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanItemSheetName!A:Z", // Make sure to get all columns A to Z
      );

      if (response.values == null || response.values!.isEmpty) {
        // Sheet is empty, just add new items
        for (var item in items) {
          await addChallanItem({...item, "challanId": challanId}, userId);
        }
        return;
      }

      final headers = response.values![0];
      print("Sheet headers: $headers"); // Debug print

      final challanIdIndex = headers.indexOf("challanId");

      if (challanIdIndex == -1) {
        throw Exception("❌ Missing challanId column");
      }

      // Build new sheet data (keep all items except for this challanId)
      List<List<Object?>> newSheetData = [];
      newSheetData.add(headers); // Add headers first

      // Add all rows that DON'T belong to our challanId
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length > challanIdIndex &&
            row[challanIdIndex].toString() != challanId) {
          newSheetData.add(row);
        }
      }

      // Add our new items to the data
      for (var item in items) {
        List<Object?> newRow = [];
        for (var header in headers) {
          String key = header.toString().trim().toLowerCase();

          switch (key) {
            case 'challanid':
              newRow.add(item['challanId'] ?? challanId);
              break;
            case 'customerid':
              newRow.add(item['customerId'] ?? '');
              break;
            case 'itemid':
              newRow.add(item['itemId'] ?? '');
              break;
            case 'itemname':
              newRow.add(item['itemName'] ?? '');
              break;
            case 'description':
              newRow.add(item['description'] ?? '');
              break;
            case 'quantity':
              newRow.add(item['quantity'] ?? '0');
              break;
            case 'price':
              newRow.add(item['price'] ?? '0');
              break;
            case 'challandate':
              newRow.add(item['challanDate'] ?? '');
              break;
            case 'gstrate':
              newRow.add(item['gstRate'] ?? '0');
              break;
            case 'gstamount':
              newRow.add(item['gstAmount'] ?? '0');
              break;
            case 'amountwithgst':
              newRow.add(item['amountWithGst'] ?? '0');
              break;
            case 'totalprice':
              newRow.add(item['totalPrice'] ?? '0');
              break;
            case 'unit':
              newRow.add(item['unit'] ?? '');
              break;
            case 'userid':
              newRow.add(item['userId'] ?? userId);
              break;
            default:
              newRow.add('');
              break;
          }
        }
        newSheetData.add(newRow);
        print("Added row: $newRow"); // Debug print
      }

      // Clear the entire sheet
      await sheetsApi.spreadsheets.values.clear(
        ClearValuesRequest(),
        spreadsheetId,
        "$challanItemSheetName!A:Z",
      );

      // Write all data back to sheet
      if (newSheetData.length > 1) {
        final range = "$challanItemSheetName!A1:${String.fromCharCode(65 + headers.length - 1)}${newSheetData.length}";

        await sheetsApi.spreadsheets.values.update(
          ValueRange(values: newSheetData),
          spreadsheetId,
          range,
          valueInputOption: "USER_ENTERED",
        );
      }

      print("✅ Successfully updated ${items.length} challan items");

    } catch (e, stackTrace) {
      print("❌ Error updating Challan items: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

// Alternative method using append after clearing specific rows
  static Future<void> updateChallanItemsV2(
      String challanId, List<Map<String, dynamic>> items, String userId) async {
    print("🔄 Updating Challan Items (Method V2)...");

    try {
      // First, delete existing items for this challanId
      await deleteChallanItemsByChallanId(challanId);

      // Then add new items
      for (var item in items) {
        await addChallanItem({...item, "challanId": challanId}, userId);
      }

      print("✅ Successfully updated challan items using V2 method");

    } catch (e) {
      print("❌ Error in updateChallanItemsV2: $e");
      rethrow;
    }
  }


  // Add these batch update methods for better performance

  /// Batch update challan items (more efficient than individual updates)
  static Future<void> updateChallanItemsBatch(String challanId, List<Map<String, dynamic>> itemsData, String userId) async {
    try {
      print("🔄 Batch updating ${itemsData.length} items for challan: $challanId");

      // First, delete existing items for this challan
      await deleteChallanItems(challanId, userId);

      // Then insert all new items
      for (var itemData in itemsData) {
        await addChallanItem(itemData, userId);
      }

      // Clear cache to force refresh on next read
      clearChallanItemCache(challanId);

      print("✅ Batch update completed for challan: $challanId");

    } catch (e) {
      print("❌ Error in batch update: $e");
      throw e;
    }
  }

  // ✅ FIXED: Delete all items for a specific challan
  static Future<void> deleteChallanItems(String challanId, String userId) async {
    print("🗑️ Deleting all items for challan: $challanId");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get all challan items
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanItemSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        print("⚠️ Sheet is empty, nothing to delete");
        return;
      }

      final headers = response.values![0];
      final challanIdIndex = headers.indexOf("challanId");

      if (challanIdIndex == -1) {
        throw Exception("❌ challanId column not found in sheet");
      }

      // Find all rows that match this challanId
      List<int> rowsToDelete = [];
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length > challanIdIndex &&
            row[challanIdIndex].toString() == challanId) {
          rowsToDelete.add(i);
        }
      }

      if (rowsToDelete.isEmpty) {
        print("ℹ️ No items found for challan: $challanId");
        return;
      }

      print("Found ${rowsToDelete.length} rows to delete");

      // Get sheet ID for batch delete
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      int? sheetId;
      for (var sheet in spreadsheet.sheets ?? []) {
        if (sheet.properties?.title == challanItemSheetName) {
          sheetId = sheet.properties?.sheetId;
          break;
        }
      }

      if (sheetId == null) {
        throw Exception("❌ Could not find sheet ID for $challanItemSheetName");
      }

      // Delete rows in reverse order to maintain indices
      List<Request> deleteRequests = [];
      for (int rowIndex in rowsToDelete.reversed) {
        deleteRequests.add(
            Request()
              ..deleteDimension = (DeleteDimensionRequest()
                ..range = (DimensionRange()
                  ..sheetId = sheetId
                  ..dimension = 'ROWS'
                  ..startIndex = rowIndex  // 0-based for API
                  ..endIndex = rowIndex + 1))
        );
      }

      // Execute batch delete
      final batchRequest = BatchUpdateSpreadsheetRequest()
        ..requests = deleteRequests;

      await sheetsApi.spreadsheets.batchUpdate(
        batchRequest,
        spreadsheetId,
      );

      print("✅ Successfully deleted ${rowsToDelete.length} items for challan: $challanId");

      // Clear cache
      clearChallanItemCache(challanId);

    } catch (e, stackTrace) {
      print("❌ Error deleting challan items: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

// Helper method to delete challan items by challanId
  static Future<void> deleteChallanItemsByChallanId(String challanId) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanItemSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        return; // Nothing to delete
      }

      final headers = response.values![0];
      final challanIdIndex = headers.indexOf("challanId");

      if (challanIdIndex == -1) {
        return; // No challanId column
      }

      // Build filtered data (exclude rows matching challanId)
      List<List<Object?>> filteredData = [headers];

      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length <= challanIdIndex ||
            row[challanIdIndex].toString() != challanId) {
          filteredData.add(row);
        }
      }

      // Clear and rewrite sheet
      await sheetsApi.spreadsheets.values.clear(
        ClearValuesRequest(),
        spreadsheetId,
        "$challanItemSheetName!A:Z",
      );

      if (filteredData.length > 1) {
        await sheetsApi.spreadsheets.values.update(
          ValueRange(values: filteredData),
          spreadsheetId,
          "$challanItemSheetName!A${filteredData.length}",
          valueInputOption: "USER_ENTERED",
        );
      }

      print("🗑️ Deleted existing items for challanId: $challanId");

    } catch (e) {
      print("❌ Error deleting challan items: $e");
      rethrow;
    }
  }

  /// Delete the Challan row from the Challan sheet (by challanId). Call after deleting challan items.
  static Future<void> deleteChallanFromSheet(String challanId) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        print("⚠️ Challan sheet is empty, nothing to delete");
        return;
      }

      final headers = response.values![0].map((h) => h.toString().trim()).toList();
      final challanIdIndex = headers.indexWhere((h) => h.toLowerCase() == 'challanid');

      if (challanIdIndex == -1) {
        print("⚠️ challanId column not found in Challan sheet");
        return;
      }

      List<List<Object?>> filteredData = [response.values![0]];

      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length <= challanIdIndex ||
            row[challanIdIndex].toString().trim() != challanId) {
          filteredData.add(row);
        }
      }

      await sheetsApi.spreadsheets.values.clear(
        ClearValuesRequest(),
        spreadsheetId,
        "$challanSheetName!A:Z",
      );

      if (filteredData.length > 1) {
        await sheetsApi.spreadsheets.values.update(
          ValueRange(values: filteredData),
          spreadsheetId,
          "$challanSheetName!A1",
          valueInputOption: "USER_ENTERED",
        );
      }

      clearChallanItemCache(challanId);
      _challanCache.remove(challanId);
      print("🗑️ Deleted challan $challanId from Challan sheet");
    } catch (e) {
      print("❌ Error deleting challan from sheet: $e");
      rethrow;
    }
  }

  /// Delete all InvoiceItems rows for the given invoiceId from the InvoiceItems sheet.
  static Future<void> deleteInvoiceItemsFromSheet(String invoiceId) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$invoiceItemSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) return;

      final headers = response.values![0].map((h) => h.toString().trim()).toList();
      final invoiceIdIndex = headers.indexWhere((h) => h.toLowerCase() == 'invoiceid');
      if (invoiceIdIndex == -1) return;

      List<List<Object?>> filteredData = [response.values![0]];
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length <= invoiceIdIndex || row[invoiceIdIndex].toString().trim() != invoiceId) {
          filteredData.add(row);
        }
      }

      await sheetsApi.spreadsheets.values.clear(
        ClearValuesRequest(),
        spreadsheetId,
        "$invoiceItemSheetName!A:Z",
      );
      if (filteredData.length > 1) {
        await sheetsApi.spreadsheets.values.update(
          ValueRange(values: filteredData),
          spreadsheetId,
          "$invoiceItemSheetName!A1",
          valueInputOption: "USER_ENTERED",
        );
      }
      _invoiceItemCache.remove(invoiceId);
      print("🗑️ Deleted invoice items for invoiceId: $invoiceId");
    } catch (e) {
      print("❌ Error deleting invoice items from sheet: $e");
      rethrow;
    }
  }

  /// Soft delete the Invoice row: set isDeleted=1 and apply light red background.
  static Future<void> deleteInvoiceFromSheet(String invoiceId) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$invoiceSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) return;

      final headers = response.values![0].map((h) => h.toString().trim()).toList();
      final invoiceIdIndex = headers.indexWhere((h) => h.toLowerCase() == 'invoiceid');
      if (invoiceIdIndex == -1) return;

      // Find row index (1-based for sheet)
      int targetRowIndex = -1;
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length > invoiceIdIndex && row[invoiceIdIndex].toString().trim() == invoiceId) {
          targetRowIndex = i + 1; // 1-based row number
          break;
        }
      }
      if (targetRowIndex == -1) {
        print("⚠️ Invoice $invoiceId not found in sheet");
        return;
      }

      // Ensure isDeleted column exists
      int isDeletedColIndex = headers.indexWhere((h) => h.toLowerCase() == 'isdeleted');
      List<List<Object?>> allData = response.values!.map((r) => r.toList()).toList();

      if (isDeletedColIndex == -1) {
        // Add isDeleted column
        headers.add('isDeleted');
        allData[0] = headers;
        for (int i = 1; i < allData.length; i++) {
          if (allData[i].length < headers.length) {
            allData[i].add((i + 1 == targetRowIndex) ? '1' : '0');
          }
        }
        await sheetsApi.spreadsheets.values.update(
          ValueRange(values: allData),
          spreadsheetId,
          "$invoiceSheetName!A1",
          valueInputOption: "USER_ENTERED",
        );
        isDeletedColIndex = headers.length - 1;
      } else {
        // Update isDeleted cell to 1
        final rowIndex = targetRowIndex;
        final colLetter = _columnIndexToLetter(isDeletedColIndex);
        final range = "$invoiceSheetName!$colLetter$rowIndex";
        await sheetsApi.spreadsheets.values.update(
          ValueRange.fromJson({"values": [["1"]]}),
          spreadsheetId,
          range,
          valueInputOption: "USER_ENTERED",
        );
      }

      // Apply light red background to the row
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      int? invoiceSheetId;
      for (var sheet in spreadsheet.sheets ?? []) {
        if (sheet.properties?.title == invoiceSheetName) {
          invoiceSheetId = sheet.properties?.sheetId ?? 0;
          break;
        }
      }
      if (invoiceSheetId != null) {
        final cellData = CellData()
          ..userEnteredFormat = (CellFormat()
            ..backgroundColor = (Color()
              ..red = 1.0
              ..green = 0.86
              ..blue = 0.86));
        final repeatCellRequest = RepeatCellRequest()
          ..range = (GridRange()
            ..sheetId = invoiceSheetId
            ..startRowIndex = targetRowIndex - 1
            ..endRowIndex = targetRowIndex
            ..startColumnIndex = 0
            ..endColumnIndex = 26)
          ..cell = cellData
          ..fields = "userEnteredFormat.backgroundColor";

        final batchRequest = BatchUpdateSpreadsheetRequest()
          ..requests = [Request()..repeatCell = repeatCellRequest];

        await sheetsApi.spreadsheets.batchUpdate(batchRequest, spreadsheetId);
      }

      // Clear caches so invoice list refreshes
      _invoiceItemCache.remove(invoiceId);
      _cacheTimestamps.remove(invoiceSheetName);
      _clearInvoiceListCache();

      print("✅ Soft deleted invoice $invoiceId (isDeleted=1, light red row)");
    } catch (e) {
      print("❌ Error soft deleting invoice from sheet: $e");
      rethrow;
    }
  }

  static String _columnIndexToLetter(int index) {
    String result = '';
    int n = index;
    while (n >= 0) {
      result = String.fromCharCode(65 + (n % 26)) + result;
      n = n ~/ 26 - 1;
    }
    return result.isEmpty ? 'A' : result;
  }

  // Add to your GoogleSheetService class:
  static Future<void> updateChallanWithCacheClear(
      Map<String, dynamic> challanData, String userId) async {
    print("🔄 Updating challan with cache clear...");

    final challanId = challanData['challanId']?.toString();

    try {
      // Update the challan
      await updateChallan(challanData, userId);

      // Clear cache immediately after update
      if (challanId != null) {
        clearChallanItemCache(challanId);
        _challanCache.remove(challanId);
        print("✅ Cleared cache for challan: $challanId");
      }

      // Also clear any general cache timestamps
      _cacheTimestamps.clear();

    } catch (e) {
      print("❌ Error updating challan: $e");
      rethrow;
    }
  }

  static Future<void> updateChallanItemsWithCacheClear(
      String challanId,
      List<Map<String, dynamic>> items,
      String userId) async {
    print("🔄 Updating challan items with cache clear...");

    try {
      // Update items
      await updateChallanItems(challanId, items, userId);

      // Force clear ALL caches
      clearChallanItemCache(challanId);
      _challanCache.remove(challanId);
      _itemCache.remove('challan_items_$challanId');
      _cacheTimestamps.remove('challan_items_$challanId');

      print("✅ Cleared all caches for challan: $challanId");

    } catch (e) {
      print("❌ Error updating items: $e");
      rethrow;
    }
  }


  static Future<int> _getChallanItemSheetId() async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);

      for (var sheet in spreadsheet.sheets ?? []) {
        if (sheet.properties?.title == challanItemSheetName) {
          return sheet.properties?.sheetId ?? 0;
        }
      }

      throw Exception("Sheet '$challanItemSheetName' not found");
    } catch (e) {
      print("❌ Error getting sheet ID: $e");
      // Fallback to a default ID or throw
      return 0; // You might need to adjust this based on your sheet structure
    }
  }


  static Future<void> deleteItems(String userId, Item item) async {
    print("=== GoogleSheetApi.deleteItems → DELETE and ADD ===");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Step 1: Fetch all rows to locate the row for this item
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$itemSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        throw Exception("❌ Stock sheet is empty, cannot delete item.");
      }

      final headers = response.values![0].map((h) => h.toString().trim()).toList();
      print("✅ Headers: $headers");

      final itemIdIndex = headers.indexOf("itemId");
      final userIdIndex = headers.indexOf("userId");

      if (itemIdIndex == -1 || userIdIndex == -1) {
        throw Exception("❌ Required columns (itemId, userId) not found in sheet.");
      }

      int? rowToDelete;

      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length > itemIdIndex &&
            row[itemIdIndex].toString() == item.itemId &&
            row[userIdIndex].toString() == userId) {
          rowToDelete = i + 1; // Google Sheets rows are 1-based
          break;
        }
      }

      if (rowToDelete == null) {
        throw Exception("❌ Item ${item.itemId} not found for user $userId.");
      }

      print("🗑 Deleting item at row $rowToDelete...");

      // Step 2: Clear the row (deletes data but row stays empty)
      await sheetsApi.spreadsheets.values.clear(
        ClearValuesRequest(),
        spreadsheetId,
        "$itemSheetName!A$rowToDelete:Z$rowToDelete",
      );

      print("✅ Item ${item.itemId} deleted from row $rowToDelete.");

      // Step 3: Add new row (append updated item)
      await Future.delayed(Duration(seconds: 1));

      final newRow = [
        item.itemId,
        item.itemName,
        item.price.toString(),
        item.unitOfMeasurement,
        item.currentStock.toString(),
        item.detailRequirement ?? "",
        item.isActive.toString(),
        userId,
      ];

      final appendBody = ValueRange.fromJson({
        "values": [newRow],
      });

      await sheetsApi.spreadsheets.values.append(
        appendBody,
        spreadsheetId,
        itemSheetName,
        valueInputOption: "USER_ENTERED",
      );

      print("✅ Item ${item.itemId} re-added successfully.");
    } catch (e) {
      print("❌ Error in deleteItems: $e");
      rethrow;
    }
  }

  // static Future<List<InvoiceItem>> getInvoiceItemsByInvoiceId(String invoiceId) async {
  //   try {
  //     final client = await _getAuthClient();
  //     final sheetsApi = SheetsApi(client);
  //
  //     // Fetch all invoice item rows
  //     final response = await sheetsApi.spreadsheets.values.get(
  //       spreadsheetId,
  //       "$invoiceItemSheetName!A:Z",
  //     );
  //
  //     if (response.values == null || response.values!.length <= 1) {
  //       print("❌ No invoice items found in sheet.");
  //       return [];
  //     }
  //
  //     // Extract headers
  //     final headers = response.values![0]
  //         .map((h) => h.toString().trim().toLowerCase().replaceAll(RegExp(r'\s+'), ''))
  //         .toList();
  //
  //     // Find the index of the invoiceId column (match your column name)
  //     final invoiceIdIndex = headers.indexOf('invoiceid'); // adjust if your column name is different
  //     if (invoiceIdIndex == -1) {
  //       throw Exception("InvoiceId column not found in sheet headers");
  //     }
  //
  //     List<InvoiceItem> invoiceItems = [];
  //
  //     // Iterate rows
  //     for (int i = 1; i < response.values!.length; i++) {
  //       final row = response.values![i];
  //
  //       // Check if this row matches the invoiceId
  //       if (row.length > invoiceIdIndex && row[invoiceIdIndex].toString().trim() == invoiceId) {
  //         Map<String, dynamic> rowMap = {};
  //         for (int j = 0; j < headers.length; j++) {
  //           rowMap[headers[j]] = j < row.length ? row[j].toString().trim() : "";
  //         }
  //
  //         try {
  //           final item = InvoiceItem.fromJson(rowMap);
  //           invoiceItems.add(item);
  //         } catch (e) {
  //           print("⚠️ Skipping row ${i + 1} due to parse error: $e");
  //         }
  //       }
  //     }
  //
  //     print("✅ Found ${invoiceItems.length} items for invoice $invoiceId");
  //     return invoiceItems;
  //   } catch (e) {
  //     print("❌ Error fetching invoice items by invoiceId: $e");
  //     return [];
  //   }
  // }

  static Future<List<InvoiceItem>> getInvoiceItemsByInvoiceId(String invoiceId) async {
    print("🔄 Fetching items for invoice: $invoiceId");

    // If already cached, return directly
    if (_invoiceItemCache.containsKey(invoiceId)) {
      print("⚡ Returning cached items for invoice $invoiceId");
      return _invoiceItemCache[invoiceId]!;
    }

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      final headers = await _getHeaders(sheetsApi, sheetName: invoiceItemSheetName);

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$invoiceItemSheetName!A2:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        print("❌ No items found for invoice $invoiceId");
        return <InvoiceItem>[];
      }

      List<InvoiceItem> items = [];
      int foundCount = 0;

      for (int i = 0; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.isEmpty) continue;

        // Create map using original headers
        Map<String, dynamic> itemMap = {};
        for (int j = 0; j < headers.length; j++) {
          itemMap[headers[j]] = j < row.length ? row[j] : "";
        }

        // Filter by invoiceId
        final rowInvoiceId = itemMap['invoiceId'] ??
            itemMap['InvoiceId'] ??
            itemMap['INVOICEID'];

        if (rowInvoiceId?.toString() == invoiceId) {
          try {
            print("=== Raw item map for invoice $invoiceId ===");
            itemMap.forEach((key, value) {
              print("  '$key': '$value'");
            });

            // ✅ FIX: Normalize the map to use 'rate' field
            // If 'price' exists but 'rate' doesn't, copy price to rate
            if (itemMap.containsKey('price') && !itemMap.containsKey('rate')) {
              itemMap['rate'] = itemMap['price'];
              print("✅ Mapped 'price' -> 'rate': ${itemMap['price']}");
            }

            // Also handle totalPrice column name variations
            if (!itemMap.containsKey('totalPrice')) {
              if (itemMap.containsKey('totalAmount')) {
                itemMap['totalPrice'] = itemMap['totalAmount'];
              } else if (itemMap.containsKey('total')) {
                itemMap['totalPrice'] = itemMap['total'];
              }
            }

            InvoiceItem item = InvoiceItem.fromJson(itemMap);
            items.add(item);
            foundCount++;

            print("✅ Added item: ${item.itemName}");
            print("   - Rate: ${item.rate}");
            print("   - Quantity: ${item.quantity}");
            print("   - GST Rate: ${item.gstRate}%");
            print("   - GST Amount: ${item.gstAmount}");
            print("   - Total Price: ${item.totalPrice}");

          } catch (e, stackTrace) {
            print("❌ Error parsing invoice item: $e");
            print("❌ Stack trace: $stackTrace");
            print("❌ Item data: $itemMap");
          }
        }
      }

      print("✅ Found $foundCount items for invoice $invoiceId");

      // Cache result for next call
      _invoiceItemCache[invoiceId] = items;

      return items;
    } catch (e) {
      print("❌ Error getting invoice items: $e");
      return [];
    }
  }

  /// ✅ Get headers (only once per app session, cached in memory)
  static Future<List<String>> _getHeaders(SheetsApi sheetsApi, {String? sheetName}) async {
    try {
      final headerSheetName = sheetName ?? challanItemSheetName;
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$headerSheetName!1:1",
      );

      if (response.values == null || response.values!.isEmpty) {
        throw Exception("No headers found in $headerSheetName");
      }

      final headers = response.values![0].map((h) => h.toString().trim()).toList();
      print("📋 Headers for $headerSheetName: $headers");
      return headers;
    } catch (e) {
      print("❌ Error getting headers for ${sheetName ?? challanItemSheetName}: $e");
      return [];
    }
  }

  /// ✅ Optimized function: get items by challanId with caching
  static Future<List<ChallanItem>> getChallanItemsByChallanId(
      String challanId) async {
    print("🔄 Fetching items for challan: $challanId");

    // If already cached, return directly
    if (_challanCache.containsKey(challanId)) {
      print("⚡ Returning cached items for challan $challanId");
      return _challanCache[challanId]!;
    }

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      final headers = await _getHeaders(sheetsApi);

      // ✅ Fetch only data rows (skip headers)
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanItemSheetName!A2:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        print("❌ No items found for challan $challanId");
        return <ChallanItem>[];
      }

      List<ChallanItem> items = [];
      int foundCount = 0;

      for (int i = 0; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.isEmpty) continue;

        Map<String, dynamic> itemMap = {};
        for (int j = 0; j < headers.length; j++) {
          itemMap[headers[j]] = j < row.length ? row[j] : "";
        }

        // Filter by challanId
        final rowChallanId = itemMap['challanId'] ??
            itemMap['ChallanId'] ??
            itemMap['CHALLANID'];

        if (rowChallanId?.toString() == challanId) {
          try {
            ChallanItem item = ChallanItem.fromJson(itemMap);
            items.add(item);
            foundCount++;
            print("✅ Added item: ${item.itemName}");
          } catch (e) {
            print("❌ Error parsing challan item: $e");
            print("❌ Item data: $itemMap");
          }
        }
      }

      print("✅ Found $foundCount items for challan $challanId");

      // Cache result for next call
      _challanCache[challanId] = items;

      return items;
    } catch (e) {
      print("❌ Error getting challan items: $e");
      return [];
    }
  }

  // static Future<List<Challan>> getChallansByDateRange({
  //   required DateTime fromDate,
  //   required DateTime toDate,
  //   required String userId,
  // }) async {
  //   print("🔄 Fetching challans by date range: ${DateFormat('dd/MM/yyyy').format(fromDate)} to ${DateFormat('dd/MM/yyyy').format(toDate)} for user: $userId");
  //
  //   try {
  //     final client = await _getAuthClient();
  //     final sheetsApi = SheetsApi(client);
  //
  //     // Fetch all challan rows
  //     final response = await sheetsApi.spreadsheets.values.get(
  //       spreadsheetId,
  //       "$challanSheetName!A:Z",
  //     );
  //
  //     if (response.values == null || response.values!.length <= 1) {
  //       print("❌ No challans found in sheet.");
  //       return <Challan>[];
  //     }
  //
  //     // Extract headers
  //     final headers = response.values![0].map((h) => h.toString().trim()).toList();
  //     print("✅ Headers: $headers");
  //
  //     // DEBUG: Show first 5 rows
  //     print("=== DEBUG: FIRST 5 ROWS ===");
  //     for (int i = 1; i < min(6, response.values!.length); i++) {
  //       Map<String, dynamic> rowMap = {};
  //       for (int j = 0; j < headers.length; j++) {
  //         rowMap[headers[j]] = j < response.values![i].length ? response.values![i][j] : "";
  //       }
  //       print("Row $i: $rowMap");
  //     }
  //
  //     List<Challan> filteredChallans = [];
  //
  //     // Iterate rows (skip header row)
  //     for (int i = 1; i < response.values!.length; i++) {
  //       final row = response.values![i];
  //       if (row.isEmpty) continue; // Skip empty rows
  //
  //       Map<String, dynamic> challanMap = {};
  //       for (int j = 0; j < headers.length; j++) {
  //         challanMap[headers[j]] = j < row.length ? row[j] : "";
  //       }
  //
  //       try {
  //         Challan challan = Challan.fromMap(challanMap);
  //
  //         // Parse challan date safely
  //         DateTime? parsedChallanDate;
  //         String rawDate = challanMap['challanDate']?.toString().trim() ?? "";
  //
  //         if (rawDate.isNotEmpty) {
  //           parsedChallanDate = _parseChallanDate(rawDate);
  //         }
  //
  //         // Filter by user ID and date range
  //         if (parsedChallanDate != null &&
  //             challan.userId == userId &&
  //             !parsedChallanDate.isBefore(fromDate) &&
  //             !parsedChallanDate.isAfter(toDate)) {
  //           // Load items for this challan
  //           challan.items = await getChallanItemsByChallanId(challan.challanId);
  //           challan.challanDate = parsedChallanDate;
  //
  //           filteredChallans.add(challan);
  //           print("✅ Added challan: ${challan.challanId} - Date: $parsedChallanDate - Items: ${challan.items?.length ?? 0}");
  //         } else {
  //           if (parsedChallanDate == null) {
  //             print("⚠️ Skipping challan ${challan.challanId}: Invalid date format ($rawDate)");
  //           } else if (challan.userId != userId) {
  //             print("⚠️ Skipping challan ${challan.challanId}: User ID mismatch (${challan.userId} vs $userId)");
  //           } else {
  //             print("⚠️ Skipping challan ${challan.challanId}: Date $parsedChallanDate outside range");
  //           }
  //         }
  //       } catch (e) {
  //         print("⚠️ Error parsing challan row $i: $e");
  //         print("Row data: $challanMap");
  //       }
  //     }
  //
  //     print("✅ Successfully found ${filteredChallans.length} challans in date range");
  //
  //     // Sort challans by date (newest first)
  //     filteredChallans.sort((a, b) {
  //       if (a.challanDate == null) return 1;
  //       if (b.challanDate == null) return -1;
  //       return b.challanDate!.compareTo(a.challanDate!);
  //     });
  //
  //     return filteredChallans;
  //   } catch (e) {
  //     print("❌ Error in getChallansByDateRange(): $e");
  //     rethrow;
  //   }
  // }

  static Future<List<Challan>> getChallansByDateRange({
    required DateTime fromDate,
    required DateTime toDate,
    required String userId,
  }) async {
    final client = await _getAuthClient();
    final sheetsApi = SheetsApi(client);

    final response = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      "$challanSheetName!A:Z",
    );

    if (response.values == null || response.values!.length <= 1) return [];

    final headers = response.values![0].map((h) => h.toString().trim()).toList();

    // ✅ Load ALL challan items once
    final challanItemsGrouped = await getAllChallanItemsGrouped();

    List<Challan> filtered = [];

    for (int i = 1; i < response.values!.length; i++) {
      final row = response.values![i];
      if (row.isEmpty) continue;

      Map<String, dynamic> challanMap = {};
      for (int j = 0; j < headers.length; j++) {
        challanMap[headers[j]] = j < row.length ? row[j] : "";
      }

      try {
        Challan challan = Challan.fromMap(challanMap);

        DateTime? parsedDate = _parseChallanDate(challanMap['challanDate']?.toString() ?? "");
        if (parsedDate != null &&
            challan.userId == userId &&
            !parsedDate.isBefore(fromDate) &&
            !parsedDate.isAfter(toDate)) {

          // ✅ Attach preloaded items
          challan.items = challanItemsGrouped[challan.challanId] ?? [];
          challan.challanDate = parsedDate;

          filtered.add(challan);
        }
      } catch (e) {
        print("⚠️ Error parsing challan: $e");
      }
    }

    return filtered;
  }

  static Future<Map<String, List<ChallanItem>>> getAllChallanItemsGrouped() async {
    final client = await _getAuthClient();
    final sheetsApi = SheetsApi(client);

    final headers = await _getHeaders(sheetsApi);

    final response = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      "$challanItemSheetName!A2:Z",
    );

    Map<String, List<ChallanItem>> grouped = {};

    if (response.values == null || response.values!.isEmpty) {
      return grouped;
    }

    for (var row in response.values!) {
      if (row.isEmpty) continue;

      Map<String, dynamic> itemMap = {};
      for (int j = 0; j < headers.length; j++) {
        itemMap[headers[j]] = j < row.length ? row[j] : "";
      }

      final challanId = itemMap['challanId'] ?? itemMap['ChallanId'] ?? "";
      if (challanId.toString().isEmpty) continue;

      try {
        final item = ChallanItem.fromJson(itemMap);
        grouped.putIfAbsent(challanId.toString(), () => []);
        grouped[challanId.toString()]!.add(item);
      } catch (e) {
        print("❌ Failed parsing ChallanItem: $e");
      }
    }

    return grouped;
  }



  /// 🔑 Helper function to parse multiple date formats
  static DateTime? _parseChallanDate(String rawDate) {
    try {
      // Try ISO 8601 (yyyy-MM-dd or with time)
      DateTime? parsed = DateTime.tryParse(rawDate);
      if (parsed != null) return parsed;

      // Try dd/MM/yyyy
      parsed = DateFormat('dd/MM/yyyy').parseStrict(rawDate);
      if (parsed != null) return parsed;
    } catch (_) {}

    try {
      // Try dd/MM/yyyy HH:mm:ss
      return DateFormat('dd/MM/yyyy HH:mm:ss').parseStrict(rawDate);
    } catch (_) {
      return null;
    }
  }

  static Future<List<Challan>> getChallansWithItemsByCustomer(String customerName) async {
    print("🔄 Fetching challans for customer: $customerName");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // ✅ Batch fetch challans & items in one call
      final batchResponse = await sheetsApi.spreadsheets.values.batchGet(
        spreadsheetId,
        ranges: [
          "$challanSheetName!A:Z",
          "$challanItemSheetName!A:Z", // make sure you have this constant
        ],
      );

      if (batchResponse.valueRanges == null || batchResponse.valueRanges!.isEmpty) {
        print("❌ No data returned from batchGet");
        return [];
      }

      // --- Challans ---
      final challansValues = batchResponse.valueRanges![0].values;
      if (challansValues == null || challansValues.length <= 1) {
        print("❌ No challans found in sheet");
        return [];
      }
      final challanHeaders = challansValues[0].map((h) => h.toString().trim()).toList();
      print("✅ Challan headers: $challanHeaders");

      // --- Items ---
      final itemsValues = batchResponse.valueRanges!.length > 1
          ? batchResponse.valueRanges![1].values
          : null;
      List<Map<String, dynamic>> allItems = [];
      if (itemsValues != null && itemsValues.length > 1) {
        final itemHeaders = itemsValues[0].map((h) => h.toString().trim()).toList();
        for (int i = 1; i < itemsValues.length; i++) {
          Map<String, dynamic> itemMap = {};
          for (int j = 0; j < itemHeaders.length; j++) {
            itemMap[itemHeaders[j]] =
            j < itemsValues[i].length ? itemsValues[i][j] : "";
          }
          allItems.add(itemMap);
        }
        print("📦 Total challan items loaded: ${allItems.length}");
      }

      List<Challan> customerChallans = [];

      // --- Iterate challans ---
      for (int i = 1; i < challansValues.length; i++) {
        final row = challansValues[i];
        if (row.isEmpty) continue;

        Map<String, dynamic> challanMap = {};
        for (int j = 0; j < challanHeaders.length; j++) {
          challanMap[challanHeaders[j]] = j < row.length ? row[j] : "";
        }

        try {
          Challan challan = Challan.fromMap(challanMap);

          // Debug: Print challan details
          print("📋 Challan ${challan.challanId}: Customer=${challan.customerName}, Looking for=$customerName");

          // Filter by customer name (case insensitive)
          if (challan.customerName.toLowerCase() == customerName.toLowerCase()) {
            print("✅ Found matching challan: ${challan.challanId}");

            // ✅ Filter items locally instead of extra API calls
            final challanItems = allItems
                .where((item) => item["challanId"].toString() == challan.challanId)
                .map((map) => ChallanItem.fromJson(map))
                .toList();

            print("📦 Items loaded for ${challan.challanId}: ${challanItems.length}");

            // ✅ Attach items using copyWith
            Challan challanWithItems = challan.copyWith(items: challanItems);
            customerChallans.add(challanWithItems);

            print("✅ Challan ${challan.challanId} now has ${challanWithItems.items?.length ?? 0} items");
          }
        } catch (e) {
          print("❌ Error parsing challan: $e");
          print("❌ Challan data: $challanMap");
        }
      }

      print("✅ Total challans found for $customerName: ${customerChallans.length}");
      return customerChallans;
    } catch (e) {
      print("❌ Error getting challans by customer: $e");
      return [];
    }
  }

  static Future<List<ChallanItem>> getChallanItemsByChallanIdFromSheet(String challanId) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Fetch all rows from the challan items sheet
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanItemSheetName!A:Z",
      );

      if (response.values == null || response.values!.length <= 1) {
        print("❌ No challan items found.");
        return [];
      }

      // Extract headers
      final headers = response.values![0]
          .map((h) => h.toString().trim().toLowerCase().replaceAll(RegExp(r'\s+'), ''))
          .toList();

      List<ChallanItem> items = [];

      // Iterate rows
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        Map<String, String> rowByHeader = {};

        for (int j = 0; j < headers.length; j++) {
          final key = headers[j];
          final value = (j < row.length) ? row[j].toString() : "";
          rowByHeader[key] = value;
        }

        // Filter by challanId
        if (rowByHeader['challanid'] == challanId) {
          try {
            final item = ChallanItem.fromJson(rowByHeader);
            items.add(item);
          } catch (e) {
            print("⚠️ Skipping row ${i + 1} due to parse error: $e");
          }
        }
      }

      print("✅ Found ${items.length} items for challan $challanId");
      return items;
    } catch (e) {
      print("❌ Error fetching items for challan $challanId: $e");
      return [];
    }
  }


  ///Inventeroty 16/10



  /// Add a new purchase to Google Sheet
  // Add these methods to your GoogleSheetService class

  /// Add purchase with dynamic header creation
  // Add to or replace in GoogleSheetService class

  /// Enhanced addPurchase with all fields (matching Invoice structure)
  static Future<void> addPurchase(dynamic purchaseData, String userId) async {
    print("🔄 Adding Purchase to Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Define expected headers for the Purchase sheet
      final expectedHeaders = [
        'purchaseId',
        'vendorId',
        'vendorName',
        'vendorEmail',
        'vendorMobile',
        'vendorAddress',
        'purchaseDate',
        'dueDate',
        'subtotal',
        'gstRate',
        'gstAmount',
        'totalAmount',
        'paidAmount',
        'pendingAmount',
        'paymentStatus',
        'paymentMethod',
        'notes',
        'userId',
        'createdAt',
        'updatedAt',
      ];

      // ✅ Ensure sheet and headers exist (auto-create if missing)
      final headers = await _getOrCreateHeaders(
        sheetsApi,
        purchaseSheetName,
        expectedHeaders,
      );

      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');

      // Utility: Format date safely
      String _formatDate(dynamic value) {
        if (value == null || value.toString().isEmpty) return "";
        try {
          if (value is DateTime) return _dateFormatter.format(value);
          return _dateFormatter.format(DateTime.parse(value.toString()));
        } catch (e) {
          return value.toString();
        }
      }

      // Normalize keys for case-insensitive matching
      Map<String, dynamic> _normalize(Map<String, dynamic> data) {
        return {
          for (var entry in data.entries)
            entry.key.toString().trim().toLowerCase(): entry.value
        };
      }

      // Support for both Map and PurchaseEntry class
      List<Map<String, dynamic>> rowsToSend = [];

      if (purchaseData is Map<String, dynamic>) {
        purchaseData['purchaseDate'] = _formatDate(purchaseData['purchaseDate']);
        purchaseData['dueDate'] = _formatDate(purchaseData['dueDate']);
        rowsToSend.add({
          ...purchaseData,
          "userId": userId,
          "createdAt": _formatDate(DateTime.now()),
          "updatedAt": _formatDate(DateTime.now()),
        });
      } else if (purchaseData is PurchaseEntry) {
        final map = {
          'purchaseId': purchaseData.purchaseId,
          'vendorId': purchaseData.vendorId,
          'vendorName': purchaseData.vendorName,
          'vendorEmail': purchaseData.vendorEmail,
          'vendorMobile': purchaseData.vendorMobile,
          'vendorAddress': purchaseData.vendorAddress,
          'purchaseDate': _formatDate(purchaseData.purchaseDate),
          'dueDate': _formatDate(purchaseData.dueDate),
          'subtotal': purchaseData.subtotal,
          'gstRate': purchaseData.gstRate,
          'gstAmount': purchaseData.gstAmount,
          'totalAmount': purchaseData.totalAmount,
          'paidAmount': purchaseData.paidAmount ?? 0.0,
          'pendingAmount': purchaseData.pendingAmount ?? purchaseData.totalAmount,
          'paymentStatus': purchaseData.paymentStatus,
          'notes': purchaseData.notes,
          'userId': userId,
          'createdAt': _formatDate(DateTime.now()),
          'updatedAt': _formatDate(DateTime.now()),
        };
        rowsToSend.add(map);
      }

      // Convert to 2D list in header order
      List<List<dynamic>> values = [];
      for (var row in rowsToSend) {
        final normalized = _normalize(row);
        List<dynamic> rowData = [];
        for (var header in headers) {
          final key = header.toString().trim().toLowerCase();
          rowData.add(normalized[key]?.toString() ?? '');
        }
        values.add(rowData);
      }

      print("🧾 Prepared purchase rows: $values");

      // Append to the Google Sheet
      final valueRange = ValueRange.fromJson({"values": values});
      await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        "$purchaseSheetName!A:Z",
        valueInputOption: "USER_ENTERED",
      );

      print("✅ Purchase added successfully to Google Sheet");
    } catch (e) {
      print("❌ Error adding Purchase: $e");
      throw Exception("Failed to add Purchase: ${e.toString()}");
    }
  }


  /// Updated addPurchaseItemsBatch with auto-create
  static Future<void> addPurchaseItemsBatch(
      List<Map<String, dynamic>> itemsData,
      String userId,
      ) async {
    print("🔄 Adding ${itemsData.length} purchase items in batch...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      final expectedHeaders = [
        'purchaseId',
        'vendorId',
        'itemId',
        'itemName',
        'description',
        'quantity',
        'purchasePrice',
        'purchaseDate',
        'gstRate',
        'totalPrice',
        'unit',
        'userId',
      ];

      // ✅ Ensure headers exist
      final headers = await _ensureHeadersExist(
        sheetsApi,
        purchaseItemSheetName,
        expectedHeaders,
      );

      String _normalizeKey(String key) {
        return key.toString().trim().toLowerCase();
      }

      List<List<dynamic>> rows = [];

      for (var itemData in itemsData) {
        List<dynamic> rowData = [];

        Map<String, dynamic> normalizedItem = {};
        for (var entry in itemData.entries) {
          normalizedItem[_normalizeKey(entry.key)] = entry.value;
        }

        for (var header in headers) {
          final headerNameLower = _normalizeKey(header.toString());

          if (headerNameLower.contains('userid')) {
            rowData.add(userId);
          } else {
            var value = normalizedItem[headerNameLower]?.toString() ?? '';
            rowData.add(value);
          }
        }

        rows.add(rowData);
      }

      final valueRange = ValueRange.fromJson({"values": rows});

      await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        "$purchaseItemSheetName!A:Z",
        valueInputOption: "USER_ENTERED",
      );

      print("✅ ${rows.length} purchase items added successfully");
    } catch (e) {
      print("❌ Error adding purchase items: $e");
      rethrow;
    }
  }

  /// Get all purchases
  static Future<List<PurchaseEntry>> getPurchasesList() async {
    print("🔄 Fetching purchases from Google Sheets...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Fetch all purchase rows
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$purchaseSheetName!A:Z",
      );

      if (response.values == null || response.values!.length <= 1) {
        print("❌ No purchases found in sheet.");
        return <PurchaseEntry>[];
      }

      final headers =
          response.values![0].map((h) => h.toString().trim()).toList();

      List<PurchaseEntry> purchases = [];
      const int yieldEvery = 100;

      for (int i = 1; i < response.values!.length; i++) {
        if (i > 1 && (i - 1) % yieldEvery == 0) {
          await Future.delayed(Duration.zero);
        }
        final row = response.values![i];

        if (row.isEmpty || row[0].toString().trim().isEmpty) {
          continue;
        }

        Map<String, dynamic> purchaseMap = {};
        for (int j = 0; j < headers.length && j < row.length; j++) {
          purchaseMap[headers[j]] = row[j].toString();
        }

        try {
          PurchaseEntry purchase = PurchaseEntry.fromJson(purchaseMap);
          purchases.add(purchase);
        } catch (e) {
          continue;
        }
      }

      print("✅ Successfully parsed ${purchases.length} purchases from Google Sheets");
      return purchases;
    } catch (e) {
      print("❌ Error in getPurchasesList(): $e");
      rethrow;
    }
  }

  /// Update purchase
  // ✅ In your GoogleSheetService.updatePurchase method, ensure this mapping exists:

// Around line 2800-2900 in your GoogleSheetService
  static Future<void> updatePurchase(Map<String, dynamic> purchaseData, String userId) async {
    print("🔄 Updating Purchase in Google Sheet...");
    print("📋 Data to update: ${purchaseData.keys.toList()}");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get all purchases
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$purchaseSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        throw Exception("❌ Purchase sheet is empty");
      }

      final headers = response.values![0];
      print("📋 Sheet headers: $headers");

      final purchaseIdIndex = headers.indexOf("purchaseId");
      final userIdIndex = headers.indexOf("userId");

      if (purchaseIdIndex == -1 || userIdIndex == -1) {
        throw Exception("❌ Missing purchaseId or userId column in sheet");
      }

      int? rowToUpdate;
      List<Object?> existingRow = [];

      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length > purchaseIdIndex &&
            row[purchaseIdIndex].toString() == purchaseData["purchaseId"].toString() &&
            row[userIdIndex].toString() == userId) {
          rowToUpdate = i + 1;
          existingRow = row;
          print("✅ Found purchase at row $rowToUpdate");
          break;
        }
      }

      if (rowToUpdate == null) {
        throw Exception("❌ Purchase not found for update (id: ${purchaseData["purchaseId"]})");
      }

      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

      // Build normalized data with all required fields
      Map<String, dynamic> normalized = {};

      for (var header in headers) {
        String key = header.toString().trim().toLowerCase();

        switch (key) {
          case 'purchaseid':
            normalized[key] = purchaseData["purchaseId"] ?? '';
            break;
          case 'vendorid':
            normalized[key] = purchaseData["vendorId"] ?? '';
            break;
          case 'vendorname':
            normalized[key] = purchaseData["vendorName"] ?? '';
            break;
          case 'vendoremail':
            normalized[key] = purchaseData["vendorEmail"] ?? '';
            break;
          case 'vendormobile':
            normalized[key] = purchaseData["vendorMobile"] ?? '';
            break;
          case 'vendoraddress':
            normalized[key] = purchaseData["vendorAddress"] ?? '';
            break;
          case 'purchasedate':
            try {
              if (purchaseData["purchaseDate"] != null) {
                if (purchaseData["purchaseDate"] is DateTime) {
                  normalized[key] = _dateFormatter.format(purchaseData["purchaseDate"] as DateTime);
                } else if (purchaseData["purchaseDate"] is String) {
                  // Try to parse ISO string
                  try {
                    final date = DateTime.parse(purchaseData["purchaseDate"]);
                    normalized[key] = _dateFormatter.format(date);
                  } catch (e) {
                    normalized[key] = purchaseData["purchaseDate"];
                  }
                } else {
                  normalized[key] = purchaseData["purchaseDate"].toString();
                }
              } else {
                normalized[key] = '';
              }
            } catch (e) {
              print("⚠️ Error formatting purchaseDate: $e");
              normalized[key] = purchaseData["purchaseDate"]?.toString() ?? '';
            }
            break;
          case 'duedate':
            try {
              if (purchaseData["dueDate"] != null) {
                if (purchaseData["dueDate"] is DateTime) {
                  normalized[key] = _dateFormatter.format(purchaseData["dueDate"] as DateTime);
                } else if (purchaseData["dueDate"] is String) {
                  try {
                    final date = DateTime.parse(purchaseData["dueDate"]);
                    normalized[key] = _dateFormatter.format(date);
                  } catch (e) {
                    normalized[key] = purchaseData["dueDate"];
                  }
                } else {
                  normalized[key] = purchaseData["dueDate"].toString();
                }
              } else {
                normalized[key] = '';
              }
            } catch (e) {
              print("⚠️ Error formatting dueDate: $e");
              normalized[key] = purchaseData["dueDate"]?.toString() ?? '';
            }
            break;
          case 'subtotal':
            normalized[key] = purchaseData["subtotal"]?.toString() ?? '0';
            print("   Subtotal: ${normalized[key]}");
            break;
          case 'gstrate':
            normalized[key] = purchaseData["gstRate"]?.toString() ?? '0';
            print("   GST Rate: ${normalized[key]}");
            break;
          case 'gstamount':
            normalized[key] = purchaseData["gstAmount"]?.toString() ?? '0';
            print("   GST Amount: ${normalized[key]}");
            break;
          case 'totalamount':
            normalized[key] = purchaseData["totalAmount"]?.toString() ?? '0';
            print("   Total Amount: ${normalized[key]}");
            break;
          case 'paidamount':
          // ✅ CRITICAL: This must be updated
            normalized[key] = purchaseData["paidAmount"]?.toString() ?? '0';
            print("   ✅ NEW Paid Amount: ${normalized[key]}");
            break;
          case 'pendingamount':
          // ✅ CRITICAL: This must be updated
            normalized[key] = purchaseData["pendingAmount"]?.toString() ?? '0';
            print("   ✅ NEW Pending Amount: ${normalized[key]}");
            break;
          case 'paymentstatus':
          // ✅ CRITICAL: This must be updated
            normalized[key] = purchaseData["paymentStatus"] ?? 'Pending';
            print("   ✅ NEW Status: ${normalized[key]}");
            break;
          case 'paymentmethod':
            normalized[key] = purchaseData["paymentMethod"] ?? '';
            print("💳 Updating Payment Method: ${normalized[key]}");
            break;
          case 'notes':
            normalized[key] = purchaseData["notes"] ?? '';
            break;
          case 'userid':
            normalized[key] = userId;
            break;
          default:
            int existingIndex =
            headers.indexWhere((h) => h.toString().toLowerCase() == key);
            if (existingIndex != -1 && existingRow.length > existingIndex) {
              normalized[key] = existingRow[existingIndex]?.toString() ?? '';
            } else {
              normalized[key] = '';
            }
            break;
        }
      }

      // Build row data in the same order as headers
      List<dynamic> rowData = [];
      for (var header in headers) {
        final key = header.toString().trim().toLowerCase();
        rowData.add(normalized[key]?.toString() ?? '');
      }

      print("📤 Updating row with data: $rowData");

      final range =
          "$purchaseSheetName!A$rowToUpdate:${String.fromCharCode(65 + headers.length - 1)}$rowToUpdate";

      final valueRange = ValueRange(
        values: [rowData],
      );

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: "USER_ENTERED",
      );

      print("✅ Purchase updated successfully at row $rowToUpdate");
    } catch (e, stackTrace) {
      print("❌ Error updating Purchase: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  /// Update purchase items with dynamic header handling ✅ UPDATED: updatePurchaseItems with cache clearing
  static Future<void> updatePurchaseItems(
      String purchaseId, List<Map<String, dynamic>> items, String userId) async {
    print("🔄 Updating Purchase Items in Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get current sheet data
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$purchaseItemSheetName!A:Z",
      );

      List<dynamic> headers = [];

      if (response.values == null || response.values!.isEmpty) {
        print("⚠️ Sheet is empty. Creating headers and adding new items...");

        // Create headers from first item's keys or default structure
        final sampleData = items.isNotEmpty
            ? items.first
            : {
          'purchaseId': '',
          'vendorId': '',
          'itemId': '',
          'itemName': '',
          'description': '',
          'quantity': '',
          'purchasePrice': '',
          'purchaseDate': '',
          'gstRate': '',
          'totalPrice': '',
          'unit': '',
          'userId': '',
        };

        headers = sampleData.keys.toList();

        // Add header row
        final headerRange = ValueRange.fromJson({
          "values": [headers],
        });

        await sheetsApi.spreadsheets.values.update(
          headerRange,
          spreadsheetId,
          "$purchaseItemSheetName!A1",
          valueInputOption: "USER_ENTERED",
        );

        print("✅ Header row created for '$purchaseItemSheetName'");

        // Now add the items
        for (var item in items) {
          item['purchaseId'] = purchaseId;
        }
        await addPurchaseItemsBatch(items, userId);

        // Clear cache after successful update
        clearPurchaseItemCache(purchaseId);
        return;
      }

      headers = response.values![0];
      print("Sheet headers: $headers");

      final purchaseIdIndex = headers.indexOf("purchaseId");

      if (purchaseIdIndex == -1) {
        throw Exception("❌ Missing purchaseId column");
      }

      // Build new sheet data (keep all items except for this purchaseId)
      List<List<Object?>> newSheetData = [];
      newSheetData.add(headers); // Add headers first

      // Add all rows that DON'T belong to our purchaseId
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length > purchaseIdIndex &&
            row[purchaseIdIndex].toString() != purchaseId) {
          newSheetData.add(row);
        }
      }

      // Normalize key function
      String _normalizeKey(String key) {
        return key.toString().trim().toLowerCase();
      }

      // Add our new items to the data
      for (var item in items) {
        List<Object?> newRow = [];

        // Normalize item keys
        Map<String, dynamic> normalizedItem = {};
        for (var entry in item.entries) {
          normalizedItem[_normalizeKey(entry.key)] = entry.value;
        }

        for (var header in headers) {
          String key = _normalizeKey(header.toString());

          if (key.contains('purchaseid')) {
            newRow.add(item['purchaseId'] ?? purchaseId);
          } else if (key.contains('userid')) {
            newRow.add(item['userId'] ?? userId);
          } else {
            newRow.add(normalizedItem[key]?.toString() ?? '');
          }
        }
        newSheetData.add(newRow);
        print("Added row: $newRow");
      }

      // Clear the entire sheet
      await sheetsApi.spreadsheets.values.clear(
        ClearValuesRequest(),
        spreadsheetId,
        "$purchaseItemSheetName!A:Z",
      );

      // Write all data back to sheet
      if (newSheetData.length > 1) {
        final range =
            "$purchaseItemSheetName!A1:${String.fromCharCode(65 + headers.length - 1)}${newSheetData.length}";

        await sheetsApi.spreadsheets.values.update(
          ValueRange(values: newSheetData),
          spreadsheetId,
          range,
          valueInputOption: "USER_ENTERED",
        );
      }

      print("✅ Successfully updated ${items.length} purchase items");

      // ✅ CRITICAL: Clear cache after successful update
      clearPurchaseItemCache(purchaseId);
      print("✅ Cache cleared after update");

    } catch (e, stackTrace) {
      print("❌ Error updating Purchase items: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  // ✅ UPDATED: Enhanced getPurchaseItemsByPurchaseId with caching
  static Future<List<PurchaseItem>> getPurchaseItemsByPurchaseId(
      String purchaseId) async {
    print("🔄 Fetching items for purchase: $purchaseId");

    // If already cached, return directly
    if (_purchaseItemCache.containsKey(purchaseId)) {
      print("⚡ Returning cached items for purchase $purchaseId");
      return _purchaseItemCache[purchaseId]!;
    }

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get headers
      final headerResponse = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$purchaseItemSheetName!1:1",
      );

      if (headerResponse.values == null || headerResponse.values!.isEmpty) {
        print("❌ No header row in purchase items sheet");
        return [];
      }

      final headers =
      headerResponse.values![0].map((h) => h.toString().trim()).toList();

      // Fetch data rows
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$purchaseItemSheetName!A2:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        print("❌ No items found for purchase $purchaseId");
        return [];
      }

      List<PurchaseItem> items = [];
      int foundCount = 0;

      for (int i = 0; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.isEmpty) continue;

        Map<String, dynamic> itemMap = {};
        for (int j = 0; j < headers.length; j++) {
          itemMap[headers[j]] = j < row.length ? row[j] : "";
        }

        // Filter by purchaseId
        final rowPurchaseId = itemMap['purchaseId'] ??
            itemMap['PurchaseId'] ??
            itemMap['PURCHASEID'];

        if (rowPurchaseId?.toString() == purchaseId) {
          try {
            print("=== Raw item map for purchase $purchaseId ===");
            itemMap.forEach((key, value) {
              print("  '$key': '$value'");
            });

            PurchaseItem item = PurchaseItem.fromJson(itemMap);
            items.add(item);
            foundCount++;

            print("✅ Added item: ${item.itemName}");
            print("   - Purchase Price: ${item.purchasePrice}");
            print("   - Quantity: ${item.quantity}");
            print("   - GST Rate: ${item.gstRate}%");
            print("   - Total Price: ${item.totalPrice}");
          } catch (e, stackTrace) {
            print("❌ Error parsing purchase item: $e");
            print("❌ Stack trace: $stackTrace");
            print("❌ Item data: $itemMap");
          }
        }
      }

      print("✅ Found $foundCount items for purchase $purchaseId");

      // Cache result for next call
      _purchaseItemCache[purchaseId] = items;

      return items;
    } catch (e) {
      print("❌ Error getting purchase items: $e");
      return [];
    }
  }

  /// Update stock after purchase
  static Future<void> updateStockAfterPurchase(List<PurchaseItem> purchaseItems) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Fetch all stock rows once
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$itemSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        print("⚠️ Stock sheet is empty - skipping stock update");
        return;
      }

      final headers = response.values![0];
      final itemIdIndex = headers.indexOf("itemId");
      final stockIndex = headers.indexOf("currentStock");
      final userIdIndex = headers.indexOf("userId");

      if (itemIdIndex == -1 || stockIndex == -1 || userIdIndex == -1) {
        print("⚠️ Missing required columns in Stock sheet - skipping update");
        return;
      }

      for (var item in purchaseItems) {
        // Skip items without itemId (manually entered items)
        if (item.itemId == null || item.itemId!.isEmpty) {
          print("⚠️ Skipping stock update for manually entered item: ${item.itemName}");
          continue;
        }

        int? rowToUpdate;
        double currentStock = 0.0;

        // Find row for this itemId + userId
        for (int i = 1; i < response.values!.length; i++) {
          final row = response.values![i];
          if (row.length > itemIdIndex &&
              row[itemIdIndex].toString() == item.itemId.toString() &&
              row[userIdIndex].toString() == AppConstants.userId) {
            rowToUpdate = i + 1; // rows are 1-based
            if (row.length > stockIndex) {
              currentStock = double.tryParse(row[stockIndex].toString().replaceAll(',', '.')) ?? 0.0;
            }
            break;
          }
        }

        if (rowToUpdate == null) {
          print("⚠️ Item ${item.itemId} not found in stock sheet.");
          continue;
        }

        // Increase stock for purchase
        final newStock = currentStock + item.quantity;

        final range =
            "$itemSheetName!${String.fromCharCode(65 + stockIndex)}$rowToUpdate";
        final valueRange = ValueRange.fromJson({
          "values": [
            [newStock]
          ]
        });

        await sheetsApi.spreadsheets.values.update(
          valueRange,
          spreadsheetId,
          range,
          valueInputOption: "USER_ENTERED",
        );

        print("✅ Stock updated (Purchase): ${item.itemId} → $newStock (was $currentStock)");
      }
    } catch (e) {
      print("❌ Error updating stock after purchase: $e");
    }
  }

  // ✅ UPDATED: updatePurchaseWithCacheClear
  static Future<void> updatePurchaseWithCacheClear(
      Map<String, dynamic> purchaseData, String userId) async {
    print("🔄 Updating purchase with cache clear...");

    final purchaseId = purchaseData['purchaseId']?.toString();

    try {
      // Update the purchase
      await updatePurchase(purchaseData, userId);

      // Clear cache immediately after update
      if (purchaseId != null) {
        clearPurchaseItemCache(purchaseId);
        print("✅ Cleared cache for purchase: $purchaseId");
      }

      // Also clear any general cache timestamps
      _cacheTimestamps.clear();

    } catch (e) {
      print("❌ Error updating purchase: $e");
      rethrow;
    }
  }

  // Clear cache for a specific purchase
  static void clearPurchaseItemCache(String purchaseId) {
    if (_purchaseItemCache.containsKey(purchaseId)) {
      _purchaseItemCache.remove(purchaseId);
      print("🗑️ Cleared cache for purchase: $purchaseId");
    }

    // Also clear from generic cache if exists
    final cacheKey = 'purchase_items_$purchaseId';
    if (_itemCache.containsKey(cacheKey)) {
      _itemCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
      print("🗑️ Cleared generic cache for purchase: $purchaseId");
    }
  }

  /// Clear entire purchase items cache
  static void clearAllPurchaseItemCache() {
    _purchaseItemCache.clear();
    print("🗑️ Cleared all purchase item cache");

    // Also clear generic purchase-related cache
    _itemCache.removeWhere((key, value) => key.startsWith('purchase_items_'));
    _cacheTimestamps.removeWhere((key, value) => key.startsWith('purchase_items_'));
    print("🗑️ Cleared all generic purchase cache");
  }


  /// Clear all caches (invoices, challans, purchases)
  static void clearAllCaches() {
    _challanCache.clear();
    _invoiceItemCache.clear();
    _purchaseItemCache.clear();
    _itemCache.clear();
    _cacheTimestamps.clear();
    print("🗑️ Cleared ALL caches");
  }

  static Future<void> updatePurchaseItemsWithCacheClear(
      String purchaseId,
      List<Map<String, dynamic>> items,
      String userId) async {
    print("🔄 Updating purchase items with cache clear...");

    try {
      await updatePurchaseItems(purchaseId, items, userId);
      print("✅ Cleared all caches for purchase: $purchaseId");
    } catch (e) {
      print("❌ Error updating items: $e");
      rethrow;
    }
  }

  /// Add a single inventory transaction to Google Sheet
  static Future<void> addInventoryTransaction(
      String userId, InventoryTransaction transaction) async {
    print("🔄 Adding inventory transaction to Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get header row
      final headerResponse = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$inventoryTransactionSheetName!1:1",
      );

      if (headerResponse.values == null || headerResponse.values!.isEmpty) {
        print("⚠️ Sheet empty, creating headers...");
        // Create headers if sheet is empty
        final headers = [
          'transactionId',
          'itemId',
          'itemName',
          'quantity',
          'type',
          'reason',
          'timestamp',
          'notes',
          'userId',
        ];

        await sheetsApi.spreadsheets.values.update(
          ValueRange.fromJson({"values": [headers]}),
          spreadsheetId,
          "$inventoryTransactionSheetName!A1:I1",
          valueInputOption: "RAW",
        );

        print("✅ Headers created");
      }

      final headers = headerResponse.values?[0] ?? [];

      // Prepare row values based on header order
      List<dynamic> rowData = [];
      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');

      for (var header in headers) {
        final headerName = header.toString().toLowerCase();

        switch (headerName) {
          case 'transactionid':
            rowData.add(transaction.transactionId);
            break;
          case 'itemid':
            rowData.add(transaction.itemId);
            break;
          case 'itemname':
            rowData.add(transaction.itemName);
            break;
          case 'quantity':
            rowData.add(transaction.quantity.toString());
            break;
          case 'type':
            rowData.add(transaction.type);
            break;
          case 'reason':
            rowData.add(transaction.reason);
            break;
          case 'timestamp':
            rowData.add(_dateFormatter.format(transaction.timestamp));
            break;
          case 'notes':
            rowData.add(transaction.notes);
            break;
          case 'userid':
            rowData.add(userId);
            break;
          default:
            rowData.add('');
        }
      }

      print("Prepared row: $rowData");

      // Append row to sheet
      await sheetsApi.spreadsheets.values.append(
        ValueRange.fromJson({"values": [rowData]}),
        spreadsheetId,
        "$inventoryTransactionSheetName!A:I",
        valueInputOption: "USER_ENTERED",
      );

      print("✅ Inventory transaction added successfully");
    } catch (e) {
      print("❌ Error adding inventory transaction: $e");
      rethrow;
    }
  }

  /// Batch add multiple inventory transactions
  static Future<void> addInventoryTransactionsBatch(
      String userId,
      List<InventoryTransaction> transactions,
      ) async {
    print("🔄 Adding ${transactions.length} inventory transactions...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      final expectedHeaders = [
        'transactionId',
        'itemId',
        'itemName',
        'quantity',
        'type',
        'reason',
        'timestamp',
        'notes',
        'userId',
      ];

      // ✅ Ensure headers exist
      final headers = await _ensureHeadersExist(
        sheetsApi,
        inventoryTransactionSheetName,
        expectedHeaders,
      );

      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');

      List<List<dynamic>> rows = [];
      for (var transaction in transactions) {
        List<dynamic> rowData = [];

        for (var header in headers) {
          final headerName = header.toString().toLowerCase();

          switch (headerName) {
            case 'transactionid':
              rowData.add(transaction.transactionId);
              break;
            case 'itemid':
              rowData.add(transaction.itemId);
              break;
            case 'itemname':
              rowData.add(transaction.itemName);
              break;
            case 'quantity':
              rowData.add(transaction.quantity.toString());
              break;
            case 'type':
              rowData.add(transaction.type);
              break;
            case 'reason':
              rowData.add(transaction.reason);
              break;
            case 'timestamp':
              rowData.add(_dateFormatter.format(transaction.timestamp));
              break;
            case 'notes':
              rowData.add(transaction.notes);
              break;
            case 'userid':
              rowData.add(userId);
              break;
            default:
              rowData.add('');
          }
        }

        rows.add(rowData);
      }

      await sheetsApi.spreadsheets.values.append(
        ValueRange.fromJson({"values": rows}),
        spreadsheetId,
        "$inventoryTransactionSheetName!A:I",
        valueInputOption: "USER_ENTERED",
      );

      print("✅ ${transactions.length} inventory transactions added successfully");
    } catch (e) {
      print("❌ Error adding inventory transactions: $e");
      rethrow;
    }
  }

  /// Fetch inventory transactions for a user
  static Future<List<InventoryTransaction>> getInventoryTransactions({
    String? userId,
    String? itemId,
    String? type,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    print("🔄 Fetching inventory transactions...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get all transaction data
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$inventoryTransactionSheetName!A:I",
      );

      if (response.values == null || response.values!.isEmpty) {
        print("⚠️ No transactions found");
        return [];
      }

      // Extract headers
      final headers = response.values![0]
          .map((h) => h.toString().trim().toLowerCase())
          .toList();

      print("✅ Headers: $headers");

      List<InventoryTransaction> transactions = [];
      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');

      // Iterate through rows
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.isEmpty) continue;

        try {
          Map<String, dynamic> txnMap = {};

          // Map row values to headers
          for (int j = 0; j < headers.length && j < row.length; j++) {
            txnMap[headers[j]] = row[j];
          }

          // Parse transaction
          final txn = InventoryTransaction(
            transactionId: txnMap['transactionid']?.toString() ?? '',
            itemId: txnMap['itemid']?.toString() ?? '',
            itemName: txnMap['itemname']?.toString() ?? '',
            quantity: int.tryParse(txnMap['quantity']?.toString() ?? '0') ?? 0,
            type: txnMap['type']?.toString() ?? '',
            reason: txnMap['reason']?.toString() ?? '',
            timestamp: _parseTransactionDate(txnMap['timestamp']?.toString() ?? ''),
            notes: txnMap['notes']?.toString() ?? '',
          );

          // Apply filters
          if (userId != null && txnMap['userid'].toString() != userId) continue;
          if (itemId != null && txn.itemId != itemId) continue;
          if (type != null && txn.type != type) continue;
          if (fromDate != null && txn.timestamp.isBefore(fromDate)) continue;
          if (toDate != null && txn.timestamp.isAfter(toDate)) continue;

          transactions.add(txn);
        } catch (e) {
          print("⚠️ Error parsing transaction at row ${i + 1}: $e");
          continue;
        }
      }

      print("✅ Found ${transactions.length} transactions");
      return transactions;
    } catch (e) {
      print("❌ Error fetching transactions: $e");
      rethrow;
    }
  }

  /// Get transactions for a specific item
  static Future<List<InventoryTransaction>> getItemTransactions(
      String userId, String itemId) async {
    return getInventoryTransactions(userId: userId, itemId: itemId);
  }

  /// Get transactions of specific type
  static Future<List<InventoryTransaction>> getTransactionsByType(
      String userId, String type) async {
    return getInventoryTransactions(userId: userId, type: type);
  }

  /// Get transactions within date range
  static Future<List<InventoryTransaction>> getTransactionsByDateRange(
      String userId, DateTime fromDate, DateTime toDate) async {
    return getInventoryTransactions(
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  /// Get transaction statistics for inventory analysis
  static Future<Map<String, dynamic>> getInventoryStats(String userId) async {
    print("🔄 Calculating inventory statistics...");

    try {
      final transactions = await getInventoryTransactions(userId: userId);

      if (transactions.isEmpty) {
        return {
          'totalTransactions': 0,
          'totalAdded': 0,
          'totalRemoved': 0,
          'totalSales': 0,
          'totalReturns': 0,
          'totalAdjustments': 0,
          'itemsAffected': 0,
        };
      }

      int totalAdded = 0;
      int totalRemoved = 0;
      int totalSales = 0;
      int totalReturns = 0;
      int totalAdjustments = 0;
      Set<String> itemIds = {};

      for (var txn in transactions) {
        itemIds.add(txn.itemId);

        switch (txn.type) {
          case 'add':
            totalAdded += txn.quantity;
            break;
          case 'remove':
            totalRemoved += txn.quantity;
            break;
          case 'sale':
            totalSales += txn.quantity;
            break;
          case 'return':
            totalReturns += txn.quantity;
            break;
          case 'adjustment':
            totalAdjustments += txn.quantity;
            break;
        }
      }

      final stats = {
        'totalTransactions': transactions.length,
        'totalAdded': totalAdded,
        'totalRemoved': totalRemoved,
        'totalSales': totalSales,
        'totalReturns': totalReturns,
        'totalAdjustments': totalAdjustments,
        'itemsAffected': itemIds.length,
        'netChange': totalAdded - totalRemoved,
      };

      print("✅ Statistics: $stats");
      return stats;
    } catch (e) {
      print("❌ Error calculating stats: $e");
      return {};
    }
  }

  /// Delete old transactions (for maintenance)
  static Future<void> deleteOldTransactions(
      String userId, DateTime beforeDate) async {
    print("🗑️ Deleting transactions before $beforeDate for user $userId");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get all transactions
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$inventoryTransactionSheetName!A:I",
      );

      if (response.values == null || response.values!.length <= 1) {
        print("⚠️ No data to delete");
        return;
      }

      final headers = response.values![0];
      final userIdIndex = headers.indexOf('userId');
      final timestampIndex = headers.indexOf('timestamp');

      if (userIdIndex == -1 || timestampIndex == -1) {
        throw Exception("Required columns not found");
      }

      // Get sheet ID for batch delete
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      final sheet = spreadsheet.sheets!
          .firstWhere((s) => s.properties?.title == inventoryTransactionSheetName);
      final sheetId = sheet.properties!.sheetId!;

      List<int> rowsToDelete = [];

      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];

        if (row.length > userIdIndex && row[userIdIndex].toString() == userId) {
          if (row.length > timestampIndex) {
            final timestamp = _parseTransactionDate(row[timestampIndex].toString());
            if (timestamp.isBefore(beforeDate)) {
              rowsToDelete.add(i);
            }
          }
        }
      }

      if (rowsToDelete.isEmpty) {
        print("ℹ️ No transactions to delete");
        return;
      }

      // Delete rows in reverse order
      List<Request> deleteRequests = [];
      for (int rowIndex in rowsToDelete.reversed) {
        deleteRequests.add(
          Request()
            ..deleteDimension = (DeleteDimensionRequest()
              ..range = (DimensionRange()
                ..sheetId = sheetId
                ..dimension = 'ROWS'
                ..startIndex = rowIndex
                ..endIndex = rowIndex + 1)),
        );
      }

      final batchRequest = BatchUpdateSpreadsheetRequest()..requests = deleteRequests;

      await sheetsApi.spreadsheets.batchUpdate(batchRequest, spreadsheetId);

      print("✅ Deleted ${rowsToDelete.length} old transactions");
    } catch (e) {
      print("❌ Error deleting transactions: $e");
      rethrow;
    }
  }

  /// Helper function to parse transaction timestamps
  static DateTime _parseTransactionDate(String dateString) {
    if (dateString.isEmpty) return DateTime.now();

    try {
      // Try format: dd/MM/yyyy HH:mm:ss
      final formats = [
        'dd/MM/yyyy HH:mm:ss',
        'dd/MM/yyyy',
        'yyyy-MM-dd HH:mm:ss',
        'yyyy-MM-dd',
      ];

      for (var format in formats) {
        try {
          return DateFormat(format).parseStrict(dateString);
        } catch (_) {
          continue;
        }
      }

      // Fallback to parse ISO format
      return DateTime.parse(dateString);
    } catch (e) {
      print("⚠️ Could not parse date '$dateString', using current time");
      return DateTime.now();
    }
  }

  ///Customer Api
  /// Add customer to Google Sheet
  static Future<void> addCustomer(Map<String, dynamic> customerData, String userId) async {
    print("🔄 Adding customer to Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Define expected headers (companyName, createdBy, createdByEmail removed per user request)
      final expectedHeaders = [
        'customerId',
        'companyId',
        'name',
        'address',
        'city',
        'state',
        'country',
        'pincode',
        'gst',
        'pan',
        'businessName',
        'businessType',
        'mobile1',
        'mobile2',
        'email',
        'website',
        'notes',
        'sundryType',
        'isActive',
        'createdAt',
        'updatedAt',
      ];

      // Get or create headers
      final headers = await _getOrCreateHeaders(
        sheetsApi,
        customerSheetName,
        expectedHeaders,
      );

      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');

      // Prepare row values in correct column order
      List<dynamic> rowData = [];

      for (var header in headers) {
        String headerLower = header.toString().toLowerCase().trim();

        switch (headerLower) {
          case 'customerid':
            rowData.add(customerData['customerId'] ?? '');
            break;
          case 'companyid':
            rowData.add(customerData['companyId'] ?? '');
            break;
          case 'name':
            rowData.add(customerData['name'] ?? '');
            break;
          case 'address':
            rowData.add(customerData['address'] ?? '');
            break;
          case 'city':
            rowData.add(customerData['city'] ?? '');
            break;
          case 'state':
            rowData.add(customerData['state'] ?? '');
            break;
          case 'country':
            rowData.add(customerData['country'] ?? '');
            break;
          case 'pincode':
            rowData.add(customerData['pincode'] ?? '');
            break;
          case 'gst':
            rowData.add(customerData['gst'] ?? '');
            break;
          case 'pan':
            rowData.add(customerData['pan'] ?? '');
            break;
          case 'businessname':
            rowData.add(customerData['businessName'] ?? '');
            break;
          case 'businesstype':
            rowData.add(customerData['businessType'] ?? '');
            break;
          case 'mobile1':
            rowData.add(customerData['mobile1'] ?? '');
            break;
          case 'mobile2':
            rowData.add(customerData['mobile2'] ?? '');
            break;
          case 'email':
            rowData.add(customerData['email'] ?? '');
            break;
          case 'website':
            rowData.add(customerData['website'] ?? '');
            break;
          case 'notes':
            rowData.add(customerData['notes'] ?? '');
            break;
          case 'sundrytype':
            rowData.add(customerData['sundryType'] ?? 'Debtors');
            break;
          case 'isactive':
            rowData.add(customerData['isActive']?.toString() ?? 'TRUE');
            break;
          case 'createdat':
            rowData.add(_dateFormatter.format(DateTime.now()));
            break;
          case 'updatedat':
            rowData.add(_dateFormatter.format(DateTime.now()));
            break;
          default:
            rowData.add(customerData[header.toString()] ?? '');
        }
      }

      print("Prepared customer row: $rowData");

      // Append row
      final valueRange = ValueRange.fromJson({
        "values": [rowData],
      });

      await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        "$customerSheetName!A:Z",
        valueInputOption: "USER_ENTERED",
      );

      print("✅ Customer added successfully to Google Sheet");
    } catch (e) {
      print("❌ Error adding customer: $e");
      throw Exception("Failed to add customer: ${e.toString()}");
    }
  }

  /// Get customers from Google Sheet
  static Future<List<Map<String, dynamic>>> getCustomers({
    String? companyId,
    String? userId,
  }) async {
    print("🔄 Fetching customers from Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get all data from the sheet
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$customerSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        print("No customers found in sheet");
        return [];
      }

      // Extract headers
      final headers = response.values![0].map((h) => h.toString().trim()).toList();
      print("✅ Headers: $headers");

      List<Map<String, dynamic>> customers = [];

      // Skip header row (index 0)
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];

        if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
          continue;
        }

        try {
          Map<String, dynamic> customerMap = {};
          for (int j = 0; j < headers.length && j < row.length; j++) {
            customerMap[headers[j]] = row[j];
          }

          // Apply filters
          if (companyId != null && customerMap['companyId']?.toString() != companyId) {
            continue;
          }

          customers.add(customerMap);
          print("✅ Added customer: ${customerMap['name']}");
        } catch (e) {
          print("Error parsing customer row ${i}: $e");
          continue;
        }
      }

      print("✅ Retrieved ${customers.length} customers from Google Sheet");
      return customers;
    } catch (e) {
      print("Error in getCustomers: $e");
      rethrow;
    }
  }

  /// Update customer in Google Sheet
  static Future<void> updateCustomer(
      Map<String, dynamic> customerData, String userId) async {
    print("🔄 Updating customer in Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get all customers
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$customerSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        throw Exception("❌ Customer sheet is empty");
      }

      final headers = response.values![0];
      final customerIdIndex = headers.indexOf("customerId");

      if (customerIdIndex == -1) {
        throw Exception("❌ Missing customerId column in sheet");
      }

      int? rowToUpdate;

      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length > customerIdIndex &&
            row[customerIdIndex].toString() == customerData["customerId"].toString()) {
          rowToUpdate = i + 1;
          break;
        }
      }

      if (rowToUpdate == null) {
        throw Exception("❌ Customer not found for update (id: ${customerData["customerId"]})");
      }

      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');

      // Build row data
      List<dynamic> rowData = [];

      for (var header in headers) {
        String headerLower = header.toString().toLowerCase().trim();

        switch (headerLower) {
          case 'customerid':
            rowData.add(customerData['customerId'] ?? '');
            break;
          case 'companyid':
            rowData.add(customerData['companyId'] ?? '');
            break;
          case 'name':
            rowData.add(customerData['name'] ?? '');
            break;
          case 'address':
            rowData.add(customerData['address'] ?? '');
            break;
          case 'city':
            rowData.add(customerData['city'] ?? '');
            break;
          case 'state':
            rowData.add(customerData['state'] ?? '');
            break;
          case 'country':
            rowData.add(customerData['country'] ?? '');
            break;
          case 'pincode':
            rowData.add(customerData['pincode'] ?? '');
            break;
          case 'gst':
            rowData.add(customerData['gst'] ?? '');
            break;
          case 'pan':
            rowData.add(customerData['pan'] ?? '');
            break;
          case 'businessname':
            rowData.add(customerData['businessName'] ?? '');
            break;
          case 'businesstype':
            rowData.add(customerData['businessType'] ?? '');
            break;
          case 'mobile1':
            rowData.add(customerData['mobile1'] ?? '');
            break;
          case 'mobile2':
            rowData.add(customerData['mobile2'] ?? '');
            break;
          case 'email':
            rowData.add(customerData['email'] ?? '');
            break;
          case 'website':
            rowData.add(customerData['website'] ?? '');
            break;
          case 'notes':
            rowData.add(customerData['notes'] ?? '');
            break;
          case 'sundrytype':
            rowData.add(customerData['sundryType'] ?? 'Debtors');
            break;
          case 'isactive':
            rowData.add(customerData['isActive']?.toString() ?? 'TRUE');
            break;
          case 'updatedat':
            rowData.add(_dateFormatter.format(DateTime.now()));
            break;
          default:
            rowData.add(customerData[header.toString()] ?? '');
        }
      }

      final range = "$customerSheetName!A$rowToUpdate:${String.fromCharCode(65 + headers.length - 1)}$rowToUpdate";

      final valueRange = ValueRange(
        values: [rowData],
      );

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: "USER_ENTERED",
      );

      print("✅ Customer updated successfully at row $rowToUpdate");
    } catch (e) {
      print("❌ Error updating customer: $e");
      rethrow;
    }
  }

  /// Delete customer from Google Sheet
  static Future<void> deleteCustomer(String customerId, String userId) async {
    print("🗑️ Deleting customer: $customerId");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get all customers
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$customerSheetName!A:Z",
      );

      if (response.values == null || response.values!.isEmpty) {
        print("⚠️ Sheet is empty");
        return;
      }

      final headers = response.values![0];
      final customerIdIndex = headers.indexOf("customerId");

      if (customerIdIndex == -1) {
        throw Exception("❌ customerId column not found");
      }

      int? rowToDelete;

      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.length > customerIdIndex &&
            row[customerIdIndex].toString() == customerId) {
          rowToDelete = i;
          break;
        }
      }

      if (rowToDelete == null) {
        print("⚠️ Customer not found: $customerId");
        return;
      }

      // Get sheet ID
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      final sheet = spreadsheet.sheets!
          .firstWhere((s) => s.properties?.title == customerSheetName);
      final sheetId = sheet.properties!.sheetId!;

      // Delete the row
      final deleteRequest = Request()
        ..deleteDimension = (DeleteDimensionRequest()
          ..range = (DimensionRange()
            ..sheetId = sheetId
            ..dimension = 'ROWS'
            ..startIndex = rowToDelete
            ..endIndex = rowToDelete + 1));

      final batchRequest = BatchUpdateSpreadsheetRequest()..requests = [deleteRequest];

      await sheetsApi.spreadsheets.batchUpdate(batchRequest, spreadsheetId);

      print("✅ Customer deleted successfully");
    } catch (e) {
      print("❌ Error deleting customer: $e");
      rethrow;
    }
  }

  /// Validate all sheets and add missing columns
  static Future<void> validateAndUpdateAllSheets() async {
    print("");
    print("=" * 70);
    print("🔍 VALIDATING ALL SHEETS AND COLUMNS");
    print("=" * 70);

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Define expected structure for all sheets
      final sheetStructures = {
        itemSheetName: [
          'itemId',
          'itemName',
          'price',
          'sellPrice',
          'gstPercent',
          'unitOfMeasurement',
          'currentStock',
          'detailRequirement',
          'isActive',
          'userId',
          'createdAt',
          'updatedAt',
        ],
        invoiceSheetName: [
          'invoiceId',
          'customerId',
          'customerName',
          'customerEmail',
          // 'customerPan',          // ✅ NEW
          // 'customerGst',          // ✅ NEW
          'mobile',
          'customerAddress',
          'issueDate',
          'dueDate',
          'subtotal',
          'gstAmount',
          'totalAmount',
          'receivedAmount',
          'pendingAmount',
          'status',
          'paymentMode',          // ✅ NEW - PAYMENT MODE
          'notes',
          'profit',
          'userId',
          'isDeleted',
          // 'createdAt',
          // 'updatedAt',
        ],
        invoiceItemSheetName: [
          'invoiceId',
          'customerId',
          'itemId',
          'itemName',
          'description',
          'quantity',
          'rate',
          'purchasePrice',
          'price',
          'issueDate',
          'gstRate',
          'gstAmount',
          'totalPrice',
          'unit',
          'userId',
        ],
        challanSheetName: [
          'challanId',
          'customerId',
          'customerName',
          'customerEmail',
          'customerMobile',
          'customerAddress',
          'challanDate',
          'subtotal',
          'gstRate',
          'gstAmount',
          'totalAmount',
          'status',
          'paymentStatus',
          'notes',
          'userId',
        ],
        challanItemSheetName: [
          'challanId',
          'customerId',
          'itemId',
          'itemName',
          'description',
          'quantity',
          'price',
          'challanDate',
          'gstRate',
          'gstAmount',
          'amountWithGst',
          'totalPrice',
        ],
        purchaseSheetName: [
          'purchaseId',
          'vendorId',
          'vendorName',
          'vendorEmail',
          'vendorMobile',
          'vendorAddress',
          'purchaseDate',
          'dueDate',
          'subtotal',
          'gstRate',
          'gstAmount',
          'totalAmount',
          'paidAmount',
          'pendingAmount',
          'paymentStatus',
          'paymentMethod',
          'notes',
          'userId',
        ],
        purchaseItemSheetName: [
          'purchaseId',
          'vendorId',
          'itemId',
          'itemName',
          'description',
          'quantity',
          'purchasePrice',
          'purchaseDate',
          'gstRate',
          'totalPrice',
          'unit',
          'userId',
        ],
        inventoryTransactionSheetName: [
          'transactionId',
          'itemId',
          'itemName',
          'quantity',
          'type',
          'reason',
          'timestamp',
          'notes',
          'userId',
        ],
        customerSheetName: [
          'customerId',
          'companyId',
          'name',
          'address',
          'city',
          'state',
          'country',
          'pincode',
          'gst',
          'pan',
          'businessName',
          'businessType',
          'mobile1',
          'mobile2',
          'email',
          'website',
          'notes',
          'sundryType',
          'isActive',
          'createdAt',
          'updatedAt',
        ],
      };

      int totalSheets = sheetStructures.length;
      int validatedSheets = 0;
      int createdSheets = 0;
      int updatedSheets = 0;
      int errorSheets = 0;

      // Process each sheet
      for (var entry in sheetStructures.entries) {
        final sheetName = entry.key;
        final expectedHeaders = entry.value;

        try {
          print("");
          print("─" * 70);
          print("📋 Checking: $sheetName");

          // Check if sheet exists
          final sheetExists = await _sheetExists(sheetsApi, sheetName);

          if (!sheetExists) {
            print("   ⚠️  Sheet doesn't exist - creating...");
            await _createSheet(sheetsApi, sheetName);
            await Future.delayed(Duration(milliseconds: 500));
            createdSheets++;
          }

          // Get current headers
          final headerResponse = await sheetsApi.spreadsheets.values.get(
            spreadsheetId,
            "$sheetName!1:1",
          );

          List<String> currentHeaders = [];
          if (headerResponse.values != null && headerResponse.values!.isNotEmpty) {
            currentHeaders = headerResponse.values![0]
                .map((h) => h.toString().trim())
                .toList();
          }

          if (currentHeaders.isEmpty) {
            // No headers - create them
            print("   ⚠️  No headers found - creating...");
            await sheetsApi.spreadsheets.values.update(
              ValueRange.fromJson({"values": [expectedHeaders]}),
              spreadsheetId,
              "$sheetName!A1",
              valueInputOption: "USER_ENTERED",
            );
            print("   ✅ Headers created: ${expectedHeaders.length} columns");
            updatedSheets++;
          } else {
            // Check for missing columns
            final missingHeaders = <String>[];
            for (var expected in expectedHeaders) {
              final found = currentHeaders.any(
                      (current) => current.toLowerCase() == expected.toLowerCase()
              );
              if (!found) {
                missingHeaders.add(expected);
              }
            }

            if (missingHeaders.isNotEmpty) {
              print("   ⚠️  Missing columns: ${missingHeaders.join(', ')}");

              // Add missing columns
              final updatedHeaders = [...currentHeaders, ...missingHeaders];

              final lastColLetter = _getColumnLetter(updatedHeaders.length);
              await sheetsApi.spreadsheets.values.update(
                ValueRange.fromJson({"values": [updatedHeaders]}),
                spreadsheetId,
                "$sheetName!A1:${lastColLetter}1",
                valueInputOption: "USER_ENTERED",
              );

              print("   ✅ Added ${missingHeaders.length} missing column(s)");
              updatedSheets++;
            } else {
              print("   ✅ All columns present (${currentHeaders.length} columns)");
            }
          }

          validatedSheets++;

        } catch (e) {
          print("   ❌ Error processing $sheetName: $e");
          errorSheets++;
        }
      }

      // Print summary
      print("");
      print("=" * 70);
      print("📊 VALIDATION SUMMARY");
      print("=" * 70);
      print("Total Sheets:        $totalSheets");
      print("✅ Validated:        $validatedSheets");
      print("🆕 Created:          $createdSheets");
      print("🔧 Updated:          $updatedSheets");
      print("❌ Errors:           $errorSheets");
      print("=" * 70);

      if (errorSheets == 0) {
        print("🎉 ALL SHEETS VALIDATED SUCCESSFULLY!");
      } else {
        print("⚠️  Some sheets had errors - please check logs above");
      }
      print("=" * 70);
      print("");

    } catch (e, stackTrace) {
      print("❌ Critical error in validateAndUpdateAllSheets: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }


  /// Quick validation check (doesn't modify, just reports)
  static Future<Map<String, dynamic>> checkSheetHealth() async {
    print("🏥 Running sheet health check...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      final requiredSheets = [
        itemSheetName,
        invoiceSheetName,
        invoiceItemSheetName,
        challanSheetName,
        challanItemSheetName,
        purchaseSheetName,
        purchaseItemSheetName,
        inventoryTransactionSheetName,
        customerSheetName,
      ];

      Map<String, bool> sheetStatus = {};
      Map<String, List<String>> sheetHeaders = {};

      for (var sheetName in requiredSheets) {
        final exists = await _sheetExists(sheetsApi, sheetName);
        sheetStatus[sheetName] = exists;

        if (exists) {
          try {
            final response = await sheetsApi.spreadsheets.values.get(
              spreadsheetId,
              "$sheetName!1:1",
            );
            if (response.values != null && response.values!.isNotEmpty) {
              sheetHeaders[sheetName] = response.values![0]
                  .map((h) => h.toString().trim())
                  .toList();
            }
          } catch (e) {
            print("⚠️ Could not read headers for $sheetName");
          }
        }
      }

      return {
        'allSheetsExist': !sheetStatus.values.contains(false),
        'sheetStatus': sheetStatus,
        'sheetHeaders': sheetHeaders,
      };

    } catch (e) {
      print("❌ Error in checkSheetHealth: $e");
      return {'error': e.toString()};
    }
  }


  // ✅ ADD THIS METHOD TO GoogleSheetService class
// This will print ALL columns in the Invoice sheet to help debug

  /// Print all columns in Invoice sheet for debugging
  static Future<void> printInvoiceSheetColumns() async {
    print("ttttttttttttt");
    print("=" * 70);
    print("🔍 PRINTING ALL INVOICE SHEET COLUMNS");
    print("=" * 70);

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Get header row from Invoice sheet
      final headerResponse = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$invoiceSheetName!1:1",
      );

      if (headerResponse.values == null || headerResponse.values!.isEmpty) {
        print("❌ No headers found in Invoice sheet");
        print("=" * 70);
        return;
      }

      final headers = headerResponse.values![0]
          .map((h) => h.toString().trim())
          .toList();

      print("");
      print("📋 Total Columns: ${headers.length}");
      print("");
      print("Column #  | Column Name");
      print("-" * 70);

      for (int i = 0; i < headers.length; i++) {
        final colNumber = (i + 1).toString().padLeft(8);
        final colLetter = _getColumnLetter(i + 1).padRight(3);
        print("$colNumber ($colLetter) | ${headers[i]}");
      }

      print("-" * 70);

      // Check for specific columns
      print("");
      print("🔍 Checking for specific columns:");
      print("");

      final requiredColumns = [
        'invoiceId',
        'customerId',
        'customerName',
        'status',
        'paymentMode',    // ← THE MISSING ONE
        'customerPan',
        'customerGst',
        'totalAmount',
      ];

      for (var reqCol in requiredColumns) {
        final found = headers.any(
                (h) => h.toLowerCase() == reqCol.toLowerCase()
        );

        if (found) {
          final index = headers.indexWhere(
                  (h) => h.toLowerCase() == reqCol.toLowerCase()
          );
          print("   ✅ '$reqCol' - EXISTS at column ${index + 1} (${_getColumnLetter(index + 1)})");
        } else {
          print("   ❌ '$reqCol' - MISSING!");
        }
      }

      print("");
      print("=" * 70);
      print("");

    } catch (e, stackTrace) {
      print("❌ Error printing Invoice columns: $e");
      print("Stack trace: $stackTrace");
      print("=" * 70);
    }
  }

// Helper method (if not already present)
  static String _getColumnLetter(int colIndex) {
    String columnName = '';
    while (colIndex > 0) {
      int modulo = (colIndex - 1) % 26;
      columnName = String.fromCharCode(65 + modulo) + columnName;
      colIndex = ((colIndex - modulo) ~/ 26);
    }
    return columnName;
  }
}

///see this googleSheet Service file if Customer table is not Found so It Auto created i want Same funcnality for all other tables so Please Give meupdate