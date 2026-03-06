import 'package:demo_prac_getx/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/controller.dart';


class LoginForm extends GetView<AuthController> {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 850;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 0 : 20,
            vertical: isWeb ? 0 : 20
        ),
        child: Container(
          padding: isWeb ? EdgeInsets.zero : null,
          decoration: isWeb ? null : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isWeb) ...[
                // Web: reference style – Username * / Password *, light grey fields, Remember me, Teal Login
                _buildWebLabel("Username *"),
                const SizedBox(height: 8),
                _buildWebInput(
                  controller: controller.loginUsernameController,
                  hint: "Enter your Username",
                  obscure: false,
                ),
                const SizedBox(height: 20),
                _buildWebLabel("Password *"),
                const SizedBox(height: 8),
                Obx(() => _buildWebInput(
                  controller: controller.loginPasswordController,
                  hint: "Enter your Password",
                  obscure: true,
                  isPasswordHidden: controller.isPasswordHidden.value,
                  onVisibilityToggle: controller.togglePasswordVisibility,
                )),
                const SizedBox(height: 16),
                Obx(() => Row(
                  children: [
                    SizedBox(
                      height: 22,
                      width: 22,
                      child: Checkbox(
                        value: controller.rememberMe.value,
                        onChanged: (v) => controller.rememberMe.value = v ?? false,
                        activeColor: AppColors.tealColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Remember me",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 28),
                Obx(() => _buildWebLoginButton(
                  isLoading: controller.isLoading.value,
                  onPressed: controller.handleLogin,
                )),
              ] else ...[
                // Mobile: unchanged
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
                      style: TextStyle(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w600
                      ),
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
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildWebLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  static Widget _buildWebInput({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    bool isPasswordHidden = true,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure && isPasswordHidden,
        style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF0F0F0),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          suffixIcon: obscure && onVisibilityToggle != null
              ? IconButton(
                  icon: Icon(
                    isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
        ),
      ),
    );
  }

  static Widget _buildWebLoginButton({
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tealColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                "Login",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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