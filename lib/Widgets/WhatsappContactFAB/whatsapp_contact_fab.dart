import 'package:flutter/material.dart';
import 'package:lw_app/Themes/lwp_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappContactFAB extends StatelessWidget {
  const WhatsappContactFAB({super.key});

  static const String _url = 'https://wa.me/';
  static const String _number = '+27727238406';

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        launchUrl(
          Uri.parse('$_url$_number'),
          mode: LaunchMode.externalApplication,
        );
      },
      child: const Icon(LwpIcons.whatsapp),
    );
  }
}
