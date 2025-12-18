import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/controller.dart';
import '../../../widgets/widgets.dart';

class LoginForm extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          _buildTealTextField(
            controller: controller.loginUsernameController,
            label: "Email Address",
            icon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          Obx(() => _buildTealTextField(
            controller: controller.loginPasswordController,
            label: "Password",
            icon: Icons.lock_outline,
            isPassword: true,
            isPasswordHidden: controller.isPasswordHidden.value,
            onVisibilityToggle: controller.togglePasswordVisibility,
          )),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.isLoading.value ? null : controller.showForgotPasswordDialog,
              child: Text(
                "Forgot Password?",
                style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Obx(() => _buildPrimaryButton(
            text: "LOGIN",
            isLoading: controller.isLoading.value,
            onPressed: controller.handleLogin,
          )),
        ],
      ),
    );
  }
}


// --- SHARED WIDGETS (TEAL STYLE) ---

Widget _buildTealTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType inputType = TextInputType.text,
  bool isPassword = false,
  bool isPasswordHidden = false,
  VoidCallback? onVisibilityToggle,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade50, // Very slight grey for input
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      obscureText: isPassword && isPasswordHidden,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.teal), // Teal Icon
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordHidden ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onVisibilityToggle,
        )
            : null,
        // No border until focused
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5), // Teal Border on Focus
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    ),
  );
}

Widget _buildPrimaryButton({
  required String text,
  required VoidCallback onPressed,
  bool isLoading = false,
}) {
  return SizedBox(
    height: 55,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal, // Main Teal Color
        foregroundColor: Colors.white,
        elevation: 5,
        shadowColor: Colors.teal.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: isLoading
          ? const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      )
          : Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    ),
  );
}
