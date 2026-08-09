import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Brand and specialty icons beyond Material Icons / Cupertino Icons.
///
/// Prefer [LwpIcons] for brand marks used in multiple places so call sites
/// stay package-agnostic. Use Material `Icons.*` for general UI chrome.
/// For one-off specialty glyphs, `FontAwesomeIcons` may be used directly.
class LwpIcons {
  LwpIcons._();

  static const IconData whatsapp = FontAwesomeIcons.whatsapp;
}
