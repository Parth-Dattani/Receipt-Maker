import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/constant.dart';
import '../../controller/auth_controller.dart';
import '../../widgets/custom_text_form_field.dart';
import 'register_screen.dart';

class LoginScreen extends GetView<AuthController> {
  static const pageId = "/login";
  const LoginScreen({super.key});

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
                      Image.asset(
                        ImagePath.appLogo, 
                        height: 120, 
                        filterQuality: FilterQuality.high,
                        isAntiAlias: true,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        AppStrings.appName.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Empowering Trust. Simplifying Contribution.\nYour Entire Management, In Your Pocket.",
                        style: TextStyle(color: Colors.white70, fontSize: 20, height: 1.5),
                      ),
                      const SizedBox(height: 60),

                      // Feature List
                      _buildFeatureRow(Icons.verified_user_rounded, "Secure Data Access"),
                      _buildFeatureRow(Icons.print_rounded, "Print & Digital Receipts"),
                      _buildFeatureRow(Icons.analytics_rounded, "Advanced Collection Reports"),
                    ],
                  ),
                ),
              ),
            ),

          // ─── Right Side: Login Form ───
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
                    key: controller.loginFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isWideScreen) ...[
                          Image.asset(
                            ImagePath.appLogo, 
                            height: 90,
                            filterQuality: FilterQuality.high,
                            isAntiAlias: true,
                          ),
                          const SizedBox(height: 16),
                        ],
                        const Text(
                          "Welcome Back",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
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
                            validator: (v) => v!.isEmpty ? 'Password required' : null,
                          )),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: controller.resetPassword,
                              child: Text('Forgot password?', style: TextStyle(color: AppColors.appTheame, fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Login Button
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ? null : controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.appTheame,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                  : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          )),

                          const SizedBox(height: 30),
                          _buildDivider(),
                          const SizedBox(height: 30),

                          // Google Sign-In
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: controller.isLoading.value ? null : () => controller.loginWithGoogle(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.g_mobiledata_rounded, color: Colors.blue, size: 28),
                                  const SizedBox(width: 12),
                                  const Text('Sign in with Google', style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          )),

                          const SizedBox(height: 40),

                          // Footer Links
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?", style: TextStyle(color: Colors.black54, fontSize: 14)),
                              TextButton(
                                onPressed: () {
                                  controller.clearControllers();
                                  Get.toNamed(RegisterScreen.pageId);
                                },
                                child: Text('Register', style: TextStyle(color: AppColors.appTheame, fontWeight: FontWeight.bold, fontSize: 14)),
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("or", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
      ],
    );
  }
}
