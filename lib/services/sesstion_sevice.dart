// import 'dart:io';
//
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:math';
//
// class SessionService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//
//   // Get device ID (using device-specific info)
//   Future<String> _getDeviceId() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? deviceId = prefs.getString('deviceId');
//
//     if (deviceId == null) {
//       if (Platform.isAndroid) {
//         final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//         deviceId = androidInfo.id;
//       } else if (Platform.isIOS) {
//         final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//         deviceId = iosInfo.identifierForVendor;
//       } else {
//         // Fallback: generate a random ID
//         const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
//         final random = Random.secure();
//         deviceId = List.generate(32, (index) => chars[random.nextInt(chars.length)]).join();
//       }
//
//       await prefs.setString('deviceId', deviceId!);
//     }
//
//     return deviceId;
//   }
//
//   // Validate session on app start
//   Future<bool> validateSession() async {
//     final user = _auth.currentUser;
//     if (user == null) return false;
//
//     final deviceId = await _getDeviceId();
//     final sessionDoc = await _firestore.collection('user_sessions').doc(user.uid).get();
//
//     if (!sessionDoc.exists) {
//       await _auth.signOut();
//       return false;
//     }
//
//     final sessionData = sessionDoc.data() as Map<String, dynamic>;
//     final storedDeviceId = sessionData['deviceId'];
//
//     if (storedDeviceId != deviceId) {
//       await _auth.signOut();
//       return false;
//     }
//
//     // Update last active time
//     await _firestore.collection('user_sessions').doc(user.uid).update({
//       'lastActive': FieldValue.serverTimestamp(),
//     });
//
//     return true;
//   }
//
//   // Create new session after login
//   Future<void> createNewSession() async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     final deviceId = await _getDeviceId();
//
//     await _firestore.collection('user_sessions').doc(user.uid).set({
//       'deviceId': deviceId,
//       'lastActive': FieldValue.serverTimestamp(),
//       'createdAt': FieldValue.serverTimestamp(),
//       'userId': user.uid,
//     });
//   }
//
//   // Clear session on logout
//   Future<void> clearSession() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       await _firestore.collection('user_sessions').doc(user.uid).delete();
//     }
//   }
// }