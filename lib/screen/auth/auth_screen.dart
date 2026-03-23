import 'package:GetYourInvoice/screen/auth/widgets/widget.dart';
import 'package:GetYourInvoice/constant/app_colors.dart';
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
        // LEFT PANEL - unchanged
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

        // ✅ RIGHT PANEL - Register tab માં wider
        Obx(() {
          final isRegister = controller.currentTabIndex.value == 1;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isRegister
                ? MediaQuery.of(context).size.width * 0.55
                : MediaQuery.of(context).size.width * 0.4,
            color: const Color(0xFF004D40),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isRegister ? 680 : 420,
                  ),
                  child: _buildWebLoginCard(context),
                ),
              ),
            ),
          );
        }),
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
            // ==================== LOGIN TAB ====================
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
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.showForgotPasswordDialog,
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
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade600),
                        ),
                        TextButton(
                          onPressed: controller.handleRegisterTabTap,
                          style: TextButton.styleFrom(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: AppColors.tealColor,
                          ),
                          child: const Text("Register",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            // ==================== REGISTER TAB ====================
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
                const SizedBox(height: 6),
                Text(
                  "Fill in the details to get started",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Info Banner
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.teal.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "For New Registration Contact your Authorised Person",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ROW 1: Full Name + Email
                Row(
                  children: [
                    Expanded(
                      child: _buildTealTextField(
                        controller: controller.regUsernameController,
                        label: "Full Name",
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildTealTextField(
                        controller: controller.regEmailController,
                        label: "Email ID",
                        icon: Icons.email_outlined,
                        inputType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ROW 2: Password + Mobile 1
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => _buildTealTextField(
                        controller: controller.loginPasswordController,
                        label: "Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isPasswordHidden:
                        controller.isPasswordHidden.value,
                        onVisibilityToggle:
                        controller.togglePasswordVisibility,
                      )),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildTealTextField(
                        controller: controller.regMobile1Controller,
                        label: "Mobile No. 1",
                        icon: Icons.phone_android,
                        inputType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ROW 3: Mobile 2 + Country
                Row(
                  children: [
                    Expanded(
                      child: _buildTealTextField(
                        controller: controller.regMobile2Controller,
                        label: "Mobile No. 2 (Optional)",
                        icon: Icons.phone_android,
                        inputType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Obx(() => _buildTealDropdown(
                        label: "Country",
                        icon: Icons.flag_outlined,
                        value: controller.selectedCountry.value.isEmpty
                            ? null
                            : controller.selectedCountry.value,
                        items: controller.countries,
                        onChanged: (value) {
                          controller.selectedCountry.value = value ?? '';
                          controller.selectedState.value = '';
                        },
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ROW 4: State + City
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        if (controller.selectedCountry.value.isNotEmpty) {
                          return _buildTealDropdown(
                            label: "State",
                            icon: Icons.map_outlined,
                            value: controller.selectedState.value.isEmpty
                                ? null
                                : controller.selectedState.value,
                            items: controller.getStatesForCountry(),
                            onChanged: (val) =>
                            controller.selectedState.value = val ?? '',
                          );
                        }
                        return _buildTealTextField(
                          controller: TextEditingController(),
                          label: "Select Country First",
                          icon: Icons.map_outlined,
                        );
                      }),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildTealTextField(
                        controller: controller.regCityController,
                        label: "City",
                        icon: Icons.location_city_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Demo Checkbox
                Obx(() => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: CheckboxListTile(
                    value: controller.isDemo.value,
                    onChanged: (val) =>
                    controller.isDemo.value = val ?? false,
                    title: Text(
                      "Demo Account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade900,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: const Text(
                      "Check to create a test account",
                      style: TextStyle(fontSize: 11),
                    ),
                    activeColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 2),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                )),
                const SizedBox(height: 20),

                // Register Button
                _buildPrimaryButton(
                  text: "REGISTER",
                  isLoading: controller.isLoading.value,
                  onPressed: controller.handleRegistration,
                ),
                const SizedBox(height: 16),

                // Already have account
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                      TextButton(
                        onPressed: () =>
                            controller.tabController.animateTo(0),
                        style: TextButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppColors.tealColor,
                        ),
                        child: const Text("Login",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),

          // Footer - both tabs
          const SizedBox(height: 20),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "© ${DateTime.now().year} InvoiceSathi. All rights reserved.",
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

  Widget _buildTealDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final safeValue = items.contains(value) ? value : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: safeValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.teal, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
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
          const Tab(text: "Register"),
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


