import 'package:flutter/material.dart';
import '../constant/constant.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool isRequired;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final bool readOnly;
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.readOnly = false,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textCapitalization = TextCapitalization.words,
    this.textInputAction = TextInputAction.next,
    this.onTap,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Label Above Field ───
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 2),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.black87),
            ),
          ),
          
          // ─── Text Field ───
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            minLines: minLines,
            maxLength: maxLength,
            obscureText: obscureText,
            readOnly: readOnly,
            textCapitalization: textCapitalization,
            textInputAction: textInputAction,
            onTap: onTap,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hintText ?? "Enter $label",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey.shade400, size: 18) : null,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.grey.shade50,
              counterText: '',
              
              // Standard Rounded Design (No border line by default)
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.appTheame.withValues(alpha: 0.5), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
              
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              alignLabelWithHint: maxLines != null && maxLines! > 1,
              errorStyle: const TextStyle(fontSize: 11),
            ),
            validator: validator ?? (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return "$label is required";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
