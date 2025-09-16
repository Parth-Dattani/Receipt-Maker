// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
//
// import '../constant/app_colors.dart';
// import '../controller/controller.dart';
//
// class QrScannerScreen extends StatefulWidget {
//   @override
//   _QrScannerScreenState createState() => _QrScannerScreenState();
// }
//
// class _QrScannerScreenState extends State<QrScannerScreen> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//   final AuthController _authController = Get.find<AuthController>();
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan QR Code'),
//         backgroundColor: AppColors.appColor,
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             flex: 5,
//             child: QRView(
//               key: qrKey,
//               onQRViewCreated: _onQRViewCreated,
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Center(
//               child: Text('Scan your AppSheet QR code'),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       controller.pauseCamera();
//       final String? url = scanData.code;
//       if (url != null) {
//         _authController.appSheetUrlController.text = url;
//         Get.back();
//         _authController.connectAppSheet();
//       }
//     });
//   }
// }