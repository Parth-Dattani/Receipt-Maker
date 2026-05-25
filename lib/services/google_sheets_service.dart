import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets_api;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../constant/constant.dart';
import '../model/receipt_model.dart';
import '../utils/shared_preferences_helper.dart';

class GoogleSheetsService {
  static const _scopes = [
    'email',
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/drive.file',
    'https://www.googleapis.com/auth/spreadsheets',
  ];

  static String _activeWorksheetTitle = 'Receipts';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? AppConstants.googleWebClientId : null,
    scopes: _scopes,
  );

  static GoogleSignInAccount? _googleAccount;
  static drive.DriveApi? _driveApi;
  static sheets_api.SheetsApi? _sheetsApi;
  static String? _spreadsheetId;
  static String? _mainFolderId;

  static bool get isSignedIn => _googleAccount != null && _driveApi != null && _sheetsApi != null;
  static String? get googleUserEmail => _googleAccount?.email;

  static Future<bool> hasFullAccess() async {
    if (_googleAccount == null) return false;
    try {
      return await _googleSignIn.canAccessScopes(_scopes);
    } catch (_) {
      return false;
    }
  }

  static void syncIdsFromConstants() {
    if (AppConstants.spreadsheetId.isNotEmpty) {
      _spreadsheetId = AppConstants.spreadsheetId;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 1. SIGN-IN
  // ════════════════════════════════════════════════════════════════════════════
  static Future<bool> signInSilentlyWithEmail(String userEmail) async {
    try {
      _googleAccount = await _googleSignIn.signInSilently();
      if (_googleAccount != null) {
        await _buildClients(_googleAccount!);
        return isSignedIn;
      }
      return false;
    } catch (e) {
      debugPrint('[GSheetsService] Silent Sign-in Error: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 2. SETUP (Verify & Recreate)
  // ════════════════════════════════════════════════════════════════════════════
  static Future<Map<String, String>?> setupUserDriveAndSheet(String userId, String financialYear) async {
    bool hasPermissions = await hasFullAccess();
    
    if (!isSignedIn || !hasPermissions) {
      debugPrint('[GSheetsService] ⚠️ Re-authenticating for full access...');
      _googleAccount = await _googleSignIn.signIn();
      if (_googleAccount == null) return null;
      await _buildClients(_googleAccount!);
      
      // Re-verify after sign in
      if (!await hasFullAccess()) return null;
    }

    if (!isSignedIn) return null;

    try {
      String? savedFolderId = await sharedPreferencesHelper.getPrefData("driveFolderId");
      String? savedSheetId = AppConstants.spreadsheetId.isNotEmpty ? AppConstants.spreadsheetId : null;

      _mainFolderId = await _getOrCreateFolder('Receipts', hintId: savedFolderId);
      if (_mainFolderId == null) return null;
      
      final sheetName = '${userId}_$financialYear';
      _spreadsheetId = await _getOrCreateSpreadsheet(sheetName, _mainFolderId!, hintId: savedSheetId);
      if (_spreadsheetId == null) return null;

      _activeWorksheetTitle = 'Receipts_$financialYear';
      await _ensureWorksheetAndHeaders();

      return {
        'spreadsheetId': _spreadsheetId ?? '',
        'folderId': _mainFolderId ?? '',
        'financialYear': financialYear,
      };
    } catch (e) {
      debugPrint('[GSheetsService] Setup Error: $e');
      return null;
    }
  }

  static String _range(String sheetName, String range) => "'$sheetName'!$range";

  // ════════════════════════════════════════════════════════════════════════════
  // 3. DATA OPERATIONS
  // ════════════════════════════════════════════════════════════════════════════
  static Future<bool> insertReceipt(ReceiptModel receipt) async {
    if (!isSignedIn || _spreadsheetId == null || _sheetsApi == null) return false;
    try {
      final String currentSheet = _activeWorksheetTitle;
      
      // Check if headers exist
      final headerRes = await _sheetsApi?.spreadsheets.values.get(_spreadsheetId!, _range(currentSheet, 'A1:Z1'));
      
      if (headerRes?.values == null || headerRes!.values!.isEmpty) {
        await _ensureWorksheetAndHeaders();
        return insertReceipt(receipt); 
      }

      final headerRow = headerRes.values!.first;
      final headerMap = {for (int i = 0; i < headerRow.length; i++) headerRow[i].toString().trim(): i};

      final allRes = await _sheetsApi?.spreadsheets.values.get(_spreadsheetId!, _range(currentSheet, 'A3:A'));
      int lastDataRow = 2 + (allRes?.values?.where((r) => r.isNotEmpty).length ?? 0);

      List<dynamic> row = List.filled(headerRow.length, '');
      _mapReceiptToRow(receipt, row, headerMap);

      await _sheetsApi?.spreadsheets.values.update(
        sheets_api.ValueRange(values: [row]),
        _spreadsheetId!,
        _range(currentSheet, 'A${lastDataRow + 1}'),
        valueInputOption: 'RAW',
      );
      return true;
    } catch (e) {
      debugPrint('[GSheetsService] Insert Error: $e');
      return false;
    }
  }

  static Future<bool> updateReceipt(ReceiptModel receipt) async {
    if (!isSignedIn || _spreadsheetId == null || _sheetsApi == null) return false;
    try {
      final res = await _sheetsApi?.spreadsheets.values.get(_spreadsheetId!, '$_activeWorksheetTitle!A1:Z');
      if (res?.values == null || res!.values!.isEmpty) return false;
      
      final headerRow = res.values!.first;
      final headerMap = {for (int i = 0; i < headerRow.length; i++) headerRow[i].toString().trim(): i};
      int? recNoIdx = headerMap['RecNo'];
      if (recNoIdx == null) return false;

      int targetRowIndex = -1;
      for (int i = 2; i < res.values!.length; i++) {
        var row = res.values![i];
        if (row.length > recNoIdx && row[recNoIdx].toString() == receipt.recNo.toString()) {
          targetRowIndex = i + 1;
          break;
        }
      }
      if (targetRowIndex == -1) return false;

      var currentRow = res.values![targetRowIndex - 1];
      List<dynamic> updatedRow = List.filled(headerRow.length, '');
      for (int i = 0; i < currentRow.length && i < updatedRow.length; i++) {
        updatedRow[i] = currentRow[i];
      }
      _mapReceiptToRow(receipt, updatedRow, headerMap);
      
      await _sheetsApi?.spreadsheets.values.update(
          sheets_api.ValueRange(values: [updatedRow]), _spreadsheetId!, '$_activeWorksheetTitle!A$targetRowIndex',
          valueInputOption: 'RAW');
      return true;
    } catch (e) {
      debugPrint('[GSheetsService] Update Error: $e');
      return false;
    }
  }

  static Future<List<ReceiptModel>> fetchAllReceipts() async {
    if (!isSignedIn || _spreadsheetId == null || _sheetsApi == null) return [];
    try {
      final res = await _sheetsApi?.spreadsheets.values.get(_spreadsheetId!, _range(_activeWorksheetTitle, 'A1:Z2000'));
      if (res?.values == null || res!.values!.length < 2) return [];
      
      final headerRow = res.values!.first;
      final headerMap = {for (int i = 0; i < headerRow.length; i++) headerRow[i].toString().trim(): i};
      
      return res.values!.skip(1).where((r) {
        if (r.isEmpty) return false;
        return int.tryParse(_getVal(r, headerMap, 'RecNo')) != null;
      }).map((r) {
        return ReceiptModel.fromDynamicMap({
          'RecNo': int.tryParse(_getVal(r, headerMap, 'RecNo')) ?? 0,
          'Date': _getVal(r, headerMap, 'Date'),
          'Donor Name': _getVal(r, headerMap, 'Donor Name'),
          'PAN No': _getVal(r, headerMap, 'PAN No'),
          'Mobile No': _getVal(r, headerMap, 'Mobile No'),
          'Amount': double.tryParse(_getVal(r, headerMap, 'Amount')) ?? 0.0,
          'Amount In Words': _getVal(r, headerMap, 'Amount In Words'),
          'Payment Type': _getVal(r, headerMap, 'Payment Type'),
          'Bank Name': _getVal(r, headerMap, 'Bank Name'),
          'Cheque No': _getVal(r, headerMap, 'Cheque No'),
          'Remarks': _getVal(r, headerMap, 'Remarks'),
          'Donation Type': _getVal(r, headerMap, 'Donation Type', fallback: 'General'),
          'Created At': DateTime.tryParse(_getVal(r, headerMap, 'Created At')) ?? DateTime.now(),
          'UpdatedAt': DateTime.tryParse(_getVal(r, headerMap, 'UpdatedAt')) ?? DateTime.now(),
        });
      }).toList();
    } catch (e) {
      debugPrint('[GSheetsService] Fetch Error: $e');
      return [];
    }
  }

  static void _mapReceiptToRow(ReceiptModel receipt, List<dynamic> row, Map<String, int> map) {
    void s(String k, dynamic v) { if (map.containsKey(k)) row[map[k]!] = v; }
    s('RecNo', receipt.recNo);
    s('Date', receipt.date);
    s('Donor Name', receipt.donorName);
    s('PAN No', receipt.panNo);
    s('Mobile No', receipt.mobileNo);
    s('Amount', receipt.amount);
    s('Amount In Words', receipt.amountInWords);
    s('Payment Type', receipt.paymentType);
    s('Bank Name', receipt.bankName);
    s('Cheque No', receipt.chequeNo);
    s('Remarks', receipt.remarks);
    s('Donation Type', receipt.donationType);
    s('Created At', receipt.createdAt.toIso8601String());
    s('UpdatedAt', receipt.updatedAt.toIso8601String());
  }

  static String _getVal(List<dynamic> row, Map<String, int> map, String key, {String fallback = ''}) {
    if (!map.containsKey(key)) return fallback;
    final idx = map[key]!;
    if (row.length <= idx) return fallback;
    return row[idx]?.toString() ?? fallback;
  }

  static Future<bool> deleteReceipt(int recNo) async {
    if (!isSignedIn || _spreadsheetId == null || _sheetsApi == null) return false;
    try {
      final res = await _sheetsApi?.spreadsheets.values.get(_spreadsheetId!, '$_activeWorksheetTitle!A1:Z');
      if (res?.values == null || res!.values!.isEmpty) return false;
      
      final headerRow = res.values!.first;
      final headerMap = {for (int i = 0; i < headerRow.length; i++) headerRow[i].toString().trim(): i};
      int? recNoIdx = headerMap['RecNo'];
      if (recNoIdx == null) return false;

      int targetRowIndex = -1;
      for (int i = 2; i < res.values!.length; i++) {
        var row = res.values![i];
        if (row.length > recNoIdx && row[recNoIdx].toString() == recNo.toString()) {
          targetRowIndex = i + 1;
          break;
        }
      }
      if (targetRowIndex == -1) return false;
      
      await _sheetsApi?.spreadsheets.values.update(
        sheets_api.ValueRange(values: [['DELETED_$recNo']]),
        _spreadsheetId!, '$_activeWorksheetTitle!A$targetRowIndex',
        valueInputOption: 'RAW',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  static void setActiveSheet(String title) {
    _activeWorksheetTitle = title;
  }

  static Future<void> createNewFinancialYearTab(String fy) async {
    if (_sheetsApi == null || _spreadsheetId == null) return;
    final String oldActive = _activeWorksheetTitle;
    _activeWorksheetTitle = "Receipts_$fy";
    try {
      await _ensureWorksheetAndHeaders();
    } catch (e) {
      _activeWorksheetTitle = oldActive;
    }
  }

  static Future<String?> uploadPdfToDrive(Uint8List bytes, String fileName) async {
    if (!isSignedIn || _mainFolderId == null || _driveApi == null) return null;
    try {
      final pdfFolderId = await _getOrCreateSubFolder('PDF', _mainFolderId!);
      final driveFile = drive.File()..name = fileName..parents = [pdfFolderId];
      final media = drive.Media(Stream.value(bytes), bytes.length);
      final uploadedFile = await _driveApi?.files.create(driveFile, uploadMedia: media);
      
      if (uploadedFile != null && uploadedFile.id != null) {
        await _driveApi?.permissions.create(drive.Permission()..type = 'anyone'..role = 'reader', uploadedFile.id!);
        final fullFile = await _driveApi?.files.get(uploadedFile.id!, $fields: 'webViewLink');
        return (fullFile as drive.File?)?.webViewLink;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String> _getOrCreateSubFolder(String name, String parentId) async {
    final q = "mimeType='application/vnd.google-apps.folder' and name='$name' and '$parentId' in parents and trashed=false";
    final res = await _driveApi?.files.list(q: q, $fields: 'files(id, name)');
    if (res?.files != null && res!.files!.isNotEmpty) return res.files!.first.id!;
    
    final f = drive.File()..name = name..mimeType = 'application/vnd.google-apps.folder'..parents = [parentId];
    final c = await _driveApi?.files.create(f, $fields: 'id');
    return c?.id ?? '';
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 4. VERIFICATION HELPERS
  // ════════════════════════════════════════════════════════════════════════════
  static Future<String?> _getOrCreateFolder(String name, {String? hintId}) async {
    if (_driveApi == null) return null;
    if (hintId != null && hintId.isNotEmpty) {
      try {
        final f = await _driveApi?.files.get(hintId, $fields: 'id, trashed');
        if (f != null && !(f as drive.File).trashed!) return hintId;
      } catch (_) {}
    }
    final q = "mimeType='application/vnd.google-apps.folder' and name='$name' and trashed=false";
    final res = await _driveApi?.files.list(q: q, $fields: 'files(id, name)');
    if (res?.files != null && res!.files!.isNotEmpty) return res.files!.first.id;
    
    final f = drive.File()..name = name..mimeType = 'application/vnd.google-apps.folder';
    final c = await _driveApi?.files.create(f, $fields: 'id');
    return c?.id;
  }

  static Future<String?> _getOrCreateSpreadsheet(String name, String folderId, {String? hintId}) async {
    if (_sheetsApi == null || _driveApi == null) return null;
    if (hintId != null && hintId.isNotEmpty) {
      try {
        final s = await _sheetsApi?.spreadsheets.get(hintId);
        if (s != null) return s.spreadsheetId;
      } catch (_) {}
    }
    final q = "mimeType='application/vnd.google-apps.spreadsheet' and name='$name' and '$folderId' in parents and trashed=false";
    final res = await _driveApi?.files.list(q: q, $fields: 'files(id, name)');
    if (res?.files != null && res!.files!.isNotEmpty) return res.files!.first.id;
    
    final f = drive.File()..name = name..mimeType = 'application/vnd.google-apps.spreadsheet'..parents = [folderId];
    final c = await _driveApi!.files.create(f, $fields: 'id');
    return c?.id;
  }

  static Future<void> _ensureWorksheetAndHeaders() async {
    if (_sheetsApi == null || _spreadsheetId == null) return;
    try {
      final spreadsheet = await _sheetsApi?.spreadsheets.get(_spreadsheetId!);
      int? targetSheetId;
      bool exists = false;
      for (var s in spreadsheet?.sheets ?? []) {
        if (s.properties?.title == _activeWorksheetTitle) { exists = true; targetSheetId = s.properties?.sheetId; break; }
      }
      if (!exists) {
        final addRes = await _sheetsApi?.spreadsheets.batchUpdate(sheets_api.BatchUpdateSpreadsheetRequest(requests: [
            sheets_api.Request(addSheet: sheets_api.AddSheetRequest(properties: sheets_api.SheetProperties(title: _activeWorksheetTitle)))
        ]), _spreadsheetId!);
        targetSheetId = addRes?.replies?.first.addSheet?.properties?.sheetId;
      }
      
      // Headers update
      await _sheetsApi?.spreadsheets.values.update(
        sheets_api.ValueRange(values: [['RecNo', 'Date', 'Donor Name', 'PAN No', 'Mobile No', 'Amount', 'Amount In Words', 'Payment Type', 'Bank Name', 'Cheque No', 'Remarks', 'Donation Type', 'Created At', 'UpdatedAt']]),
        _spreadsheetId!, '$_activeWorksheetTitle!A1:N1', valueInputOption: 'RAW',
      );

      // HIDDEN_ROW row 2
      await _sheetsApi?.spreadsheets.values.update(
        sheets_api.ValueRange(values: [List.filled(14, 'HIDDEN_ROW')]),
        _spreadsheetId!, '$_activeWorksheetTitle!A2:N2', valueInputOption: 'RAW',
      );
    } catch (e) {
      debugPrint('[GSheetsService] Ensure Worksheet Error: $e');
    }
  }

  static Future<void> _buildClients(GoogleSignInAccount account) async {
    try {
      final headers = await account.authHeaders;
      if (headers['Authorization'] != null) {
        final client = _AuthClient(headers);
        _driveApi = drive.DriveApi(client);
        _sheetsApi = sheets_api.SheetsApi(client);
      }
    } catch (e) {
      debugPrint('[GSheetsService] Client Build Error: $e');
    }
  }

  static Future<void> signOut() async {
    try { await _googleSignIn.signOut(); } catch (_) {}
    reset();
  }

  static void reset() {
    _driveApi = null; _sheetsApi = null; _spreadsheetId = null;
    _googleAccount = null; _mainFolderId = null;
  }
}

class _AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _inner = http.Client();
  _AuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest req) { req.headers.addAll(_headers); return _inner.send(req); }
  @override
  void close() { _inner.close(); super.close(); }
}
