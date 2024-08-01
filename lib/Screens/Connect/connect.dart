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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konnek'),
        actions: <Widget>[ProfileActionButton()],
      ),
      floatingActionButton: WhatsappContactFAB(),
      body: SafeArea(
        child: Center(
          child: Text('Konnek page'),
        ),
      ),
    );
  }

  Widget _createConnectCard(
      BuildContext context,
      String text,
      String imagePath,
      VoidCallback onTap,
      ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: 200.00,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imagePath),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.center,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white, // hard coded to white regardless of theme to better display on background
                  letterSpacing: 3.0,
                  shadows: <Shadow>[
                    Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: Color.fromARGB(255, 0, 0, 0)),
                    Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: Color.fromARGB(255, 0, 0, 0)),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}