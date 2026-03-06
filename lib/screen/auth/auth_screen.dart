import 'package:demo_prac_getx/screen/auth/widgets/widget.dart';
import 'package:demo_prac_getx/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/controller.dart';


class AuthScreen extends GetView<AuthController> {
  static const pageId = "/AuthScreen";
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: isWeb ? const Color(0xFF004D40) : Colors.grey.shade100,
      body: Obx(() => Stack(
        children: [
          // ફક્ત વેબ હોય તો જ નવું લેઆઉટ, બાકી તારો ઓરિજિનલ મોબાઈલ વ્યુ
          isWeb ? _buildWebProfessionalLayout(context) : _buildOriginalMobileLayout(context),

          if (controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(child: CircularProgressIndicator(color: AppColors.tealColor)),
            ),
        ],
      )),
    );
  }

  // ==========================================
  // Web layout: left panel (teal) + right login card
  // ==========================================
  Widget _buildWebProfessionalLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Container(
            color: const Color(0xFF004D40),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 56),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/app_logo.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.maps_home_work_outlined,
                          size: 100,
                          color: Colors.tealAccent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Invoice Sathi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Empowering Growth. Simplifying Billing.\n Your Entire Business, In Your Pocket.",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),
                      IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWebPoint(Icons.verified_user_outlined, "Secure Data Access"),
                            _buildWebPoint(Icons.print_rounded, "Thermal Printing Support"),
                            _buildWebPoint(Icons.inventory_2_outlined, "Inventory Management"),
                            _buildWebPoint(Icons.receipt_long_outlined, "Invoice & Challan"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            color: const Color(0xFF004D40),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _buildWebLoginCard(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebLoginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            if (controller.currentTabIndex.value == 0) {
              return Column(
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  const LoginForm(),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: controller.isLoading.value ? null : controller.showForgotPasswordDialog,
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        TextButton(
                          onPressed: controller.handleRegisterTabTap,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: AppColors.tealColor,
                          ),
                          child: const Text("Register", style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 420,
                  child: SingleChildScrollView(
                    child: Obx(() => RegistrationForm(showFormFields: controller.showFormFields.value)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      TextButton(
                        onPressed: () => controller.tabController.animateTo(0),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppColors.tealColor,
                        ),
                        child: const Text("Login", style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "© ${DateTime.now().year} GetYourInvoice. All rights reserved.",
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              "Developed By Intelligent Tech",
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Mobile layout (unchanged)
  // ==========================================
  Widget _buildOriginalMobileLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            _buildHeader(), // તારું ઓરિજિનલ હેડર નીચે છે
            Expanded(
              child: Container(
                color: Colors.white,
                child: TabBarView(
                  controller: controller.tabController,
                  children: [
                    const LoginForm(),
                    RegistrationForm(showFormFields: controller.showFormFields.value),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // તારું ઓરિજિનલ હેડર - બેઠું જ
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade800, Colors.teal.shade400],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/app_logo.png',
              height: 80,
              width: 80,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.maps_home_work_outlined,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Welcome Back",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            _buildOriginalTabBarUI(),
          ],
        ),
      ),
    );
  }

  // તારું ઓરિજિનલ TabBar UI - 7-Tap Safe
  Widget _buildOriginalTabBarUI() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(50),
      ),
      child: TabBar(
        controller: controller.tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.teal.shade800,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelColor: Colors.white,
        dividerColor: Colors.transparent,
        tabs: [
          const Tab(text: "Login"),
          GestureDetector(
            onTap: controller.handleRegisterTabTap, // આ તારું 7-Tap લોજિક છે
            child: const Tab(text: "Register"),
          ),
        ],
      ),
    );
  }

  Widget _buildWebPoint(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 28,
            child: Center(
              child: Icon(icon, color: Colors.tealAccent, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

///old Woring 10-12
// class AuthScreen extends GetView<AuthController> {
//   static const pageId = "/AuthScreen";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100, // Light background for Web contrast
//       body: Center(
//         // WEB VIEW SUPPORT: Constrains width on large screens (Web/Desktop)
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 500),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               // Adds a shadow on Web to make it pop like a card
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               )
//             ],
//           ),
//           child: Obx(() => Stack(
//             children: [
//               Column(
//                 children: [
//                   _buildHeader(),
//                   Expanded(
//                     child: Container(
//                       color: Colors.white,
//                       child: TabBarView(
//                         controller: controller.tabController,
//                         children: [
//                           LoginForm(),
//                           RegistrationForm(showFormFields: controller.showFormFields.value),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               if (controller.isLoading.value)
//                 Container(
//                   color: Colors.black.withOpacity(0.4),
//                   child: const Center(
//                     child: CircularProgressIndicator(color: Colors.tealAccent),
//                   ),
//                 ),
//             ],
//           )),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       height: 220,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.teal.shade800, Colors.teal.shade400], // TEAL Gradient
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(40),
//           bottomRight: Radius.circular(40),
//         ),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 10,
//             offset: Offset(0, 5),
//           )
//         ],
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: Column(
//           mainAxisSize: MainAxisSize.min, // Allow column to shrink/grow based on content
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20),
//             const Icon(Icons.maps_home_work_outlined, size: 50, color: Colors.white),
//             const SizedBox(height: 10),
//             const Text(
//               "Welcome Back",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.2,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 30),
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 30),
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(50),
//                 ),
//                 child: TabBar(
//                   controller: controller.tabController,
//                   indicator: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(50),
//                     boxShadow: const [
//                       BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
//                     ],
//                   ),
//                   indicatorSize: TabBarIndicatorSize.tab,
//                   labelColor: Colors.teal.shade800, // Active Tab Color
//                   labelStyle: const TextStyle(fontWeight: FontWeight.bold),
//                   unselectedLabelColor: Colors.white,
//                   dividerColor: Colors.transparent,
//                   tabs: [
//                     const Tab(text: "Login"),
//                     GestureDetector(
//                       onTap: controller.handleRegisterTabTap,
//                       child: const Tab(text: "Register"),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


