import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shows a styled snackbar on the next frame.
///
/// Uses [ScaffoldMessenger] when possible (avoids "No Overlay widget found" when
/// [Get.context] points at a subtree without an overlay). Only uses GetX snack
/// APIs when a root [Overlay] exists; otherwise logs to console.
void showCustomSnackbar({
  required String title,
  required String message,
  required Color baseColor,
  Color? titleTextColor,
  Color? messageTextColor,
  IconData? icon = Icons.check_circle_outline,
  Duration duration = const Duration(seconds: 3),
  SnackPosition position = SnackPosition.TOP,
  /// When non-null (e.g. [showDialog] builder context), tried first so the snack
  /// attaches to the correct [ScaffoldMessenger] above overlays like dialogs.
  BuildContext? anchorContext,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _presentCustomSnackbar(
      title: title,
      message: message,
      baseColor: baseColor,
      titleTextColor: titleTextColor,
      messageTextColor: messageTextColor,
      icon: icon,
      duration: duration,
      position: position,
      anchorContext: anchorContext,
    );
  });
}

void _presentCustomSnackbar({
  required String title,
  required String message,
  required Color baseColor,
  Color? titleTextColor,
  Color? messageTextColor,
  IconData? icon,
  required Duration duration,
  required SnackPosition position,
  BuildContext? anchorContext,
}) {
  List<Color> gradientColors = [
    baseColor,
    baseColor.withOpacity(0.6),
  ];

  Color getContrastColor(Color base) {
    double luminance =
        (0.299 * base.red + 0.587 * base.green + 0.114 * base.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  final effectiveTitleTextColor = titleTextColor ?? getContrastColor(baseColor);
  final effectiveMessageTextColor =
      messageTextColor ?? getContrastColor(baseColor);

  bool tryMaterialSnackBar(BuildContext ctx) {
    if (!ctx.mounted) return false;
    final messenger = ScaffoldMessenger.maybeOf(ctx);
    if (messenger == null) return false;

    final size = MediaQuery.sizeOf(ctx);
    final pad = MediaQuery.paddingOf(ctx);
    final EdgeInsets margin = position == SnackPosition.TOP
        ? EdgeInsets.fromLTRB(16, pad.top + 8, 16, size.height * 0.55)
        : EdgeInsets.fromLTRB(16, size.height * 0.55, 16, pad.bottom + 16);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: effectiveTitleTextColor, size: 28),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty) ...[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: effectiveTitleTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: effectiveMessageTextColor.withOpacity(0.92),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: baseColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: margin,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
    return true;
  }

  // Try several contexts: dialog/local first, then navigator key, overlay (GetX).
  final contextsToTry = <BuildContext?>[
    anchorContext,
    Get.key.currentContext,
    Get.context,
    Get.overlayContext,
  ];
  for (final c in contextsToTry) {
    if (c != null && tryMaterialSnackBar(c)) {
      return;
    }
  }

  final BuildContext? rootCtx =
      Get.key.currentContext ?? Get.overlayContext ?? Get.context;

  if (rootCtx != null &&
      rootCtx.mounted &&
      Overlay.maybeOf(rootCtx, rootOverlay: true) != null) {
    try {
      Get.showSnackbar(
        GetSnackBar(
          titleText: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: effectiveTitleTextColor,
            ),
          ),
          messageText: Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: effectiveMessageTextColor.withOpacity(0.7),
            ),
          ),
          duration: duration,
          snackPosition: position,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundGradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icon(
            icon,
            color: effectiveTitleTextColor,
            size: 28,
          ),
          shouldIconPulse: true,
          animationDuration: const Duration(milliseconds: 400),
          boxShadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          borderWidth: 1,
          borderColor: Colors.white.withOpacity(0.1),
          mainButton: TextButton(
            onPressed: () => Get.closeCurrentSnackbar(),
            child: Text(
              "Dismiss",
              style: TextStyle(
                color: effectiveTitleTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
      return;
    } catch (_) {
      // Try one more frame (e.g. mid-route transition).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx2 = Get.key.currentContext;
        if (ctx2 != null && tryMaterialSnackBar(ctx2)) return;
        debugPrint('[showCustomSnackbar] $title — $message');
      });
      return;
    }
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx2 = Get.key.currentContext;
    if (ctx2 != null && tryMaterialSnackBar(ctx2)) return;
    debugPrint('[showCustomSnackbar] $title — $message');
  });
}
