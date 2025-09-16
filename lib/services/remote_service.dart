import 'dart:convert';

import 'package:demo_prac_getx/constant/app_constant.dart';
import 'package:demo_prac_getx/model/comment_model.dart';
import 'package:demo_prac_getx/services/api.dart';
import 'package:demo_prac_getx/utils/shared_preferences_helper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/model.dart';
import '../utils/pdf_helper.dart';

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

  // Save user's AppId when they first register or admin assigns
  static Future<void> saveUserAppId(String userEmail, String appId) async {
    final prefs = await sharedPreferencesHelper.getSharedPreferencesInstance();
    await prefs.setString('appid_$userEmail', appId);
  }

  // Get user's AppId
  static Future<String?> getUserAppId(String userEmail) async {
    final prefs = await sharedPreferencesHelper.getSharedPreferencesInstance();
    return prefs.getString('appid_$userEmail');
  }

  // Get current logged-in user's AppId
  static Future<String?> getCurrentUserAppId() async {
    final prefs = await sharedPreferencesHelper.getSharedPreferencesInstance();
    final currentUser = prefs.getString('current_user_email');

    if (currentUser == null) return null;

    return getUserAppId(currentUser);
  }

  static Future<http.Response> getComment() async {
    Map<String, String> header = {
      'Content-Type': 'application/json',
    };

    final uri = Uri.parse(Apis.commetApi);

    http.Response response = await http.get(headers: header, uri);
    return response;
  }

  /// Add item to Items table with enhanced fields
  static Future<void> addItem(String userId,Item item) async {
    final dynamicTableName = "${itemsTableName}_$userId";
    print("Dynamic Item Tabel name   :--------- ${dynamicTableName}");
    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action"
        ///"https://api.appsheet.com/api/v2/apps/$appId/tables/$dynamicTableName/Action"
    );

    print("Dynamic Item Tabel Api Url :--------- ${url}");

    // Ensure userId is included in the item data
    final itemData = {
      ...item.toMap(),
      "userId": userId, // Make sure this matches your column name exactly
    };

    final body = jsonEncode({
      "Action": "Add",
      "Rows": [
        itemData
       ],
    });

    print("Adding item with data-01: $itemData");
    print("Adding item with data: ${item.toMap()}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "ApplicationAccessKey": accessKey,
      },
      body: body,
    );

    print("Add Item Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      print("Item added successfully: ${response.body}");
    } else {
      throw Exception("Failed to add item: ${response.body}");
    }
  }

  // static Future<void> addInvoice(List<Invoice> invoices,String userId) async {
  //   checkInvoiceTableStructure();
  //   final url = Uri.parse(
  //       "https://api.appsheet.com/api/v2/apps/$appId/tables/$invoiceTableName/Action");
  //
  //   final invoiceData = invoices.map((inv) {
  //     return {
  //       ...inv.toMap(),
  //       "userId": userId, // Make sure this matches your column name exactly
  //     };
  //   }).toList();
  //
  //
  //   final body = jsonEncode({
  //     "Action": "Add",
  //     "Rows": invoiceData,
  //   });
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

  static Future<void> addInvoice(dynamic invoiceData, String userId) async {
    checkInvoiceTableStructure();
    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$invoiceTableName/Action");

    List<Map<String, dynamic>> rowsToSend = [];

    if (invoiceData is Map<String, dynamic>) {
      // Single invoice with items
      if (invoiceData.containsKey('items') && invoiceData['items'] is List) {
        invoiceData['items'] = jsonEncode(invoiceData['items']);
      }
      rowsToSend.add({
        ...invoiceData,
        "userId": userId,
      });
    } else if (invoiceData is List<Invoice>) {
      // Multiple invoice rows (legacy format)
      rowsToSend = invoiceData.map((inv) {
        return {
          ...inv.toMap(),
          "userId": userId,
        };
      }).toList();
    }

    final body = jsonEncode({
      "Action": "Add",
      "Rows": rowsToSend,
    });

    print("Sending to AppSheet: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "ApplicationAccessKey": accessKey,
      },
      body: body,
    );

    print("AppSheet Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData is Map && responseData.containsKey("RowsAffected")) {
        print("Invoice sent successfully. Rows affected: ${responseData["RowsAffected"]}");
      } else {
        print("Invoice sent successfully: ${response.body}");
      }
    } else {
      throw Exception("Failed to send invoice: ${response.body}");
    }
  }

  static Future<void> addInvoiceItem(Map<String, dynamic> itemData, String userId) async {
    try {
      print("Adding invoice item: ${jsonEncode(itemData)}");

      final url = Uri.parse(
          "https://api.appsheet.com/api/v2/apps/$appId/tables/$invoiceItemTableName/Action");

      final Map<String, dynamic> requestBody = {
        "Action": "Add",
        "Properties": {
          "Locale": "en-US",
        },
        "Rows": [
       {   ...itemData,
         //"userId": userId,
      }    ]
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey, // Use the same access key as addInvoice
        },
        body: jsonEncode(requestBody),
      );

      print("Add Invoice Item Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey("RowsAffected")) {
          print("Invoice item sent successfully. Rows affected: ${responseData["RowsAffected"]}");
        } else {
          print("Invoice item sent successfully: ${response.body}");
        }
      } else {
        throw Exception("Failed to add invoice item: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error adding invoice item: $e");
      rethrow;
    }
  }

  static Future<void> addChallanItem(Map<String, dynamic> challanData, String userId) async {

    try {
      print("Adding challan item: ${jsonEncode(challanData)}");

      final url = Uri.parse(
          "https://api.appsheet.com/api/v2/apps/$appId/tables/$challanItemTableName/Action");

      final Map<String, dynamic> requestBody = {
        "Action": "Add",
        "Properties": {
          "Locale": "en-US",
        },
        "Rows": [
          {
            ...challanData,
            //"userId": userId,
          }
        ]
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: jsonEncode(requestBody),
      );

      print("Add Challan Item Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        // ✅ ADD THIS CHECK FOR EMPTY RESPONSE
        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(response.body);
          if (responseData is Map && responseData.containsKey("RowsAffected")) {
            print("Challan item sent successfully. Rows affected: ${responseData["RowsAffected"]}");
          } else {
            print("Challan item sent successfully: ${response.body}");
          }
        } else {
          // ✅ HANDLE EMPTY RESPONSE AS SUCCESS
          print("Challan item sent successfully. Empty response received.");
        }
      } else {
        throw Exception("Failed to add challan item: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error adding challan item: $e");
      rethrow;
    }
  }

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

  // static Future<void> addChallan(List<Challan> challans, String userId) async {
  //   final url = Uri.parse(
  //       "https://api.appsheet.com/api/v2/apps/$appId/tables/$challanTableName/Action");
  //
  //   final challansData = challans.map((challan) {
  //     return {
  //       ...challan.toMap(),
  //       "userId": userId, // Make sure this matches your column name exactly
  //     };
  //   }).toList();
  //
  //   final body = jsonEncode({
  //     "Action": "Add",
  //     "Rows": challansData,
  //   });
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
  //       print("Challan sent successfully. Rows affected: ${responseData["RowsAffected"]}");
  //     } else {
  //       print("Challan sent successfully: ${response.body}");
  //     }
  //   } else {
  //     throw Exception("Failed to send challan: ${response.body}");
  //   }
  // }

  static Future<void> addChallan(dynamic challanData, String userId) async {
    checkChallanTableStructure();
    try {
      print("=== STARTING ADD CHALLAN ===");

      final url = Uri.parse(
          "https://api.appsheet.com/api/v2/apps/$appId/tables/$challanTableName/Action");

      // Print the actual URL being called
      print("API URL: $url");
      print("App ID: $appId");
      print("Table Name: $challanTableName");

      List<Map<String, dynamic>> rowsToSend = [];

      if (challanData is Map<String, dynamic>) {
        if (challanData.containsKey('items') && challanData['items'] is List) {
          challanData['items'] = jsonEncode(challanData['items']);
        }
        rowsToSend.add({
          ...challanData,
          "userId": userId,
        });
      } else if (challanData is List<Challan>) {
        print("Processing as Challan object");
        rowsToSend = challanData.map((chal){
          return {
            ...chal.toMap(),
            "userId": userId,
          };
        }).toList();
      }

      print("Rows to send: ${jsonEncode(rowsToSend)}");

      final body = jsonEncode({
        "Action": "Add",
        // "Properties": {
        //   "Locale": "en-US",
        // },
        "Rows": rowsToSend,
      });

      print("Sending to AppSheet: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: body,
      );

      print("=== RESPONSE ===");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("Response Headers: ${response.headers}");

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final responseData = jsonDecode(response.body);
            if (responseData is Map && responseData.containsKey("RowsAffected")) {
              print("Challan sent successfully. Rows affected: ${responseData["RowsAffected"]}");
            } else {
              print("Challan sent successfully: ${response.body}");
            }
          } catch (e) {
            print("⚠️ Could not decode response JSON: $e");
          }
        } else {
          print("✅ Challan added successfully (empty response body).");
        }
      }

    } catch (e) {
      print("❌ ERROR in addChallan: $e");
      rethrow;
    }
  }


  // Method to verify challan exists after saving

  static Future<bool> verifyChallanExists(String challanId) async {
    try {
      print("=== VERIFYING CHALLAN EXISTS: $challanId ===");

      final url = Uri.parse(
          "https://api.appsheet.com/api/v2/apps/$appId/tables/$challanTableName/Action");

      final body = jsonEncode({
        "Action": "Find",
        "Properties": {
          "Locale": "en-US",
        },
        "Rows": [
          {"challanId": challanId}
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

      print("Verification response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData is List && responseData.isNotEmpty) {
            print("✅ Challan verified - exists in database");
            return true;
          } else {
            print("❌ Challan not found in database");
            return false;
          }
        } catch (e) {
          print("Error parsing verification response: $e");
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Error in verifyChallanExists: $e");
      return false;
    }
  }
  static Future<void> findChallanById(String challanId) async {
    try {
      print("=== SEARCHING FOR CHALLAN $challanId ===");

      final url = Uri.parse(
          "https://api.appsheet.com/api/v2/apps/$appId/tables/$challanTableName/Action");

      final body = jsonEncode({
        "Action": "Find",
        "Properties": {
          "Locale": "en-US",
        },
        "Rows": [
          {"challanId": challanId}
        ]
      });

      print("Find request: $body");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: body,
      );

      print("Find response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          final responseData = jsonDecode(response.body);
          print("Found challan data: $responseData");
        } catch (e) {
          print("Error parsing find response: $e");
        }
      }
    } catch (e) {
      print("Error in findChallanById: $e");
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

  static Future<List<ChallanItem>> getChallanItemsByChallanId(String challanId) async {
    try {
      print("Fetching challan items for challan: $challanId");

      final Map<String, dynamic> requestBody = {
        "Action": "Find",
        "Properties": {
          "Locale": "en-US",
        },
        "Filters": [
          ["challanId", "equals", challanId] // FIX: Changed "invoiceId" to "challanId"
        ]
      };

      final response = await http.post(
        Uri.parse('https://api.appsheet.com/api/v2/apps/$appId/tables/$challanItemTableName/Action'),
        headers: {
          'Content-Type': 'application/json',
          'ApplicationAccessKey': accessKey,
        },
        body: jsonEncode(requestBody),
      );

      print("Challan Items Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        // FIX: AppSheet returns a Map, not a List directly
        List<dynamic> itemsData = [];

        if (responseData is Map<String, dynamic>) {
          // Check if response has 'data' field (common in AppSheet)
          if (responseData.containsKey('data')) {
            itemsData = responseData['data'] ?? [];
          } else {
            // If no 'data' field, try to use the response as list
            itemsData = responseData.values.toList();
          }
        } else if (responseData is List) {
          itemsData = responseData;
        }

        print("API returned ${itemsData.length} items total");

        // No need for additional filtering - the API filter should handle it
        return itemsData.map((item) {
          if (item is Map<String, dynamic>) {
            return ChallanItem.fromJson(item);
          } else {
            print("Invalid item format: $item");
            return ChallanItem.fromJson({}); // Return empty item
          }
        }).toList();
      } else {
        throw Exception('Failed to fetch challan items: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching Challan items: $e");
      rethrow;
    }
  }

  // Method to check table structure for debugging
  static Future<void> checkChallanTableStructure() async {

      print("=== CHECKING CHALLAN TABLE STRUCTURE ===");

      final url = Uri.parse(
          "https://api.appsheet.com/api/v2/apps/$appId/tables/$challanTableName/columns");

      final body = jsonEncode({
        "Action": "Find",
        "Properties": {
          "Locale": "en-US",
          "Selector": 'Filter(1=1)',
          "SelectColumns": ["challanId",
            "itemId",
            "customerId",
            "customerName",
            "customerMobile",
            "customerEmail",
            "customerAddress",
            "itemId",
            "itemName", "qty", "price", "subtotal", "taxRate",
          "taxAmount",
          "paymentStatus", "notes", "status", "userId"]
        }
      });
try{
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: body
      );
      print("Table Structure Response: ${response.statusCode} - ${response.body}");

    } catch (e) {
  print("Error checking table structure: $e");
  }

  }




  static Future<void> checkInvoiceTableStructure() async {
    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$invoiceTableName/Action");

    final body = jsonEncode({
      "Action": "Find",
      "Properties": {
        "Locale": "en-US",
        "Selector": 'Filter(1=1)',
        "SelectColumns": ["invoiceId", "itemId", "itemName", "qty", "price", "mobile", "customerName"]
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

      print("Table Structure Response: ${response.statusCode} - ${response.body}");
    } catch (e) {
      print("Error checking table structure: $e");
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

  static Future<List<Challan>> getChallans() async {
    print("🔄 Fetching challans from AppSheet API...");

    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$challanTableName/Action");

    final Map<String, dynamic> requestBody = {
      "Action": "Find",
      "Properties": {
        "Locale": "en-US",
      }
    };

    print("Challan request body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: jsonEncode(requestBody),
      );

      print("Challan response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Check for empty response
        if (response.body.trim().isEmpty || response.body.trim() == "[]") {
          print("Challan method returned empty data");
          return <Challan>[];
        }

        dynamic data;
        try {
          data = jsonDecode(response.body);
          print("Challan parsed data type: ${data.runtimeType}");
        } catch (jsonError) {
          print("Challan JSON decode error: $jsonError");
          print("Raw response: ${response.body}");
          return <Challan>[];
        }

        List<dynamic> challanData = [];

        // Handle different response structures
        if (data is List) {
          challanData = data;
          print("Direct list with ${challanData.length} challans");
        } else if (data is Map) {
          if (data.containsKey("Rows")) {
            challanData = data["Rows"] ?? [];
            print("Map with Rows: ${challanData.length} challans");
          } else if (data.containsKey("Records")) {
            challanData = data["Records"] ?? [];
            print("Map with Records: ${challanData.length} challans");
          } else if (data.containsKey("data")) {
            challanData = data["data"] ?? [];
            print("Map with data: ${challanData.length} challans");
          } else {
            print("Unknown map structure: ${data.keys}");
            // Try to extract any list-like values
            var listKeys = data.keys.where((key) => data[key] is List).toList();
            if (listKeys.isNotEmpty) {
              challanData = data[listKeys.first] ?? [];
              print("Using first list key '${listKeys.first}': ${challanData.length} items");
            } else {
              // If it's a single record, wrap it in a list
              challanData = [data];
              print("Wrapping single record in list");
            }
          }
        } else {
          print("Unexpected data type: ${data.runtimeType}");
          return <Challan>[];
        }

        // Handle empty data
        if (challanData.isEmpty) {
          print("No challan data found in response");
          return <Challan>[];
        }

        // Convert to Challan objects with enhanced error handling
        List<Challan> challans = [];
        for (int i = 0; i < challanData.length; i++) {
          try {
            var item = challanData[i];

            if (item is Map<String, dynamic>) {
              print("Processing challan $i: $item");
              Challan challan = Challan.fromJson(item);
              challans.add(challan);
            } else if (item is Map) {
              // Convert dynamic map to String key map
              var convertedMap = Map<String, dynamic>.from(item);
              print("Processing challan $i: $convertedMap");
              Challan challan = Challan.fromJson(convertedMap);
              challans.add(challan);
            } else {
              print("Skipping invalid challan data at index $i: ${item.runtimeType}");
              print("Problematic item: $item");
            }
          } catch (e) {
            print("Error parsing challan item $i: $e");
            print("Problematic item: ${challanData[i]}");
            // Continue with other items instead of failing completely
            continue;
          }
        }

        print("Successfully parsed ${challans.length} challans");
        return challans;

      } else {
        print("Challan HTTP error: ${response.statusCode}");
        print("Error response: ${response.body}");
        throw Exception('Failed to load challans: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in getChallans(): $e");
      rethrow;
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
// In RemoteService - add this method
  static Future<List<Challan>> getChallansWithItemsByCustomer(String customerName) async {
    try {
      // First get all challans for this customer
      List<Challan> customerChallans = await getChallansByDateRange(
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

        List<ChallanItem> items = await getChallanItemsByChallanId(customerChallans[i].challanId);

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

  // In RemoteService
  static Future<List<Challan>> getChallansWithItems() async {
    try {
      // First get all challans
      List<Challan> challans = await getChallansByDateRange(
        fromDate: DateTime.now().subtract(Duration(days: 30)),
        toDate: DateTime.now(),
        userId: AppConstants.userId,
      );

      print("Processing ${challans.length} challans to fetch items...");

      // For each challan, fetch its items from ChallanItems table
      for (int i = 0; i < challans.length; i++) {
        print("Fetching items for challan ${i + 1}/${challans.length}: ${challans[i].challanId}");

        List<ChallanItem> items = await getChallanItemsByChallanId(challans[i].challanId);

        // Update the challan with items
        challans[i] = challans[i].copyWith(items: items);

        print("Added ${items.length} items to challan ${challans[i].challanId}");
      }

      return challans;
    } catch (e) {
      print('Error fetching challans with items: $e');
      return [];
    }
  }

  // In your ApiService class
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

  // Add this at the beginning of your RemoteService class
  static void printAppSheetConfig() {
    print("=== APPSHEET CONFIGURATION ===");
    print("App ID: $appId");
    print("Invoice Table: $invoiceTableName");
    print("Challan Table: $challanTableName");
    print("Access Key: ${accessKey.substring(0, 10)}..."); // Show first 10 chars only
  }

/// Alternative method for fetching challans
//   static Future<List<Challan>> getChallansAlternative() async {
//     print("=== TRYING ALTERNATIVE METHOD: Read ===");
//
//     final url = Uri.parse(
//         "https://api.appsheet.com/api/v2/apps/$appId/tables/$challanTableName/Data");
//
//     final response = await http.get(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "ApplicationAccessKey": accessKey,
//       },
//     );
//
//     print("Read Response: ${response.statusCode} - ${response.body}");
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//
//       if (data is List) {
//         if (data.isEmpty) {
//           print("✅ No challans found in alternative method");
//           return [];
//         }
//         return data.map((e) => Challan.fromMap(e)).toList();
//       } else if (data is Map && data.containsKey("")) {
//         // Handle different response format
//         List<dynamic> rows = data[""];
//         if (rows.isEmpty) {
//           print("✅ No challans found in alternative method");
//           return [];
//         }
//         return rows.map((e) => Challan.fromMap(e)).toList();
//       } else {
//         print("⚠️ Unexpected response format in alternative method: $data");
//         return [];
//       }
//     } else {
//       throw Exception("Failed to load challans (alternative): ${response.body}");
//     }
//   }

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

  // Add this test method to your RemoteService class
  static Future<void> testConnection() async {
    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action");

    // Test with minimal request first
    final body = jsonEncode({
      "Action": "Find",
      "Properties": {
        "Locale": "en-US"
        // No Selector or SelectColumns - get everything
      }
    });

    print("Testing connection with: $body");
    print("App ID: $appId");
    print("Table Name: $itemsTableName");
    print("Access Key: ${accessKey.substring(0, 10)}..."); // Show first 10 chars only

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "ApplicationAccessKey": accessKey,
      },
      body: body,
    );

    print("Test Response: ${response.statusCode}");
    print("Test Response Body: '${response.body}'");

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body);
      print("Test Data Structure: ${data.runtimeType}");
      if (data is List) {
        print("Found ${data.length} items");
        if (data.isNotEmpty) {
          print("First item keys: ${data[0].keys.toList()}");
        }
      } else if (data is Map) {
        print("Response keys: ${data.keys.toList()}");
      }
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

  // The issue is AppSheet sync - let's force a sync and try different approaches

// Method 1: Force AppSheet to sync before filtering
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


// Alternative 3: Delete and Add (as last resort)
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
  } ///new


  static Future<List<Invoice>> getInvoices() async {
    print("🔄 Trying alternative invoice fetch method...");

    final url = Uri.parse(
        "https://api.appsheet.com/api/v2/apps/$appId/tables/$invoiceTableName/Action");

    // Try a simpler request without sorting
    final simpleBody = jsonEncode({
      "Action": "Find",
      "Properties": {
        "Locale": "en-US",
      }
    });

    print("Alternative request body: $simpleBody");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ApplicationAccessKey": accessKey,
        },
        body: simpleBody,
      );

      print("Alternative response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty || response.body.trim() == "[]") {
          print("Alternative method also returned empty");
          return <Invoice>[];
        }

        dynamic data;
        try {
          data = jsonDecode(response.body);
          print("Alternative parsed data type: ${data.runtimeType}");
        } catch (jsonError) {
          print("Alternative JSON decode error: $jsonError");
          return <Invoice>[];
        }

        List<dynamic> invoiceData = [];

        if (data is List) {
          invoiceData = data;
          print("Alternative direct list with ${invoiceData.length} invoices");
        } else if (data is Map) {
          if (data.containsKey("Rows")) {
            invoiceData = data["Rows"];
            print("Alternative map with Rows: ${invoiceData.length} invoices");
          } else if (data.containsKey("Records")) {
            invoiceData = data["Records"];
            print("Alternative map with Records: ${invoiceData.length} invoices");
          } else {
            print("Alternative unknown map structure: ${data.keys}");
            invoiceData = [data];
          }
        }

        return invoiceData.map((e) => Invoice.fromMap(e as Map<String, dynamic>)).toList();

      } else {
        print("Alternative HTTP error: ${response.statusCode}");
        return <Invoice>[];
      }
    } catch (e) {
      print("Error in getInvoicesAlternative: $e");
      return <Invoice>[];
    }
  }

// Method 2: Get all data and filter manually (fallback)
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

// Method 3: Try different AppSheet API approach
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


// Quick test method - try this first
  Future<void> testSimpleFilter() async {
    try {
      print("=== TESTING SIMPLE APPROACH ===");

      // Get all items first
      final allItems = await RemoteService.getItems();
      print("Total items without filter: ${allItems.length}");

      // Now try with filter
      final filteredItems = await RemoteService.getItems(userId: "Cueiq22u4QYqyzvjwHFbNVIxQXq2");
      print("Filtered items: ${filteredItems.length}");

      // Manual verification
      final manualFilter = allItems.where((item) => item.userId == "Cueiq22u4QYqyzvjwHFbNVIxQXq2").toList();
      print("Manual filter result: ${manualFilter.length}");

    } catch (e) {
      print("Test error: $e");
    }
  }

  String? getCurrentUserId() {
    // DEBUG: Print what you're returning
    String? userId = "your_actual_user_id"; // Replace with your actual method

    print("getCurrentUserId() returning: '$userId'");
    return userId;
  }


// Step 5: Test different column names
  static Future<void> testDifferentColumnNames(String userId) async {
    final columnVariations = [
      "userId",
      "UserId",
      "user_id",
      "UserID",
      "User ID",
      "user",
      "User"
    ];

    for (String columnName in columnVariations) {
      try {
        print("Testing column name: '$columnName'");

        final selector = "Filter([$columnName] = '$userId')";
        print("Selector: $selector");

        final body = jsonEncode({
          "Action": "Find",
          "Properties": {
            "Locale": "en-US",
            "Selector": selector,
          }
        });

        final response = await http.post(
          Uri.parse("https://api.appsheet.com/api/v2/apps/$appId/tables/$itemsTableName/Action"),
          headers: {
            "Content-Type": "application/json",
            "ApplicationAccessKey": accessKey,
          },
          body: body,
        );

        if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
          final data = jsonDecode(response.body);
          final count = data is List ? data.length : (data["Rows"]?.length ?? 0);

          if (count > 0) {
            print("SUCCESS with column '$columnName': Found $count items");
            return; // Stop testing when we find the right column
          }
        }

      } catch (e) {
        print("Error testing column '$columnName': $e");
      }
    }

    print("No working column name found for userId");
  }
  ///

  ////


  // Optional: Add method to get user-specific items
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

// Debug method to get all items (for testing)
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
