import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:lw_app/Themes/custom_theme.dart';

enum LwpSnackbarType { success, error, info, warning }

class LwpSnackbar {
  LwpSnackbar._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, LwpSnackbarType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, LwpSnackbarType.error);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, LwpSnackbarType.info);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, LwpSnackbarType.warning);
  }

  static void _show(BuildContext context, String message, LwpSnackbarType type) {
    AnimatedSnackBar(
      builder: (context) {
        return _LwpSnackbarWidget(
          message: message,
          type: type,
        );
      },
      duration: const Duration(seconds: 4),
      mobileSnackBarPosition: MobileSnackBarPosition.bottom,
    ).show(context);
  }
}

class _LwpSnackbarWidget extends StatelessWidget {
  final String message;
  final LwpSnackbarType type;

  const _LwpSnackbarWidget({
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Resolve Background Color
    Color backgroundColor;
    Color textColor;
    Color iconColor;

    if (isDarkMode) {
      // Dark Mode Branding: Gold background, Black text
      backgroundColor = DarkColors.primary;
      textColor = Colors.black;
      iconColor = Colors.black;
    } else {
      // Light Mode Branding: Deep Black background, White text
      backgroundColor = LightColors.primary;
      textColor = Colors.white;
      iconColor = Colors.white;
    }

    // Adjust for Error Type specifically to provide clear feedback
    if (type == LwpSnackbarType.error) {
      backgroundColor = Colors.redAccent.shade700;
      textColor = Colors.white;
      iconColor = Colors.white;
    }

    IconData iconData;
    switch (type) {
      case LwpSnackbarType.success:
        iconData = Icons.check_circle_outline;
        break;
      case LwpSnackbarType.error:
        iconData = Icons.error_outline;
        break;
      case LwpSnackbarType.info:
        iconData = Icons.info_outline;
        break;
      case LwpSnackbarType.warning:
        iconData = Icons.warning_amber_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: iconColor),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
