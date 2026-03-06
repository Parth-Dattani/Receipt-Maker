import 'package:demo_prac_getx/screen/auth/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AuthScreen extends GetView<AuthController> {
  static const pageId = "/AuthScreen";

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isWeb = size.width > 850;

    return Scaffold(
      backgroundColor: isWeb ? Colors.teal.shade50 : Colors.grey.shade100,
      body: Obx(() => Stack(
        children: [
          isWeb ? _buildWebLayout(size) : _buildMobileLayout(),

          // Loading Overlay
          if (controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              ),
            ),
        ],
      )),
    );
  }

  // --- 1. WEB LAYOUT ---
  Widget _buildWebLayout(Size size) {
    return Row(
      children: [
        // --- LEFT BRANDING PANEL ---
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade900, Colors.teal.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  left: -50,
                  child: CircleAvatar(radius: 120, backgroundColor: Colors.white.withOpacity(0.05)),
                ),
                Positioned(
                  bottom: -80,
                  right: -20,
                  child: CircleAvatar(radius: 150, backgroundColor: Colors.black.withOpacity(0.05)),
                ),

                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center, // બધું સેન્ટરમાં રાખવા
                        children: [
                          // --- APP LOGO ---
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 10))
                              ],
                            ),
                            child: Image.asset(
                              "assets/images/app_logo.png",
                              height: 100,
                              width: 100,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.receipt_long, size: 80, color: Colors.teal),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Invoice Sathi",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Smart Billing & Inventory Partner",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),

                          const SizedBox(height: 50),

                          // --- PROPERLY MANAGED FEATURE POINTS ---
                          _buildFeatureItem(Icons.print_rounded, "Thermal Print Support"),
                          _buildFeatureItem(Icons.inventory_2_outlined, "Manage Stock & Inventory"),
                          _buildFeatureItem(Icons.analytics_outlined, "Business Growth Insights"),
                          _buildFeatureItem(Icons.verified_user_outlined, "Secure Data Storage"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- RIGHT FORM PANEL ---
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 450,
                margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 10))
                  ],
                ),
                child: _buildMainContent(isWeb: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- FEATURE ITEM WITH PROPER ALIGNMENT ---
  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: SizedBox(
        width: 300, // આ વિડ્થ ફિક્સ રાખવાથી બધા આઈકોન એક લાઈનમાં આવશે
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.tealAccent, size: 22),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. MOBILE LAYOUT ---
  Widget _buildMobileLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        color: Colors.white,
        child: _buildMainContent(isWeb: false),
      ),
    );
  }

  // --- COMMON CONTENT ---
  Widget _buildMainContent({required bool isWeb}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(isWeb),
        SizedBox(
          height: 550,
          child: TabBarView(
            controller: controller.tabController,
            children: [
              LoginForm(),
              Obx(() => RegistrationForm(showFormFields: controller.showFormFields.value)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isWeb) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade800, Colors.teal.shade400],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: const Radius.circular(40),
          bottomRight: const Radius.circular(40),
          topLeft: isWeb ? const Radius.circular(20) : Radius.zero,
          topRight: isWeb ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (!isWeb)
              Container(
                height: 75,
                width: 75,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  "assets/images/app_logo.png",
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.receipt_long, size: 40, color: Colors.teal),
                ),
              ),
            const SizedBox(height: 10),
            const Text(
              "Invoice Sathi",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
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
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.teal.shade800,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.white,
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: "Login"), Tab(text: "Register")],
              ),
            ),
          ],
        ),
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


