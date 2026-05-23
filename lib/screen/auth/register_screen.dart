import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/constant.dart'; // તમારા પ્રોજેક્ટ મુજબ પાથ ચેક કરી લેવો
import '../../controller/auth_controller.dart';

class RegisterScreen extends GetView<AuthController> {
  static const pageId = "/register";
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor2,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: controller.registerFormKey,
              child: Container(
                // 🌟 વેબ કે લેપટોપની મોટી સ્ક્રીન પર કાર્ડ ખેંચાઈ ન જાય એટલે મેક્સિમમ 450 width આપવી
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
                        'Create Account',
                        style: TextStyle(color: AppColors.appTheame, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 📑 Register Details Card
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
                              'Register',
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
                            validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null,
                          )),
                          const SizedBox(height: 16),

                          // 🔒 Confirm Password Field
                          Obx(() => TextFormField(
                            controller: controller.confirmPasswordController,
                            obscureText: controller.obscureConfirmPassword.value,
                            decoration: _inputDecoration('Confirm Password', Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(controller.obscureConfirmPassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () => controller.obscureConfirmPassword.toggle(),
                              ),
                            ),
                            validator: (v) => v != controller.passwordController.text ? 'Passwords do not match' : null,
                          )),
                          const SizedBox(height: 28),

                          // 🚀 Register Button
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ? null : controller.register,
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
                                  : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          )),

                          const SizedBox(height: 24),

                          // 🔙 Back to Login Redirection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account?", style: TextStyle(color: Colors.grey, fontSize: 13)),
                              TextButton(
                                onPressed: () {
                                  controller.clearControllers();
                                  Get.back();
                                },
                                child: Text('Login', style: TextStyle(color: AppColors.appTheame, fontWeight: FontWeight.bold, fontSize: 13)),
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

  // 🎨 Input Fields Styling (Consistent with LoginScreen)
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
