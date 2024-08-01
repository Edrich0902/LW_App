import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappContactFAB extends StatefulWidget {
  const WhatsappContactFAB({super.key});

  @override
  State<WhatsappContactFAB> createState() => _WhatsappContactFABState();
}

class _WhatsappContactFABState extends State<WhatsappContactFAB> {
  final String url = "https://wa.me/";
  final String number = "+27727238406";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.whatsapp),
      onPressed: () {
        String link = url + number;
        launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
      },
    );
  }
}