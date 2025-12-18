import 'package:demo_prac_getx/screen/auth/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AuthScreen extends GetView<AuthController> {
  static const pageId = "/AuthScreen";

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        // WEB VIEW SUPPORT: Constrains width on large screens
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
          child: Obx(() => Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: TabBarView(
                        controller: controller.tabController,
                        children: [
                          LoginForm(),
                          RegistrationForm(showFormFields: controller.showFormFields.value),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (controller.isLoading.value)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  ),
                ),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      // -----------------------------------------------------------
      // FIX 1: Removed fixed height (height: 220).
      // Used padding instead so it grows dynamically without crashing.
      // -----------------------------------------------------------
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
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.maps_home_work_outlined, size: 50, color: Colors.white),
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

            // -----------------------------------------------------------
            // FIX 2: Cleaned up the Double-Container nesting here.
            // -----------------------------------------------------------
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
                    // Important: Ensure this method exists in your controller
                    onTap: controller.handleRegisterTabTap,
                    child: const Tab(text: "Register"),
                  ),
                ],
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


