import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:lw_app/Widgets/Glass/lwp_phone_bar.dart';
import 'package:lw_app/Widgets/Glass/lwp_top_bar.dart';

/// Space reserved for floating shell chrome so content can scroll underneath.
class LwpShellInsets {
  LwpShellInsets._();

  static double top(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return pad.top + LwpTopBar.gap + LwpTopBar.capsuleHeight + 6;
  }

  static double bottom(BuildContext context) {
    final mq = MediaQuery.of(context);
    return LwpPhoneBar.dockBottom(mq) + LwpPhoneBar.dockHeight + 8;
  }

  static EdgeInsets paddingOf(BuildContext context) {
    return EdgeInsets.only(top: top(context), bottom: bottom(context));
  }

  /// Scrollable content padding so lists start below chrome but scroll under it.
  static EdgeInsets scrollOf(
    BuildContext context, {
    double horizontal = 16,
    double topExtra = 8,
    double bottom = 16,
  }) {
    return EdgeInsets.fromLTRB(
      horizontal,
      top(context) + topExtra,
      horizontal,
      bottom,
    );
  }

  /// Non-scrolling body inset (loaders / empty / error under floating chrome).
  static EdgeInsets bodyOf(BuildContext context) {
    return EdgeInsets.only(top: top(context));
  }

  static double dockBottom(MediaQueryData mq) =>
      math.max(mq.padding.bottom - 10, 12);
}
