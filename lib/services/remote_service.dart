import 'dart:convert';
import 'dart:math';
import 'dart:math' as Math;

import 'package:demo_prac_getx/constant/app_constant.dart';
import 'package:demo_prac_getx/model/comment_model.dart';
import 'package:demo_prac_getx/services/api.dart';
import 'package:demo_prac_getx/utils/shared_preferences_helper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/model.dart';
import '../utils/pdf_helper.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/sheets/v4.dart';
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
  //static const spreadsheetId = "1mzdsQcY7dpUdVvktCK8Ocrtz1g5CehDOItcIzdjjRoQ"; // from Sheet URL
  static String spreadsheetId = "${AppConstants.spreadsheetId}"; // from Sheet URL
  static const itemSheetName = "Item"; // your sheet/tab name
  static const invoiceSheetName = "Invoice"; // your sheet/tab name
  static const invoiceItemSheetName = "InvoiceItems"; // your sheet/tab name
  static const challanSheetName = "Challan"; // your sheet/tab name
  static const challanItemSheetName = "ChallanItems"; // your sheet/tab name


  static List<String>? _cachedHeaders;
  static final Map<String, List<ChallanItem>> _challanCache = {};


  /// Load credentials from assets/credentials.json
  static Future<AuthClient> _getAuthClient() async {
    final credentialsJson = await rootBundle.loadString('assets/invoicesathi-4ca968cb8212.json');

   print("------------Creddd-------------${credentialsJson}");
    final accountCredentials =
    ServiceAccountCredentials.fromJson(jsonDecode(credentialsJson));
    final scopes = [SheetsApi.spreadsheetsScope];

    return await clientViaServiceAccount(accountCredentials, scopes);
  }

  /// Add a new item row to Google Sheet
  static Future<void> addItem(String userId, Item item) async {
    final client = await _getAuthClient();
    final sheetsApi = SheetsApi(client);

    print("---------========Sheet API...........-----${sheetsApi}");
    // Prepare row values in correct column order
    final values = [
      item.itemId,
      item.itemName,
      item.price.toString(),
      item.gstPercent.toString(),
      item.unitOfMeasurement,
      item.currentStock.toString(),
      item.detailRequirement,
      item.isActive ? "TRUE" : "FALSE",
      userId,
    ];

    // Append row
    await sheetsApi.spreadsheets.values.append(
      ValueRange.fromJson({
        "values": [values]
      }),
      spreadsheetId,
      "$itemSheetName!A:I", // Adjust columns (A-H based on your schema)
      valueInputOption: "RAW",
    );

    print("✅ Item added successfully to Google Sheet");
  }

  // Get items from Google Sheet with optional user filtering
  static Future<List<Item>> getItems({String? userId}) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      print("---------========Sheets API Get Items...........-----${sheetsApi}");

      // Get all data from the sheet
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$itemSheetName!A:I", // Adjust range based on your columns
      );

      print("Response: ${response.values}");

      if (response.values == null || response.values!.isEmpty) {
        print("No data found in sheet");
        return <Item>[];
      }

      List<Item> items = [];

      // Skip header row (index 0) if it exists
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];

        // Ensure row has enough columns
        if (row.length < 9) {
          print("Skipping incomplete row ${i}: $row");
          continue;
        }

        try {
          // Parse row data according to your schema
          final item = Item(
            itemId: row[0]?.toString() ?? '',
            itemName: row[1]?.toString() ?? '',
            price: double.tryParse(row[2]?.toString() ?? '0') ?? 0.0,
            gstPercent : double.tryParse(row[3]?.toString() ?? '0') ?? 0.0,
            unitOfMeasurement: row[4]?.toString() ?? '',
            currentStock: int.tryParse(row[5]?.toString() ?? '0') ?? 0,
            detailRequirement: row[6]?.toString() ?? '',
            isActive: (row[7]?.toString().toLowerCase() == 'true'),
            // Assuming userId is in column I (index 8)
          );

          // Filter by userId if provided
          if (userId != null && userId.isNotEmpty) {
            String rowUserId = row[8]?.toString() ?? '';
            if (rowUserId == userId) {
              items.add(item);
            }
          } else {
            // No filter, add all items
            items.add(item);
          }

        } catch (e) {
          print("Error parsing row ${i}: $e");
          print("Row data: $row");
          continue;
        }
      }

      print("✅ Retrieved ${items.length} items from Google Sheet");
      return items;

    } catch (e) {
      print("Error in getItems: $e");
      rethrow;
    }
  }

  // Edit item using Google Sheets API (delete and re-add approach)
  static Future<void> editItemAlternative3(String userId, Item item) async {
    print("=== TRYING ALTERNATIVE 3: DELETE AND ADD (Google Sheets) ===");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);


    // Get sheet metadata to find the correct sheetId (safer than hardcoding 0)
    final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
    final sheet = spreadsheet.sheets!
        .firstWhere((s) => s.properties?.title == itemSheetName);
    final sheetId = sheet.properties!.sheetId!;
      // Step 1: Find and delete the existing item
      print("Step 1: Finding item to delete...");

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$itemSheetName!A:I",
      );

      if (response.values == null || response.values!.isEmpty) {
        throw Exception("No data found in sheet");
      }

      int? targetRowIndex;
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.isNotEmpty && row[0]?.toString() == item.itemId) {
          targetRowIndex = i; // 0-based index for delete operation
          break;
        }
      }

      if (targetRowIndex == null) {
        throw Exception("Item with ID ${item.itemId} not found");
      }

      print("Found item at row index: $targetRowIndex");

      // Delete the row using batch update
      final deleteRequests = [
        Request()
          ..deleteDimension = (DeleteDimensionRequest()
            ..range = (DimensionRange()
              ..sheetId = sheetId // Adjust if your sheet has different ID
              ..dimension = 'ROWS'
              ..startIndex = targetRowIndex
              ..endIndex = targetRowIndex + 1))
      ];

      final deleteBatchRequest = BatchUpdateSpreadsheetRequest()
        ..requests = deleteRequests;

      print("Deleting row...");
      await sheetsApi.spreadsheets.batchUpdate(
        deleteBatchRequest,
        spreadsheetId,
      );

      print("Delete successful");

      // Step 2: Add the updated item (small delay for consistency)
      await Future.delayed(Duration(seconds: 1));

      print("Step 2: Adding updated item...");

      // Prepare updated row values
      final values = [
        item.itemId,
        item.itemName,
        item.price.toString(),
        item.gstPercent.toString(),
        item.unitOfMeasurement,
        item.currentStock.toString(),
        item.detailRequirement,
        item.isActive ? "TRUE" : "FALSE",
        userId,
      ];

      print("Adding values: $values");

      // Append the updated row
      await sheetsApi.spreadsheets.values.append(
        ValueRange.fromJson({
          "values": [values]
        }),
        spreadsheetId,
        "$itemSheetName!A:H",
        valueInputOption: "RAW",
      );

      print("Add successful - Item edited using delete and add approach");

    } catch (e) {
      print("Error in editItemAlternative3: $e");
      rethrow;
    }
  }


  ///Invoice
  // Get all invoices from Google Sheet
  static Future<List<Invoice>> getInvoices() async {
    print("🔄 Fetching invoices from Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // First, get the header row to understand column positions
      final headerResponse = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$invoiceSheetName!1:1", // Get only the header row
      );

      print("----Header Response: -------${spreadsheetId}");
      if (headerResponse.values == null || headerResponse.values!.isEmpty) {
        print("No header row found in sheet");
        return <Invoice>[];
      }

      final headers = headerResponse.values![0];
      print("Sheet headers: $headers");

      // Create a map of column names to indices
      final columnIndices = {};
      for (int i = 0; i < headers.length; i++) {
        columnIndices[headers[i].toString().toLowerCase()] = i;
      }
      print("Column indices: $columnIndices");

      // Get all data from the invoice sheet
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$invoiceSheetName!A:Z", // Get all columns
      );

      if (response.values == null || response.values!.isEmpty) {
        print("No invoice data found in sheet");
        return <Invoice>[];
      }

      if (response.values!.length <= 1) {
        print("Only header row found, no invoice data");
        return <Invoice>[];
      }

      List<Invoice> invoices = [];

      // Skip header row (index 0)
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];

        // Skip empty rows
        if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
          continue;
        }

        try {
          // Create a map using the header names as keys
          Map<String, dynamic> rowData = {};
          for (int j = 0; j < min(row.length, headers.length); j++) {
            rowData[headers[j].toString()] = row[j];
          }

          // Convert to Invoice object
          final invoice = Invoice.fromMap(rowData);
          invoices.add(invoice);

        } catch (e) {
          print("Error parsing invoice row ${i}: $e");
          print("Row data: $row");
          continue;
        }
      }

      print("✅ Retrieved ${invoices.length} invoices from Google Sheet");
      return invoices;

    } catch (e) {
      print("❌ Error in getInvoices: $e");
      rethrow; // Re-throw to let caller handle fallback
    }
  }

