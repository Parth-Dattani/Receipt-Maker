import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_colors.dart';
import '../controller/auth_controller.dart';

/// Wraps the app and listens to Firestore users/{uid}. When isActive == false,
/// shows a non-dismissible "Account Inactive" dialog with a Logout button.
class AccountStatusWrapper extends StatefulWidget {
  const AccountStatusWrapper({super.key, required this.child});

  final Widget? child;

  @override
  State<AccountStatusWrapper> createState() => _AccountStatusWrapperState();
}

class _AccountStatusWrapperState extends State<AccountStatusWrapper> {
  bool _inactiveDialogShown = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return widget.child ?? const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('AccountStatusWrapper Firestore error: ${snapshot.error}');
          return widget.child ?? const SizedBox.shrink();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return widget.child ?? const SizedBox.shrink();
        }
        final data = snapshot.data!.data();
        final isActive = data?['isActive'];
        // Only show dialog when isActive is explicitly false; treat true or missing as active
        final bool inactive = isActive == false;
        final bool active = isActive == true;

        if (inactive && !_inactiveDialogShown) {
          _inactiveDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showAccountInactiveDialog();
          });
        }
        // Close dialog whenever we see isActive == true (cache or server)
        if (active && _inactiveDialogShown) {
          _inactiveDialogShown = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _closeAccountInactiveDialogIfOpen();
          });
        }

        return widget.child ?? const SizedBox.shrink();
      },
    );
  }

  void _showAccountInactiveDialog() {
    final navContext = Get.context;
    if (navContext == null || !navContext.mounted) return;
    final teal = AppColors.tealColor;
    final tealDark = Color.lerp(teal, Colors.black, 0.25) ?? teal;
    showDialog<void>(
      context: navContext,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                color: teal.withOpacity(0.2),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: tealDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Account Inactive',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please contact your administrator:',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          '7383915985',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'info@intelligenttech.in',
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await Get.find<AuthController>().logout();
                },
                style: TextButton.styleFrom(
                  foregroundColor: teal,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Logout'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _closeAccountInactiveDialogIfOpen() {
    final overlayContext = Get.overlayContext;
    if (overlayContext == null || !overlayContext.mounted) return;
    try {
      Navigator.of(overlayContext, rootNavigator: true).pop();
    } catch (_) {
      try {
        Navigator.of(Get.context!, rootNavigator: true).pop();
      } catch (_) {}
    }
  }
}
