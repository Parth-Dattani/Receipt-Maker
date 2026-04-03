import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackbar({
  required String title,
  required String message,
  required Color baseColor,
  Color? titleTextColor,
  Color? messageTextColor,
  IconData? icon = Icons.check_circle_outline,
  Duration duration = const Duration(seconds: 3),
  SnackPosition position = SnackPosition.TOP,
}) {
  if (Get.context == null) return;

  // Generate gradient from single color
  List<Color> gradientColors = [
    baseColor,
    baseColor.withOpacity(0.6), // Lighter shade for gradient effect
  ];

  // Calculate contrasting color if not provided
  Color getContrastColor(Color base) {
    // Calculate luminance to determine if baseColor is light or dark
    double luminance = (0.299 * base.red + 0.587 * base.green + 0.114 * base.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  final effectiveTitleTextColor = titleTextColor ?? getContrastColor(baseColor);
  final effectiveMessageTextColor = messageTextColor ?? getContrastColor(baseColor);

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
}

// Example usage:
// showCustomSnackbar(
//   title: "Success!",
//   message: "Item saved to AppSheet successfully.",
//   baseColor: Colors.green.shade700,
//   titleTextColor: Colors.white, // Optional
//   messageTextColor: Colors.white70, // Optional
//   icon: Icons.check_circle_outline,
// );