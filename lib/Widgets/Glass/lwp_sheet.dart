import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Widgets/LwpBottomSheet/lwp_bottom_sheet.dart';

/// Solid inset bottom sheet with grab handle and optional title.
Future<T?> showLwpSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
  bool expand = false,
}) {
  unawaited(HapticFeedback.lightImpact());
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: Colors.black.withValues(alpha: 0.34),
    builder: (context) {
      final mq = MediaQuery.of(context);
      final theme = Theme.of(context);
      final keyboard = mq.viewInsets.bottom;
      final lift = keyboard > 0 ? keyboard + _gap : _gap;
      final isDark = theme.brightness == Brightness.dark;
      final ink = isDark ? Colors.white : LightColors.primary;

      final content = Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          10,
          18,
          keyboard > 0 ? 18 : math.max(mq.padding.bottom - _gap, 0) + 14,
        ),
        child: Column(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: LwpSheetHandle()),
            const SizedBox(height: 14),
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
              ),
            if (expand)
              Expanded(child: builder(context))
            else
              Flexible(child: builder(context)),
          ],
        ),
      );

      return Padding(
        padding: EdgeInsets.fromLTRB(_gap, 0, _gap, lift),
        child: Material(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(_radius),
          clipBehavior: Clip.antiAlias,
          child: expand
              ? SizedBox(
                  height: math.max(mq.size.height * 0.88 - lift, 0),
                  child: content,
                )
              : content,
        ),
      );
    },
  );
}

const _gap = 8.0;
const _radius = 34.0;
