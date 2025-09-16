// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
//
// import '../../constant/constant.dart';
// import '../../controller/controller.dart';
// import '../QrScannerScreen.dart';
//
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class ConnectAppSheetScreen extends StatelessWidget {
//   ConnectAppSheetScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Use Get.find with defensive programming
//     final AuthController authController = Get.find<AuthController>();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Connect Your AppSheet App'),
//         backgroundColor: AppColors.appColor,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildInstructionsCard(),
//             const SizedBox(height: 20),
//             _buildUrlInputField(authController),
//             const SizedBox(height: 20),
//             _buildConnectButton(authController),
//             const SizedBox(height: 16),
//             _buildAlternativeOptions(authController),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInstructionsCard() {
//     return Card(
//       color: Colors.blue[50],
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'How to find your AppSheet URL:',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue[700],
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 8),
//             _buildInstructionStep('1. Open your app in the AppSheet portal.'),
//             _buildInstructionStep('2. Click the "Share" button.'),
//             _buildInstructionStep('3. Copy the URL provided.'),
//             _buildInstructionStep('4. Paste it in the field below.'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInstructionStep(String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Text(text, style: TextStyle(color: Colors.blue[700])),
//     );
//   }
//
//   Widget _buildUrlInputField(AuthController authController) {
//     return TextField(
//       controller: authController.appSheetUrlController,
//       decoration: InputDecoration(
//         labelText: 'AppSheet App URL',
//         hintText: 'https://www.appsheet.com/start/your-app-id-here',
//         border: const OutlineInputBorder(),
//         suffixIcon: IconButton(
//           icon: const Icon(Icons.paste),
//           onPressed: () async {
//             final data = await Clipboard.getData('text/plain');
//             if (data != null && data.text != null) {
//               authController.appSheetUrlController.text = data.text!;
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildConnectButton(AuthController authController) {
//     return Obx(() => SizedBox(
//       width: double.infinity,
//       child: authController.isLoading.value
//           ? const Center(child: CircularProgressIndicator())
//           : ElevatedButton(
//         onPressed: () => authController.connectAppSheet(),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.appColor,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//         ),
//         child: const Text(
//           'Connect App',
//           style: TextStyle(fontSize: 16),
//         ),
//       ),
//     ));
//   }
//
//   Widget _buildAlternativeOptions(AuthController authController) {
//     return Column(
//       children: [
//         const Center(child: Text('OR')),
//         const SizedBox(height: 16),
//         Center(
//           child: TextButton.icon(
//             icon: const Icon(Icons.qr_code_scanner),
//             label: const Text('Scan QR Code'),
//             onPressed: () {
//               // Navigate to QR scanner screen
//               Get.to(() => QrScannerScreen());
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }