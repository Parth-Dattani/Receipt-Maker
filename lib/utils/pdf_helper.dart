import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class PdfHelper {
  /// Load company logo image bytes from URL or data:base64 string for PDF.
  static Future<Uint8List?> loadLogoBytes(String? logo) async {
    if (logo == null || logo.trim().isEmpty) return null;
    final s = logo.trim();
    try {
      if (s.startsWith('data:') && s.contains('base64,')) {
        final idx = s.indexOf('base64,');
        if (idx >= 0) {
          final base64 = s.substring(idx + 7).trim();
          if (base64.isNotEmpty) return Uint8List.fromList(base64Decode(base64));
        }
        return null;
      }
      if (s.startsWith('http://') || s.startsWith('https://')) {
        final response = await http.get(Uri.parse(s)).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) return response.bodyBytes;
      }
    } catch (_) {}
    return null;
  }
}
