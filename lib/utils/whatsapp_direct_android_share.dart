import 'dart:io' as io;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class WhatsappDirectAndroidShare {
  static const MethodChannel _fileProvider = MethodChannel('invoice_sathi/file_provider');
  static const MethodChannel _whatsappShare = MethodChannel('invoice_sathi/whatsapp_share');

  /// PDF ને એપના કેશ ડિરેક્ટરીમાં કોપી કરે છે જેથી FileProvider તેને એક્સેસ કરી શકે
  static Future<io.File> materializeShareablePdf(
      io.File source, {
        String? suggestedFileName,
      }) async {
    if (kIsWeb) return source;
    if (!io.Platform.isAndroid) return source;
    final tmpDir = await getTemporaryDirectory();
    final rawName = (suggestedFileName ?? (source.uri.pathSegments.isNotEmpty
        ? source.uri.pathSegments.last
        : 'receipt.pdf'))
        .trim();

    final cleanedBase = rawName
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '');
    final safe = cleanedBase.toLowerCase().endsWith('.pdf')
        ? cleanedBase
        : '$cleanedBase.pdf';

    final dest = io.File('${tmpDir.path}/$safe');
    return source.copy(dest.path);
  }

  /// ડાયરેક્ટ WhatsApp ચેટ ઓપન કરીને PDF મોકલે છે
  static Future<bool> sendPdfToWhatsAppChat({
    required io.File pdfFile,
    required String toPhoneE164,
    required String caption,
    io.File? preparedShareFile,
  }) async {
    if (kIsWeb || !io.Platform.isAndroid) return false;

    final digits = toPhoneE164.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return false;

    // જો તૈયાર ફાઇલ ન હોય તો મટીરિયલાઈઝ કરો
    final io.File shareFile = preparedShareFile ?? await materializeShareablePdf(pdfFile);

    try {
      // 🚀 અહીં authority ખાસ ચેક કરજો: 'com.pixelperfect.receipt.fileprovider'
      final uriStr = await _fileProvider.invokeMethod<String>(
        'getUriForFile',
        <String, dynamic>{
          'path': shareFile.path,
          'authority': 'com.pixelperfect.receipt.fileprovider',
        },
      );
      if (uriStr == null || uriStr.isEmpty) return false;

      final ok = await _whatsappShare.invokeMethod<bool>(
        'sendPdf',
        <String, dynamic>{
          'uri': uriStr,
          'caption': caption,
          'digits': digits,
        },
      );
      return ok == true;
    } on MissingPluginException catch (e) {
      debugPrint('Native bridge missing ($e). એપ અનઇન્સ્ટોલ કરીને ફરી રન કરો.');
      return false;
    }
  }
}