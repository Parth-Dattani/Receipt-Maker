import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool isRequired;
  final TextInputType keyboardType;
  final IconData? prefixIcon; // ✅ make prefixIcon optional
  final bool readOnly;

  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon, // ✅ optional
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null, // ✅ only show if provided
        ),
          readOnly: readOnly,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return "$label is required";
          }
          return null;
        },
      ),
    );
  }
}
