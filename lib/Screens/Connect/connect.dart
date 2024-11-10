import 'package:flutter/material.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';
import 'package:lw_app/Widgets/LwpBanner/lwp_banner.dart';
import 'package:lw_app/Screens/ConnectGroups/connect_groups.dart';
import 'package:lw_app/Screens/ServeGroups/serve_groups.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';

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
        title: const Text('Skakel In'),
        actions: const <Widget>[LwpAnnouncementButton(), ProfileActionButton()],
      ),
      floatingActionButton: const WhatsappContactFAB(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LwpBanner(
                imageUrl: 'https://images.unsplash.com/photo-1460518451285-97b6aa326961?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                message: 'Konneksie Groepe',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ConnectGroupsPage()),
                  );
                },
              ),
              const SizedBox(height: 16),
              LwpBanner(
                imageUrl: 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                message: 'Kom Dien',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ServeGroupsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}