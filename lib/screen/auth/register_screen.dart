import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/constant.dart';
import '../../controller/auth_controller.dart';
import '../../widgets/custom_text_form_field.dart';

class RegisterScreen extends GetView<AuthController> {
  static const pageId = "/register";
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 900;

    return Scaffold(
      backgroundColor: isWideScreen ? Colors.white : AppColors.whiteColor2,
      body: Row(
        children: [
          // ─── Left Side: Branding (Visible only on Web/Desktop) ───
          if (isWideScreen)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.appTheame, AppColors.appTheame.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Image.asset(ImagePath.appLogo, height: 80),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Join ${AppStrings.appName}".toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Start Managing Your Trust Collections Professionally.\nSimple, Fast, and Secure.",
                        style: TextStyle(color: Colors.white70, fontSize: 20, height: 1.5),
                      ),
                      const SizedBox(height: 60),

                      // Benefits
                      _buildFeatureRow(Icons.rocket_launch_rounded, "Instant Setup"),
                      _buildFeatureRow(Icons.people_alt_rounded, "Unlimited Donor Records"),
                      _buildFeatureRow(Icons.security_rounded, "End-to-End Security"),
                    ],
                  ),
                ),
              ),
            ),

          // ─── Right Side: Register Form ───
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: controller.registerFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isWideScreen) ...[
                          Image.asset(ImagePath.appLogo, height: 70),
                          const SizedBox(height: 16),
                        ],
                        const Text(
                          "Create Account",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Fill the details to get started",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 32),

                          // Email Field
                          CustomTextFormField(
                            label: "Email Address",
                            hintText: "Enter your Email",
                            prefixIcon: Icons.email_outlined,
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v!.isEmpty ? 'Email required' : (GetUtils.isEmail(v) ? null : 'Invalid email'),
                          ),

                          // Password Field
                          Obx(() => CustomTextFormField(
                            label: "Password",
                            hintText: "Enter your Password",
                            prefixIcon: Icons.lock_outline,
                            controller: controller.passwordController,
                            obscureText: controller.obscurePassword.value,
                            suffixIcon: IconButton(
                              icon: Icon(controller.obscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                              onPressed: () => controller.obscurePassword.toggle(),
                            ),
                            validator: (v) => v!.length < 6 ? 'Password too short' : null,
                          )),

                          // Confirm Password Field
                          Obx(() => CustomTextFormField(
                            label: "Confirm Password",
                            hintText: "Confirm your Password",
                            prefixIcon: Icons.lock_outline,
                            controller: controller.confirmPasswordController,
                            obscureText: controller.obscureConfirmPassword.value,
                            suffixIcon: IconButton(
                              icon: Icon(controller.obscureConfirmPassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                              onPressed: () => controller.obscureConfirmPassword.toggle(),
                            ),
                            validator: (v) => v != controller.passwordController.text ? 'Passwords do not match' : null,
                          )),

                          const SizedBox(height: 30),

                          // Register Button
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ? null : controller.register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.appTheame,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                  : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          )),

                          const SizedBox(height: 40),

                          // Login Redirection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account?", style: TextStyle(color: Colors.black54, fontSize: 14)),
                              TextButton(
                                onPressed: () {
                                  controller.clearControllers();
                                  Get.back();
                                },
                                child: Text('Login', style: TextStyle(color: AppColors.appTheame, fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                            ],
                          ),

                          const SizedBox(height: 60),
                          Text(
                            "© 2026 Noor Receipt. All rights reserved.\nDeveloped by Intelligent Tech",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade400, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 15),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
