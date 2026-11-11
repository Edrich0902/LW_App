import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lw_app/Themes/lwp_icons.dart';
import 'package:lw_app/Widgets/Glass/lwp_glass_fab.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappContactFAB extends StatelessWidget {
  const WhatsappContactFAB({super.key});

  static const String _url = 'https://wa.me/';
  static const String _number = '+27727238406';

  @override
  Widget build(BuildContext context) {
    return LwpGlassFab(
      heroTag: 'whatsapp-contact-fab',
      onPressed: () {
        launchUrl(
          Uri.parse('$_url$_number'),
          mode: LaunchMode.externalApplication,
        );
      },
      child: const FaIcon(LwpIcons.whatsapp, size: 22),
    );
  }
}
