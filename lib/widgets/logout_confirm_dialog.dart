import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Branded logout confirmation — teal accent, clear primary/secondary actions.
class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({
    super.key,
    required this.onConfirm,
    this.title,
    this.message,
    this.cancelLabel,
    this.confirmLabel,
  });

  final Future<void> Function() onConfirm;

  /// Defaults to [confirm_logout].tr
  final String? title;

  /// Defaults to [logout_message].tr
  final String? message;

  /// Defaults to [cancel].tr
  final String? cancelLabel;

  /// Defaults to [logout].tr
  final String? confirmLabel;

  static const Color _brandTeal = Color(0xFF00897B);
  static const Color _logoutRed = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = title ?? 'confirm_logout'.tr;
    final m = message ?? 'logout_message'.tr;
    final cancel = cancelLabel ?? 'cancel'.tr;
    final confirm = confirmLabel ?? 'logout'.tr;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _brandTeal.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 40,
                  color: _brandTeal,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                t,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                m,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _brandTeal,
                        side: BorderSide(color: _brandTeal.withValues(alpha: 0.45)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        cancel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _logoutRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        confirm,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
