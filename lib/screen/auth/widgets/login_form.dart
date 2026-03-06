import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/controller.dart';
import '../../../widgets/widgets.dart';


class LoginForm extends GetView<AuthController> {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 850;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 40 : 20,
            vertical: isWeb ? 40 : 20
        ),
        child: Container(
          // Web માટે ખાસ કાર્ડ સ્ટાઇલ
          padding: isWeb ? const EdgeInsets.all(30) : EdgeInsets.zero,
          decoration: isWeb ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 25,
                offset: const Offset(0, 10),
              )
            ],
          ) : null, // મોબાઈલમાં જેવું હતું તેવું જ રહેશે
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isWeb) ...[
                const Text(
                  "Sign In",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter your credentials to access Invoice Sathi",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 35),
              ],

              // Email Field
              _buildTealTextField(
                controller: controller.loginUsernameController,
                label: "Email Address",
                icon: Icons.email_outlined,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password Field
              Obx(() => _buildTealTextField(
                controller: controller.loginPasswordController,
                label: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
                isPasswordHidden: controller.isPasswordHidden.value,
                onVisibilityToggle: controller.togglePasswordVisibility,
              )),

              const SizedBox(height: 10),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: controller.isLoading.value ? null : controller.showForgotPasswordDialog,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Login Button
              Obx(() => _buildPrimaryButton(
                text: "LOGIN",
                isLoading: controller.isLoading.value,
                onPressed: controller.handleLogin,
              )),

              if (isWeb) const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


// --- SHARED WIDGETS (તમારા જ વિજેટ્સ, Web માટે થોડા એડજસ્ટ કર્યા છે) ---

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
      color: Colors.white, // Web પર સફેદ બેકગ્રાઉન્ડ વધુ સારું લાગે
      borderRadius: BorderRadius.circular(12), // થોડા શાર્પ કોર્નર્સ Web માટે
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      obscureText: isPassword && isPasswordHidden,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.black87, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.teal.shade600, size: 22),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordHidden ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade400,
            size: 20,
          ),
          onPressed: onVisibilityToggle,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
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
    height: 52, // Web માટે સ્ટાન્ડર્ડ હાઈટ
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0, // Web પર ફ્લેટ બટન વધુ સારા લાગે છે
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Input field જેવી જ રેડિયસ
        ),
      ),
      child: isLoading
          ? const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      )
          : Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    ),
  );
}