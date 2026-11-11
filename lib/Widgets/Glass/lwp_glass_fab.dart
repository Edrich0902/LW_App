import 'package:flutter/material.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Widgets/Glass/lwp_glass.dart';

/// Floating action control with the same frost as shell chrome.
class LwpGlassFab extends StatelessWidget {
  const LwpGlassFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.heroTag,
    this.size = 56,
  }) : icon = null,
       label = null,
       extended = false;

  const LwpGlassFab.extended({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.tooltip,
    this.heroTag,
  }) : child = null,
       size = 56,
       extended = true;

  final VoidCallback? onPressed;
  final Widget? child;
  final Widget? icon;
  final Widget? label;
  final String? tooltip;
  final Object? heroTag;
  final double size;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? Colors.white : LightColors.primary;
    final enabled = onPressed != null;
    final color = enabled ? ink : theme.disabledColor;

    final Widget body;
    if (extended) {
      body = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(color: color, size: 22),
              child: icon!,
            ),
            const SizedBox(width: 10),
            DefaultTextStyle(
              style: theme.textTheme.labelLarge!.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              child: label!,
            ),
          ],
        ),
      );
    } else {
      body = Center(
        child: IconTheme(
          data: IconThemeData(color: color, size: 24),
          child: child!,
        ),
      );
    }

    Widget fab = LwpGlass(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: extended
              ? SizedBox(height: size, child: body)
              : SizedBox(width: size, height: size, child: body),
        ),
      ),
    );

    if (heroTag != null) {
      fab = Hero(tag: heroTag!, child: fab);
    }
    if (tooltip != null) {
      fab = Tooltip(message: tooltip!, child: fab);
    }
    return fab;
  }
}
