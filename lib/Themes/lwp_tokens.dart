import 'package:flutter/widgets.dart';

/// Border radius scale. See docs/ui-consistency-plan.md for usage mapping.
class LwpRadii {
  LwpRadii._();

  /// Bottom-sheet drag handles.
  static const double handle = 2.0;

  /// Small/tight inner elements: compact chips, small action buttons.
  static const double xs = 8.0;

  /// Chips, inner thumbnails, inline note/info containers.
  static const double sm = 12.0;

  /// Hero / larger inner media that fills available width.
  static const double md = 16.0;

  /// Default: cards, sheets, buttons, inputs, dialogs.
  static const double lg = 24.0;

  /// Fully-rounded badges. Prefer [StadiumBorder] where a shape is accepted.
  static const double pill = 999.0;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));

  /// Rounded top only — used by bottom sheets.
  static const BorderRadius lgTop =
      BorderRadius.vertical(top: Radius.circular(lg));
}

/// 8pt-based spacing scale.
class LwpSpacing {
  LwpSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
