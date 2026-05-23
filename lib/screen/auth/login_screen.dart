import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/constant.dart'; // તમારા પ્રોજેક્ટ મુજબ પાથ ચેક કરી લેવો
import '../../controller/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends GetView<AuthController> {
  static const pageId = "/login";
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌟 વેબ રિસ્પોન્સિવનેસ માટે ડિવાઇસની વિડ્થ ચેક કરવી
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.whiteColor2,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: controller.loginFormKey,
              child: Container(
                // 🌟 જો વેબ કે ટેબ્લેટ મોટી સ્ક્રીન હોય તો મેક્સિમમ 450 width આપવી jethi card ખેંચાય નહિ
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // 🏢 Logo & Trust Name Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.appTheame,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.appTheame.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 4
                          )
                        ],
                      ),
                      child: const Icon(Icons.account_balance, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.trustName,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.appTheame),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      AppStrings.trustRegNo,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.appTheame.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Receipt Manager',
                        style: TextStyle(color: AppColors.appTheame, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 📑 Login Credentials Card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 6)
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Login',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.appTheame)
                          ),
                          const SizedBox(height: 24),

                          // ✉️ Email Field
                          TextFormField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration('Email', Icons.email_outlined),
                            validator: (v) => v!.isEmpty ? 'Email required' : (GetUtils.isEmail(v) ? null : 'Invalid email'),
                          ),
                          const SizedBox(height: 16),

                          // 🔒 Password Field
                          Obx(() => TextFormField(
                            controller: controller.passwordController,
                            obscureText: controller.obscurePassword.value,
                            decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(controller.obscurePassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () => controller.obscurePassword.toggle(),
                              ),
                            ),
                            validator: (v) => v!.isEmpty ? 'Password required' : null,
                          )),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: controller.resetPassword,
                              child: Text('Forgot Password?', style: TextStyle(color: AppColors.appTheame, fontSize: 13, fontWeight: FontWeight.w500)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 🚀 Regular Login Button
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ? null : controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.appTheame,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                                  : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          )),

                          const SizedBox(height: 24),

                          // ── 🌟 OR Divider ──────────────────────────────────────
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1.5)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text("OR", style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1.5)),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── 🌟 Google Sign-In Button (With Obx Loader) ─────────
                          // ── 🌟 Google Sign-In Button (વિથ સેફ આઈકોન અને ઓવરફ્લો સોલ્યુશન) ─────────
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: controller.isLoading.value ? null : () => controller.loginWithGoogle(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Colors.grey.shade50,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min, // 🌟 ઓવરફ્લો અટકાવવા માટે મિનિમમ સાઈઝ
                                children: [
                                  // 🌟 નેટવર્ક ઈમેજની જગ્યાએ સેફ ગૂગલ બ્રાન્ડ આઈકોન લુક
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.g_mobiledata_rounded, // ફ્લટરનું ઇનબિલ્ટ આઇકોન જે ક્યારેય ક્રેશ નહીં થાય
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Flexible( // 🌟 ટેક્સ્ટ જો મોટી થાય તો પણ ઓવરફ્લો નહિ થાય
                                    child: Text(
                                      'Sign in with Google',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),

                          const SizedBox(height: 24),

                          // 📝 Register Redirection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?", style: TextStyle(color: Colors.grey, fontSize: 13)),
                              TextButton(
                                onPressed: () {
                                  controller.clearControllers();
                                  Get.toNamed(RegisterScreen.pageId);
                                },
                                child: Text('Register', style: TextStyle(color: AppColors.appTheame, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🎨 Input Fields Styling
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.appTheame, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.appTheame, width: 1.5)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}