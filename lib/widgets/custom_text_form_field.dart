import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool isRequired;
  final TextInputType keyboardType;
  final IconData? prefixIcon; // ✅ make prefixIcon optional
  final bool readOnly;
  final int? maxLines; // ✅ NEW: number of lines to display
  final int? minLines; // ✅ NEW: minimum lines
  final String? Function(String?)? validator; // optional custom validator

  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon, // ✅ optional
    this.readOnly = false,
    this.maxLines = 1, // ✅ default is single line
    this.minLines, // ✅ optional minimum lines
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines, // ✅ allows multi-line input
        minLines: minLines, // ✅ minimum lines to show
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null, // ✅ only show if provided
          // ✅ Align icon to top when multi-line
          alignLabelWithHint: maxLines != null && maxLines! > 1,
        ),
          readOnly: readOnly,
        validator: validator ?? (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return "$label is required";
          }
          return null;
        },
      ),
    );
  }
}
