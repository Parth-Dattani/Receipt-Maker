import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/controller.dart';
import 'web_app_sidebar.dart';
import 'package:GetYourInvoice/screen/screen.dart';

/// On web, wraps [child] with the shared left sidebar so the drawer is always visible.
/// [currentRoute] is passed to the sidebar to highlight the active menu item.
/// [child] is typically the full screen (e.g. Scaffold with appBar and body).
/// Skips the sidebar for routes that don't have DashboardController (e.g. after login → Company Registration).
Widget webScreenWrapper({
  required Widget child,
  required String currentRoute,
}) {
  if (!kIsWeb) return child;

  // Routes that use their own binding and don't have DashboardController — show content only (no sidebar).
  final noSidebarRoutes = [
    AuthScreen.pageId,
  ];
  if (noSidebarRoutes.contains(currentRoute)) {
    return child;
  }

  // ✅ CompanyRegistration: Only show sidebar in Edit mode
  if (currentRoute == CompanyRegistrationScreen.pageId) {
    if (Get.isRegistered<CompanyController>()) {
      final ctrl = Get.find<CompanyController>();
      if (!ctrl.isEditMode.value) return child; // Registration: no sidebar
    } else {
      return child;
    }
  }

  // Material at root so all InkWell/ink widgets in sidebar and content have an ancestor.
  // SizedBox.expand gives the Row full height so the sidebar ListView shows the full menu.
  return Material(
    type: MaterialType.transparency,
    child: SizedBox.expand(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WebAppSidebar(currentRoute: currentRoute),
          Expanded(child: child),
        ],
      ),
    ),
  );
}
