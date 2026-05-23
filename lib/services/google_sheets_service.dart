import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets_api;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../model/receipt_model.dart';

class GoogleSheetsService {
  static const _scopes = [
    drive.DriveApi.driveFileScope,
    'https://www.googleapis.com/auth/spreadsheets',
  ];

  static String _activeWorksheetTitle = 'Receipts'; // Default

  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  static GoogleSignInAccount? _googleAccount;

  static drive.DriveApi? _driveApi;
  static sheets_api.SheetsApi? _sheetsApi;
  static String? _spreadsheetId;
  static String? _mainFolderId;

  static String? _currentUserId;
  static String? _currentFY;

  static bool get isSignedIn => _googleAccount != null && _driveApi != null;
  static String? get googleUserEmail => _googleAccount?.email;

  // આ પ્રોપર્ટી ઉમેરો જેથી SettingsController એને એક્સેસ કરી શકે
  static Future<sheets_api.Spreadsheet> get spreadsheet async {
    return await _sheetsApi!.spreadsheets.get(_spreadsheetId!);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 1. SIGN-IN
  // ════════════════════════════════════════════════════════════════════════════
  static Future<bool> signInSilentlyWithEmail(String userEmail) async {
    try {
      _googleAccount = await _googleSignIn.signInSilently();
      if (_googleAccount != null && _emailMatches(_googleAccount!.email, userEmail)) {
        await _buildClients(_googleAccount!);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool _emailMatches(String a, String b) => a.trim().toLowerCase() == b.trim().toLowerCase();

  // ════════════════════════════════════════════════════════════════════════════
  // 2. SETUP
  // ════════════════════════════════════════════════════════════════════════════
  static Future<Map<String, String>?> setupUserDriveAndSheet(String userId, String financialYear) async {
    if (!isSignedIn) {
      _googleAccount = await _googleSignIn.signIn();
      if (_googleAccount != null) await _buildClients(_googleAccount!);
    }

    try {
      final folderId = await _getOrCreateFolder('Receipts');
      _mainFolderId = folderId;
      final sheetName = '${userId}_$financialYear';
      _spreadsheetId = await _getOrCreateSpreadsheet(sheetName, folderId);

      // શીટ સેટઅપ વખતે ડિફોલ્ટ એક્ટિવ શીટ સેટ કરો
      _activeWorksheetTitle = 'Receipts_$financialYear';
      await _ensureWorksheetAndHeaders();

      _currentUserId = userId;
      _currentFY = financialYear;
      return {'spreadsheetId': _spreadsheetId!};
    } catch (e) {
      return null;
    }
  }

  static String _range(String sheetName, String range) => "'$sheetName'!$range";

  // ════════════════════════════════════════════════════════════════════════════
  // 3. DATA OPERATIONS
  // ════════════════════════════════════════════════════════════════════════════
  static Future<bool> insertReceipt(ReceiptModel receipt) async {
    if (!isSignedIn || _spreadsheetId == null) return false;
    try {
      final headerRes = await _sheetsApi!.spreadsheets.values.get(_spreadsheetId!, _range(_activeWorksheetTitle, 'A1:Z1'));
      final headerRow = headerRes.values!.first;
      final headerMap = {for (int i = 0; i < headerRow.length; i++) headerRow[i].toString().trim(): i};

      final allRes = await _sheetsApi!.spreadsheets.values.get(_spreadsheetId!, _range(_activeWorksheetTitle, 'A3:A'));
      int lastDataRow = 2 + (allRes.values?.where((r) => r.isNotEmpty).length ?? 0);

      List<dynamic> row = List.filled(headerRow.length, '');
      _mapReceiptToRow(receipt, row, headerMap);

      await _sheetsApi!.spreadsheets.values.update(
        sheets_api.ValueRange(values: [row]),
        _spreadsheetId!,
        _range(_activeWorksheetTitle, 'A${lastDataRow + 1}'),
        valueInputOption: 'RAW',
      );
      return true;
    } catch (e) {
      print('[GSheetsService] Error: $e');
      return false;
    }
  }

  static Future<bool> updateReceipt(ReceiptModel receipt) async {
    if (!isSignedIn || _spreadsheetId == null || _sheetsApi == null) return false;

    try {
      final res = await _sheetsApi!.spreadsheets.values
          .get(_spreadsheetId!, '$_activeWorksheetTitle!A1:Z');

      if (res.values == null || res.values!.isEmpty) return false;

      final headerRow = res.values!.first;
      final headerMap = {
        for (int i = 0; i < headerRow.length; i++)
          headerRow[i].toString().trim(): i
      };

      int? recNoIdx = headerMap['RecNo'];
      if (recNoIdx == null) return false;

      int targetRowIndex = -1;
      for (int i = 2; i < res.values!.length; i++) {
        var row = res.values![i];
        if (row.length > recNoIdx &&
            row[recNoIdx].toString() == receipt.recNo.toString()) {
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

      final vr = sheets_api.ValueRange(values: [updatedRow]);
      await _sheetsApi!.spreadsheets.values.update(
          vr, _spreadsheetId!, '$_activeWorksheetTitle!A$targetRowIndex',
          valueInputOption: 'RAW');
      print('[GSheetsService] ✅ Updated #${receipt.recNo} → Row $targetRowIndex');
      return true;
    } catch (e) {
      print('[GSheetsService] ❌ updateReceipt error: $e');
      return false;
    }
  }

  static Future<List<ReceiptModel>> fetchAllReceipts() async {
    if (!isSignedIn || _spreadsheetId == null || _sheetsApi == null) return [];

    try {
      final res = await _sheetsApi!.spreadsheets.values.get(_spreadsheetId!, _range(_activeWorksheetTitle, 'A1:Z1000'));

      if (res.values == null || res.values!.length < 2) return [];

      final headerRow = res.values!.first;
      final headerMap = {
        for (int i = 0; i < headerRow.length; i++)
          headerRow[i].toString().trim(): i
      };

      return res.values!.skip(1).where((r) => r.isNotEmpty && _getVal(r, headerMap, 'RecNo') != 'HIDDEN_ROW').map((r) {
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
      print('[GSheetsService] ❌ fetchAllReceipts error: $e');
      return [];
    }
  }

  static void _mapReceiptToRow(
      ReceiptModel receipt, List<dynamic> row, Map<String, int> map) {
    void s(String k, dynamic v) {
      if (map.containsKey(k)) row[map[k]!] = v;
    }
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

  static String _getVal(List<dynamic> row, Map<String, int> map, String key,
      {String fallback = ''}) {
    if (!map.containsKey(key)) return fallback;
    final idx = map[key]!;
    if (row.length <= idx) return fallback;
    return row[idx]?.toString() ?? fallback;
  }

  static Future<bool> deleteReceipt(int recNo) async {
    if (!isSignedIn || _spreadsheetId == null || _sheetsApi == null) return false;

    try {
      final res = await _sheetsApi!.spreadsheets.values.get(_spreadsheetId!, '$_activeWorksheetTitle!A1:Z');
      if (res.values == null || res.values!.isEmpty) return false;

      final headerRow = res.values!.first;
      final headerMap = {for (int i = 0; i < headerRow.length; i++) headerRow[i].toString().trim(): i};
      int? recNoIdx = headerMap['RecNo'];
      if (recNoIdx == null) return false;

      int targetRowIndex = -1;
      for (int i = 0; i < res.values!.length; i++) {
        var row = res.values![i];
        if (row.length > recNoIdx && row[recNoIdx].toString() == recNo.toString()) {
          targetRowIndex = i + 1;
          break;
        }
      }

      if (targetRowIndex == -1) return false;

      final sheetRes = await _sheetsApi!.spreadsheets.get(_spreadsheetId!);
      int? sheetId;
      for (var s in sheetRes.sheets ?? []) {
        if (s.properties?.title == _activeWorksheetTitle) {
          sheetId = s.properties?.sheetId;
          break;
        }
      }
      if (sheetId == null) return false;

      await _sheetsApi!.spreadsheets.batchUpdate(
        sheets_api.BatchUpdateSpreadsheetRequest(requests: [
          sheets_api.Request(
            deleteDimension: sheets_api.DeleteDimensionRequest(
              range: sheets_api.DimensionRange(
                sheetId: sheetId,
                dimension: 'ROWS',
                startIndex: targetRowIndex - 1,
                endIndex: targetRowIndex,
              ),
            ),
          ),
        ]),
        _spreadsheetId!,
      );

      print('[GSheetsService] ✅ Deleted Receipt #$recNo at Row $targetRowIndex');
      return true;
    } catch (e) {
      print('[GSheetsService] ❌ deleteReceipt error: $e');
      return false;
    }
  }

  static void setActiveSheet(String title) {
    _activeWorksheetTitle = title;
    print('[GSheetsService] ✅ Active sheet switched to: $title');
  }

  static Future<String?> uploadPdfToDrive(File file) async {
    if (!isSignedIn || _mainFolderId == null) return null;
    try {
      final pdfFolderId = await _getOrCreateSubFolder('PDF', _mainFolderId!);
      
      final driveFile = drive.File()
        ..name = file.path.split('/').last
        ..parents = [pdfFolderId];

      final media = drive.Media(file.openRead(), file.lengthSync());
      final uploadedFile = await _driveApi!.files.create(driveFile, uploadMedia: media);
      
      // Make file viewable by anyone with link (optional but common for sharing)
      await _driveApi!.permissions.create(
        drive.Permission()..type = 'anyone'..role = 'reader',
        uploadedFile.id!,
      );

      final fullFile = await _driveApi!.files.get(uploadedFile.id!, $fields: 'webViewLink');
      return (fullFile as drive.File).webViewLink;
    } catch (e) {
      print('[GSheetsService] ❌ uploadPdfToDrive error: $e');
      return null;
    }
  }

  static Future<String> _getOrCreateSubFolder(String name, String parentId) async {
    final q = "mimeType='application/vnd.google-apps.folder' and name='$name' and '$parentId' in parents and trashed=false";
    final res = await _driveApi!.files.list(q: q, $fields: 'files(id, name)');
    if (res.files != null && res.files!.isNotEmpty) return res.files!.first.id!;

    final f = drive.File()..name = name..mimeType = 'application/vnd.google-apps.folder'..parents = [parentId];
    final c = await _driveApi!.files.create(f, $fields: 'id');
    return c.id!;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 4. SHEET SETUP & STYLING (ALL BLUE FIXED LOOK)
  // ════════════════════════════════════════════════════════════════════════════
  static Future<void> _ensureWorksheetAndHeaders() async {
    if (_sheetsApi == null || _spreadsheetId == null) return;

    final spreadsheet = await _sheetsApi!.spreadsheets.get(_spreadsheetId!);

    int? targetSheetId;
    bool exists = false;

    for (var s in spreadsheet.sheets ?? []) {
      if (s.properties?.title == _activeWorksheetTitle) {
        exists = true;
        targetSheetId = s.properties?.sheetId;
        break;
      }
    }

    if (!exists) {
      final addRes = await _sheetsApi!.spreadsheets.batchUpdate(
        sheets_api.BatchUpdateSpreadsheetRequest(requests: [
          sheets_api.Request(
            addSheet: sheets_api.AddSheetRequest(
              properties: sheets_api.SheetProperties(title: _activeWorksheetTitle),
            ),
          ),
        ]),
        _spreadsheetId!,
      );
      targetSheetId = addRes.replies?.first.addSheet?.properties?.sheetId;
      print('[GSheetsService] Tab "$_activeWorksheetTitle" created.');
    }

    final dropReqs = <sheets_api.Request>[];
    for (var s in spreadsheet.sheets ?? []) {
      if (s.properties?.title == 'Sheet1') {
        dropReqs.add(sheets_api.Request(
          deleteSheet:
          sheets_api.DeleteSheetRequest(sheetId: s.properties?.sheetId),
        ));
      }
    }
    if (dropReqs.isNotEmpty) {
      await _sheetsApi!.spreadsheets.batchUpdate(
          sheets_api.BatchUpdateSpreadsheetRequest(requests: dropReqs),
          _spreadsheetId!);
      print('[GSheetsService] Sheet1 dropped.');
    }

    await _sheetsApi!.spreadsheets.values.update(
      sheets_api.ValueRange(values: [
        [
          'RecNo', 'Date', 'Donor Name', 'PAN No', 'Mobile No', 'Amount',
          'Amount In Words', 'Payment Type', 'Bank Name', 'Cheque No',
          'Remarks', 'Donation Type', 'Created At', 'UpdatedAt'
        ]
      ]),
      _spreadsheetId!,
      '$_activeWorksheetTitle!A1:N1',
      valueInputOption: 'RAW',
    );

    await _sheetsApi!.spreadsheets.values.update(
      sheets_api.ValueRange(values: [List.filled(14, 'HIDDEN_ROW')]),
      _spreadsheetId!,
      '$_activeWorksheetTitle!A2:N2',
      valueInputOption: 'RAW',
    );

    if (targetSheetId != null) {
      await _sheetsApi!.spreadsheets.batchUpdate(
        sheets_api.BatchUpdateSpreadsheetRequest(requests: [
          // ── 1. Row 1: All 14 columns — Navy Blue Header (No unique color for Col J) ──
          sheets_api.Request(
            repeatCell: sheets_api.RepeatCellRequest(
              range: sheets_api.GridRange(
                sheetId: targetSheetId,
                startRowIndex: 0,
                endRowIndex: 1,
                startColumnIndex: 0,
                endColumnIndex: 14,
              ),
              cell: sheets_api.CellData(
                userEnteredFormat: sheets_api.CellFormat(
                  backgroundColor: sheets_api.Color(red: 0.1, green: 0.22, blue: 0.42, alpha: 1.0), // #1A3A6B Premium Navy
                  textFormat: sheets_api.TextFormat(
                    bold: true,
                    fontSize: 11,
                    foregroundColor: sheets_api.Color(red: 1.0, green: 1.0, blue: 1.0),
                  ),
                  horizontalAlignment: 'CENTER',
                ),
              ),
              fields: 'userEnteredFormat(backgroundColor,textFormat,horizontalAlignment)',
            ),
          ),

          // ── 2. Row 2: Plain White Hidden Buffer Row ────────────
          sheets_api.Request(
            repeatCell: sheets_api.RepeatCellRequest(
              range: sheets_api.GridRange(
                sheetId: targetSheetId,
                startRowIndex: 1,
                endRowIndex: 2,
                startColumnIndex: 0,
                endColumnIndex: 14,
              ),
              cell: sheets_api.CellData(
                userEnteredFormat: sheets_api.CellFormat(
                  backgroundColor: sheets_api.Color(red: 1.0, green: 1.0, blue: 1.0),
                  textFormat: sheets_api.TextFormat(bold: false, fontSize: 10, foregroundColor: sheets_api.Color(red: 1.0, green: 1.0, blue: 1.0)),
                ),
              ),
              fields: 'userEnteredFormat(backgroundColor,textFormat)',
            ),
          ),

          // ── 3. Hide Row 2 ──────────────────────────────────
          sheets_api.Request(
            updateDimensionProperties:
            sheets_api.UpdateDimensionPropertiesRequest(
              range: sheets_api.DimensionRange(
                sheetId: targetSheetId,
                dimension: 'ROWS',
                startIndex: 1,
                endIndex: 2,
              ),
              properties: sheets_api.DimensionProperties(hiddenByUser: true),
              fields: 'hiddenByUser',
            ),
          ),

          // ── 4. Freeze Row 1 ─────────────────────────────
          sheets_api.Request(
            updateSheetProperties: sheets_api.UpdateSheetPropertiesRequest(
              properties: sheets_api.SheetProperties(
                sheetId: targetSheetId,
                gridProperties: sheets_api.GridProperties(frozenRowCount: 1),
              ),
              fields: 'gridProperties.frozenRowCount',
            ),
          ),

          // ── 5. Auto-resize columns ─────────────────────────────────
          sheets_api.Request(
            autoResizeDimensions: sheets_api.AutoResizeDimensionsRequest(
              dimensions: sheets_api.DimensionRange(
                sheetId: targetSheetId,
                dimension: 'COLUMNS',
                startIndex: 0,
                endIndex: 14,
              ),
            ),
          ),
        ]),
        _spreadsheetId!,
      );
      print('[GSheetsService] ✅ All headers styled to Navy Blue seamlessly.');
    }
  }

  static Future<String> _getOrCreateFolder(String name) async {
    final q = "mimeType='application/vnd.google-apps.folder' and name='$name' and trashed=false";
    final res = await _driveApi!.files.list(q: q, $fields: 'files(id, name)');
    if (res.files != null && res.files!.isNotEmpty) return res.files!.first.id!;

    final f = drive.File()..name = name..mimeType = 'application/vnd.google-apps.folder';
    final c = await _driveApi!.files.create(f, $fields: 'id');
    return c.id!;
  }

  static Future<String> _getOrCreateSpreadsheet(String name, String folderId) async {
    final q = "mimeType='application/vnd.google-apps.spreadsheet' and name='$name' and '$folderId' in parents and trashed=false";
    final res = await _driveApi!.files.list(q: q, $fields: 'files(id, name)');
    if (res.files != null && res.files!.isNotEmpty) return res.files!.first.id!;

    final f = drive.File()..name = name..mimeType = 'application/vnd.google-apps.spreadsheet'..parents = [folderId];
    final c = await _driveApi!.files.create(f, $fields: 'id');
    return c.id!;
  }

  static Future<void> createNewFinancialYearTab(String fy) async {
    if (_sheetsApi == null || _spreadsheetId == null) return;

    final String newTitle = "Receipts_$fy";
    final spreadsheet = await _sheetsApi!.spreadsheets.get(_spreadsheetId!);

    bool exists = spreadsheet.sheets?.any((s) => s.properties?.title == newTitle) ?? false;

    if (!exists) {
      // નવી શીટ ઉમેરવાની રિક્વેસ્ટ
      await _sheetsApi!.spreadsheets.batchUpdate(
        sheets_api.BatchUpdateSpreadsheetRequest(requests: [
          sheets_api.Request(
            addSheet: sheets_api.AddSheetRequest(
              properties: sheets_api.SheetProperties(title: newTitle),
            ),
          ),
        ]),
        _spreadsheetId!,
      );

      // નવી શીટમાં હેડર રો સેટ કરો
      await _sheetsApi!.spreadsheets.values.update(
        sheets_api.ValueRange(values: [[
          'RecNo', 'Date', 'Donor Name', 'PAN No', 'Mobile No', 'Amount',
          'Amount In Words', 'Payment Type', 'Bank Name', 'Cheque No',
          'Remarks', 'Donation Type', 'Created At', 'UpdatedAt'
        ]]),
        _spreadsheetId!,
        '$newTitle!A1:N1',
        valueInputOption: 'RAW',
      );
      print('[GSheetsService] ✅ Tab "$newTitle" created with headers.');
    }
  }

  static Future<void> _buildClients(GoogleSignInAccount account) async {
    final headers = await account.authHeaders;
    final client = _AuthClient(headers);
    _driveApi = drive.DriveApi(client);
    _sheetsApi = sheets_api.SheetsApi(client);
  }

  static Future<void> signOut() async {
    try { await _googleSignIn.signOut(); } catch (_) {}
    reset();
  }

  static void reset() {
    _driveApi = null; _sheetsApi = null; _spreadsheetId = null;
    _currentUserId = null; _currentFY = null; _googleAccount = null;
    print('[GSheetsService] 🔄 Reset complete.');
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
