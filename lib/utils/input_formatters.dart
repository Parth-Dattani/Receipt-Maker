import 'package:flutter/services.dart';

/// Strips any non-digit character (decimal point, comma, etc.) so mobile
/// keyboards cannot enter decimal values for PCS/box quantity fields.
class IntegerOnlyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly == newValue.text) return newValue;

    // Adjust selection so cursor stays in a valid position
    int selectionIndex = digitsOnly.length;
    if (newValue.selection.end > digitsOnly.length) {
      selectionIndex = digitsOnly.length;
    } else if (newValue.selection.end < 0) {
      selectionIndex = 0;
    } else {
      selectionIndex = newValue.selection.end.clamp(0, digitsOnly.length);
    }

    return TextEditingValue(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// Allows digits and at most one decimal separator (. or , or any other) for gm/kg etc.
/// Works reliably on mobile where keyboards can send different decimal characters.
class DecimalQuantityInputFormatter extends TextInputFormatter {
  static bool _isDigit(String c) => RegExp(r'[0-9]').hasMatch(c);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final StringBuffer allowed = StringBuffer();
    bool seenSeparator = false;
    for (int i = 0; i < newValue.text.length; i++) {
      final c = newValue.text[i];
      if (_isDigit(c)) {
        allowed.write(c);
      } else if (!seenSeparator) {
        // Allow one decimal separator (., , or any non-digit some keyboards use)
        allowed.write('.');
        seenSeparator = true;
      }
    }

    final String result = allowed.toString();
    if (result == newValue.text) return newValue;

    int selectionIndex = newValue.selection.end;
    if (selectionIndex > result.length) selectionIndex = result.length;
    if (selectionIndex < 0) selectionIndex = 0;

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
