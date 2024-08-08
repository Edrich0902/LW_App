import 'package:flutter/material.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  @override
  void initState() {
    super.initState();
  }

  // TODO: complete this screen with dummy content
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Skakel In'),
        actions: <Widget>[ProfileActionButton()],
      ),
      floatingActionButton: WhatsappContactFAB(),
      body: SafeArea(
        child: Center(
          child: Text('Skakel in page'),
        ),
      ),
    );
  }
}