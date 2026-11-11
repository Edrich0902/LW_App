import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Brand and specialty icons beyond Material Icons / Cupertino Icons.
///
/// Prefer [LwpIcons] for brand marks used in multiple places so call sites
/// stay package-agnostic. Use Material `Icons.*` for general UI chrome.
/// Render with [FaIcon], not Material [Icon] (FA 11+ uses [FaIconData]).
class LwpIcons {
  LwpIcons._();

  static const FaIconData whatsapp = FontAwesomeIcons.whatsapp;
}