// Add invoice to Google Sheet
  static Future<void> addInvoice(dynamic invoiceData, String userId) async {
    print("🔄 Adding invoice to Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      print("Sheets API initialized for adding invoice");

      // Determine which sheet to use based on your structure
      String targetSheetName = "Invoice"; // Default sheet name
      print("Using sheet: $targetSheetName");

      // First, get the header row to understand column order
      final headerResponse = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$targetSheetName!1:1", // Get only the header row
      );

      if (headerResponse.values == null || headerResponse.values!.isEmpty) {
        throw Exception("No header row found in sheet '$targetSheetName'");
      }

      final headers = headerResponse.values![0];
      print("Sheet headers: $headers");

      List<List<dynamic>> rowsToAdd = [];

      if (invoiceData is Map<String, dynamic>) {
        // Single invoice data
        rowsToAdd.add(_prepareInvoiceRow(invoiceData, userId, headers));
      } else if (invoiceData is List<Invoice>) {
        // Multiple invoices
        for (Invoice invoice in invoiceData) {
          rowsToAdd.add(_prepareInvoiceRow(invoice.toMap(), userId, headers));
        }
      } else if (invoiceData is Invoice) {
        // Single Invoice object
        rowsToAdd.add(_prepareInvoiceRow(invoiceData.toMap(), userId, headers));
      } else {
        throw Exception("Invalid invoice data format: ${invoiceData.runtimeType}");
      }

      print("Prepared ${rowsToAdd.length} rows to add");

      // Add all rows to the sheet
      final valueRange = ValueRange.fromJson({
        "values": rowsToAdd
      });

      final response = await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        "$targetSheetName!A:Z",
        valueInputOption: "USER_ENTERED", // Better formatting
      );

      if (response.updates?.updatedRows != null) {
        print("✅ Invoice(s) added successfully. Rows affected: ${response.updates!.updatedRows}");
      } else {
        print("✅ Invoice(s) added successfully");
      }

    } catch (e) {
      print("❌ Error adding invoice: $e");
      throw Exception("Failed to add invoice: ${e.toString()}");
    }
  }

  // Helper method to prepare invoice row data based on actual sheet headers
  static List<dynamic> _prepareInvoiceRow(
      Map<String, dynamic> invoiceData, String userId, List<dynamic> headers) {
    final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

    String _formatDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return "";
      try {
        if (value is DateTime) {
          return _dateFormatter.format(value);
        } else {
          return _dateFormatter.format(DateTime.parse(value.toString()));
        }
      } catch (e) {
        return value.toString(); // fallback if already string
      }
    }

    // Handle items serialization if present
    if (invoiceData.containsKey('items') && invoiceData['items'] is List) {
      invoiceData['items'] = jsonEncode(invoiceData['items']);
    }

    // Add userId
    invoiceData['userId'] = userId;

    // Force issueDate (instead of invoiceDate)
    invoiceData['issueDate'] =
        _formatDate(invoiceData['issueDate'] ?? DateTime.now());

    // Force dueDate
    if (invoiceData.containsKey('dueDate')) {
      invoiceData['dueDate'] = _formatDate(invoiceData['dueDate']);
    }

    // Prepare row values in correct column order
    List<dynamic> rowData = [];

    for (var header in headers) {
      String headerStr = header.toString().toLowerCase();

      if (headerStr.contains('invoice') && headerStr.contains('id')) {
        rowData.add(invoiceData['invoiceId'] ?? '');
      } else if (headerStr.contains('customer') && headerStr.contains('name')) {
        rowData.add(invoiceData['customerName'] ?? '');
      } else if (headerStr.contains('customer') && headerStr.contains('email')) {
        rowData.add(invoiceData['customerEmail'] ?? '');
      } else if (headerStr.contains('customer') && headerStr.contains('phone')) {
        rowData.add(invoiceData['customerPhone'] ?? '');
      } else if (headerStr.contains('customer') && headerStr.contains('address')) {
        rowData.add(invoiceData['customerAddress'] ?? '');
      } else if (headerStr.contains('issue') && headerStr.contains('date')) {
        rowData.add(invoiceData['issueDate']); // ✅ correct mapping
      } else if (headerStr.contains('due') && headerStr.contains('date')) {
        rowData.add(invoiceData['dueDate']); // ✅ correct mapping
      } else if (headerStr.contains('total') && headerStr.contains('amount')) {
        rowData.add(invoiceData['totalAmount']?.toString() ?? '0');
      } else if (headerStr.contains('tax') && headerStr.contains('amount')) {
        rowData.add(invoiceData['taxAmount']?.toString() ?? '0');
      } else if (headerStr.contains('discount') && headerStr.contains('amount')) {
        rowData.add(invoiceData['discountAmount']?.toString() ?? '0');
      } else if (headerStr.contains('status')) {
        rowData.add(invoiceData['status'] ?? 'draft');
      } else if (headerStr.contains('items')) {
        rowData.add(invoiceData['items'] ?? '[]');
      } else if (headerStr.contains('notes')) {
        rowData.add(invoiceData['notes'] ?? '');
      } else if (headerStr.contains('payment') && headerStr.contains('method')) {
        rowData.add(invoiceData['paymentMethod'] ?? '');
      } else if (headerStr.contains('payment') && headerStr.contains('status')) {
        rowData.add(invoiceData['paymentStatus'] ?? 'pending');
      } else if (headerStr.contains('user') && headerStr.contains('id')) {
        rowData.add(userId);
      } else if (headerStr.contains('company') && headerStr.contains('id')) {
        rowData.add(invoiceData['companyId'] ?? '');
      } else {
        rowData.add(invoiceData[header.toString()] ?? '');
      }
    }

    print("Prepared row data: $rowData");
    return rowData;
  }


  static Future<void> updateInvoice(
      Map<String, dynamic> invoiceData, String userId) async {
    print("🔄 Updating invoice in Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);
      const targetSheetName = "Invoice";

      // 1. Get headers
      final headerResponse = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$targetSheetName!1:1",
      );
      final headers = headerResponse.values![0];

      // 2. Find row number
      final allRows = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$targetSheetName!A:Z",
      );

      int rowIndex = -1;
      List<dynamic>? oldRow;

      for (int i = 1; i < (allRows.values?.length ?? 0); i++) {
        final row = allRows.values![i];
        if (row.isNotEmpty && row[0].toString() == invoiceData['invoiceId']) {
          rowIndex = i + 1;
          oldRow = row;
          break;
        }
      }

      if (rowIndex == -1) {
        throw Exception("Invoice ID not found: ${invoiceData['invoiceId']}");
      }

      // 3. Merge values
      final mergedRow = _prepareInvoiceUpdateRow(
        invoiceData,
        userId,
        headers,
        oldRow ?? [],
      );

      // 4. Update row
      final valueRange = ValueRange.fromJson({
        "values": [mergedRow],
      });

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        "$targetSheetName!A$rowIndex:Z$rowIndex",
        valueInputOption: "USER_ENTERED",
      );

      print("✅ Invoice updated at row $rowIndex");
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


  static Future<void> updateInvoiceItems(
      String invoiceId, List<Map<String, dynamic>> items, String userId) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);
      const String itemSheet = "InvoiceItems";

      // 🔹 Get headers
      final headerRes = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$itemSheet!1:1",
      );
      final headers = headerRes.values![0];

      // 🔹 Load all rows
      final allRows = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        itemSheet,
      );

      final values = allRows.values ?? [];
      final rowsToUpdate = <int>[];

      // 🔹 Find row indexes for this invoiceId
      for (int i = 1; i < values.length; i++) {
        if (values[i].isNotEmpty &&
            values[i][0].toString().trim() == invoiceId) {
          rowsToUpdate.add(i + 1); // sheet row index (1-based)
        }
      }

      // 🔹 Overwrite existing rows but PRESERVE unchanged values
      for (int i = 0; i < rowsToUpdate.length; i++) {
        final sheetRow = values[rowsToUpdate[i] - 1]; // current values in sheet

        if (i < items.length) {
          final item = items[i];
          item['invoiceId'] = invoiceId;
          item['userId'] = userId;

          // merge old values with new ones
          final rowValues = <String>[];
          for (int j = 0; j < headers.length; j++) {
            final key = headers[j].toString().trim();
            final newVal = item[key]?.toString();

            if (newVal != null && newVal.isNotEmpty) {
              rowValues.add(newVal); // use new value
            } else if (j < sheetRow.length) {
              rowValues.add(sheetRow[j]?.toString() ?? ""); // preserve old value
            } else {
              rowValues.add(""); // blank if truly new column
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
          // Extra old rows -> clear them
          final range =
              "$itemSheet!A${rowsToUpdate[i]}:${_columnLetter(headers.length)}${rowsToUpdate[i]}";
          await sheetsApi.spreadsheets.values.clear(
            ClearValuesRequest(),
            spreadsheetId,
            range,
          );
        }
      }

      // 🔹 If new items > old rows → append extra ones
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

      print("✅ InvoiceItems updated (preserve unchanged values) for $invoiceId");
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




  /// Add invoice item directly to Google Sheet (without AppSheet API)
  static Future<void> addInvoiceItem(
      Map<String, dynamic> itemData, String userId) async {
    print("🔄 Adding invoice item to Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // String targetSheetName = "InvoiceItems";
      // print("Using sheet: $targetSheetName");

      // Get header row
      final headerResponse = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$invoiceItemSheetName!1:1",
      );

      if (headerResponse.values == null || headerResponse.values!.isEmpty) {
        throw Exception("No header row found in sheet '$invoiceItemSheetName'");
      }

      final headers = headerResponse.values![0];
      print("InvoiceItems headers: $headers");

      // Add userId if it's a column
      if (headers.contains("userId")) {
        itemData['userId'] = userId;
      }

      // ✅ Normalize keys (lowercase)
      final normalizedItemData = {
        for (var entry in itemData.entries)
          entry.key.toString().trim().toLowerCase(): entry.value
      };

      // Prepare row in correct order
      List<dynamic> rowData = [];
      for (var header in headers) {
        final key = header.toString().trim().toLowerCase();
        rowData.add(normalizedItemData[key] ?? '');
      }

      print("Prepared row: $rowData");

      final valueRange = ValueRange.fromJson({
        "values": [rowData],
      });

      final response = await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        "$invoiceItemSheetName!A:Z",
        valueInputOption: "USER_ENTERED",
      );

      if (response.updates?.updatedRows != null) {
        print("✅ Invoice item added successfully. Rows affected: ${response.updates!.updatedRows}");
      } else {
        print("✅ Invoice item added successfully.");
      }
    } catch (e) {
      print("❌ Error adding invoice item: $e");
      throw Exception("Failed to add invoice item: ${e.toString()}");
    }
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
        int currentStock = 0;

        // Find row for this itemId + userId
        for (int i = 1; i < response.values!.length; i++) {
          final row = response.values![i];
          if (row.length > itemIdIndex &&
              row[itemIdIndex].toString() == item.itemId.toString() &&
              row[userIdIndex].toString() == AppConstants.userId) {
            rowToUpdate = i + 1; // rows are 1-based
            if (row.length > stockIndex) {
              currentStock = int.tryParse(row[stockIndex].toString()) ?? 0;
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


  ///Challan
  static Future<void> addChallan(dynamic challanData, String userId) async {
    print("🔄 Adding Challan to Google Sheet...");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);


      // Get header row
      final headerResponse = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanSheetName!1:1",
      );

      if (headerResponse.values == null || headerResponse.values!.isEmpty) {
        throw Exception("No header row found in sheet '$challanSheetName'");
      }

      final headers = headerResponse.values![0];
      print("Challan headers: $headers");

      final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

      String _formatDate(dynamic value) {
        if (value == null || value.toString().isEmpty) return "";
        try {
          if (value is DateTime) {
            return _dateFormatter.format(value);
          } else {
            return _dateFormatter.format(DateTime.parse(value.toString()));
          }
        } catch (e) {
          return value.toString(); // fallback
        }
      }

      // Normalize helper
      Map<String, dynamic> _normalize(Map<String, dynamic> data) {
        return {
          for (var entry in data.entries)
            entry.key.toString().trim().toLowerCase(): entry.value
        };
      }

      // Build rows
      List<Map<String, dynamic>> rowsToSend = [];

      if (challanData is Map<String, dynamic>) {
        if (challanData.containsKey('items') && challanData['items'] is List) {
          challanData['items'] = jsonEncode(challanData['items']);
        }

        // format challanDate
        if (challanData.containsKey('challanDate')) {
          challanData['challanDate'] = _formatDate(challanData['challanDate']);
        }

        rowsToSend.add({...challanData, "userId": userId});
      } else if (challanData is List<Challan>) {
        rowsToSend = challanData.map((chal) {
          final map = chal.toMap();
          if (map.containsKey('items') && map['items'] is List) {
            map['items'] = jsonEncode(map['items']);
          }
          if (map.containsKey('challanDate')) {
            map['challanDate'] = _formatDate(map['challanDate']);
          }
          return {...map, "userId": userId};
        }).toList();
      }

      print("Prepared rows: ${jsonEncode(rowsToSend)}");

      // Convert rows to ordered values matching headers
      List<List<dynamic>> values = [];
      for (var row in rowsToSend) {
        final normalized = _normalize(row);
        List<dynamic> rowData = [];
        for (var header in headers) {
          final key = header.toString().trim().toLowerCase();
          rowData.add(normalized[key] ?? '');
        }
        values.add(rowData);
      }

      print("Prepared ${values.length} row(s) to add");

      // Append rows to Google Sheet
      final valueRange = ValueRange.fromJson({
        "values": values,
      });

      final response = await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        "$challanSheetName!A:Z",
        valueInputOption: "USER_ENTERED",
      );

      if (response.updates?.updatedRows != null) {
        print("✅ Challan(s) added successfully. Rows affected: ${response.updates!.updatedRows}");
      } else {
        print("✅ Challan(s) added successfully.");
      }
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
        int currentStock = 0;

        // Find row for this itemId + userId
        for (int i = 1; i < response.values!.length; i++) {
          final row = response.values![i];
          if (row.length > itemIdIndex &&
              row[itemIdIndex].toString() == item.itemId.toString() &&
              row[userIdIndex].toString() == AppConstants.userId) {
            rowToUpdate = i + 1; // rows are 1-based
            if (row.length > stockIndex) {
              currentStock = int.tryParse(row[stockIndex].toString()) ?? 0;
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

      // Fetch all challan rows
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanSheetName!A:Z", // adjust range if needed
      );

      if (response.values == null || response.values!.length <= 1) {
        print("❌ No challans found in sheet.");
        return <Challan>[];
      }

      // Extract headers from first row
      final headers =
      response.values![0].map((h) => h.toString().trim()).toList();
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
      print("❌ Error in getChallans(): $e");
      rethrow;
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

  static Future<List<InvoiceItem>> getInvoiceItemsByInvoiceId(String invoiceId) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Fetch all invoice item rows
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$invoiceItemSheetName!A:Z",
      );

      if (response.values == null || response.values!.length <= 1) {
        print("❌ No invoice items found in sheet.");
        return [];
      }

      // Extract headers
      final headers = response.values![0]
          .map((h) => h.toString().trim().toLowerCase().replaceAll(RegExp(r'\s+'), ''))
          .toList();

      // Find the index of the invoiceId column (match your column name)
      final invoiceIdIndex = headers.indexOf('invoiceid'); // adjust if your column name is different
      if (invoiceIdIndex == -1) {
        throw Exception("InvoiceId column not found in sheet headers");
      }

      List<InvoiceItem> invoiceItems = [];

      // Iterate rows
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];

        // Check if this row matches the invoiceId
        if (row.length > invoiceIdIndex && row[invoiceIdIndex].toString().trim() == invoiceId) {
          Map<String, dynamic> rowMap = {};
          for (int j = 0; j < headers.length; j++) {
            rowMap[headers[j]] = j < row.length ? row[j].toString().trim() : "";
          }

          try {
            final item = InvoiceItem.fromJson(rowMap);
            invoiceItems.add(item);
          } catch (e) {
            print("⚠️ Skipping row ${i + 1} due to parse error: $e");
          }
        }
      }

      print("✅ Found ${invoiceItems.length} items for invoice $invoiceId");
      return invoiceItems;
    } catch (e) {
      print("❌ Error fetching invoice items by invoiceId: $e");
      return [];
    }
  }

  ///its Working... on 18-09- 2:00PM
  // static Future<List<ChallanItem>> getChallanItemsByChallanId(String challanId) async {
  //   print("🔄 Fetching items for challan: $challanId");
  //
  //   try {
  //     final client = await _getAuthClient();
  //     final sheetsApi = SheetsApi(client);
  //
  //     final response = await sheetsApi.spreadsheets.values.get(
  //       spreadsheetId,
  //       "$challanItemSheetName!A:Z",
  //     );
  //
  //     if (response.values == null || response.values!.length <= 1) {
  //       print("❌ No items found for challan $challanId");
  //       return <ChallanItem>[];
  //     }
  //
  //     final headers = response.values![0].map((h) => h.toString().trim()).toList();
  //     print("✅ Item headers: $headers");
  //
  //     List<ChallanItem> items = [];
  //     int foundCount = 0;
  //
  //     for (int i = 1; i < response.values!.length; i++) {
  //       final row = response.values![i];
  //
  //       if (row.isEmpty) continue;
  //
  //       Map<String, dynamic> itemMap = {};
  //       for (int j = 0; j < headers.length; j++) {
  //         itemMap[headers[j]] = j < row.length ? row[j] : "";
  //       }
  //
  //       // Debug: Print the row data
  //       print("📋 Row $i: $itemMap");
  //
  //       // Filter items by challanId - make sure the field name matches
  //       if (itemMap['challanId'] == challanId ||
  //           itemMap['ChallanId'] == challanId ||
  //           itemMap['CHALLANID'] == challanId) {
  //
  //         try {
  //           ChallanItem item = ChallanItem.fromJson(itemMap);
  //           items.add(item);
  //           foundCount++;
  //           print("✅ Added item: ${item.itemName} for challan $challanId");
  //         } catch (e) {
  //           print("❌ Error parsing challan item: $e");
  //           print("❌ Item data: $itemMap");
  //         }
  //       }
  //     }
  //
  //     print("✅ Found $foundCount items for challan $challanId");
  //     return items;
  //   } catch (e) {
  //     print("❌ Error getting challan items: $e");
  //     return [];
  //   }
  // }

  /// ✅ Get headers (only once per app session, cached in memory)
  static Future<List<String>> _getHeaders(SheetsApi sheetsApi) async {
    if (_cachedHeaders != null) return _cachedHeaders!;

    final response = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      "$challanItemSheetName!A1:Z1",
    );

    _cachedHeaders = response.values?.first
        .map((h) => h.toString().trim())
        .toList() ??
        [];

    print("✅ Cached headers: $_cachedHeaders");
    return _cachedHeaders!;
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

  static Future<List<Challan>> getChallansByDateRange({
    required DateTime fromDate,
    required DateTime toDate,
    required String userId,
  }) async {
    print("🔄 Fetching challans by date range: ${DateFormat('dd/MM/yyyy').format(fromDate)} to ${DateFormat('dd/MM/yyyy').format(toDate)} for user: $userId");

    try {
      final client = await _getAuthClient();
      final sheetsApi = SheetsApi(client);

      // Fetch all challan rows
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        "$challanSheetName!A:Z",
      );

      if (response.values == null || response.values!.length <= 1) {
        print("❌ No challans found in sheet.");
        return <Challan>[];
      }

      // Extract headers
      final headers = response.values![0].map((h) => h.toString().trim()).toList();
      print("✅ Headers: $headers");

      // DEBUG: Show first 5 rows
      print("=== DEBUG: FIRST 5 ROWS ===");
      for (int i = 1; i < min(6, response.values!.length); i++) {
        Map<String, dynamic> rowMap = {};
        for (int j = 0; j < headers.length; j++) {
          rowMap[headers[j]] = j < response.values![i].length ? response.values![i][j] : "";
        }
        print("Row $i: $rowMap");
      }

      List<Challan> filteredChallans = [];

      // Iterate rows (skip header row)
      for (int i = 1; i < response.values!.length; i++) {
        final row = response.values![i];
        if (row.isEmpty) continue; // Skip empty rows

        Map<String, dynamic> challanMap = {};
        for (int j = 0; j < headers.length; j++) {
          challanMap[headers[j]] = j < row.length ? row[j] : "";
        }

        try {
          Challan challan = Challan.fromMap(challanMap);

          // Parse challan date safely
          DateTime? parsedChallanDate;
          String rawDate = challanMap['challanDate']?.toString().trim() ?? "";

          if (rawDate.isNotEmpty) {
            parsedChallanDate = _parseChallanDate(rawDate);
          }

          // Filter by user ID and date range
          if (parsedChallanDate != null &&
              challan.userId == userId &&
              !parsedChallanDate.isBefore(fromDate) &&
              !parsedChallanDate.isAfter(toDate)) {
            // Load items for this challan
            challan.items = await getChallanItemsByChallanId(challan.challanId);
            challan.challanDate = parsedChallanDate;

            filteredChallans.add(challan);
            print("✅ Added challan: ${challan.challanId} - Date: $parsedChallanDate - Items: ${challan.items?.length ?? 0}");
          } else {
            if (parsedChallanDate == null) {
              print("⚠️ Skipping challan ${challan.challanId}: Invalid date format ($rawDate)");
            } else if (challan.userId != userId) {
              print("⚠️ Skipping challan ${challan.challanId}: User ID mismatch (${challan.userId} vs $userId)");
            } else {
              print("⚠️ Skipping challan ${challan.challanId}: Date $parsedChallanDate outside range");
            }
          }
        } catch (e) {
          print("⚠️ Error parsing challan row $i: $e");
          print("Row data: $challanMap");
        }
      }

      print("✅ Successfully found ${filteredChallans.length} challans in date range");

      // Sort challans by date (newest first)
      filteredChallans.sort((a, b) {
        if (a.challanDate == null) return 1;
        if (b.challanDate == null) return -1;
        return b.challanDate!.compareTo(a.challanDate!);
      });

      return filteredChallans;
    } catch (e) {
      print("❌ Error in getChallansByDateRange(): $e");
      rethrow;
    }
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


}

