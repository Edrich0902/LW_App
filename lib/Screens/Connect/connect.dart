import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Screens/ConnectGroups/connect_groups.dart';
import 'package:lw_app/Screens/ServeGroups/serve_groups.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';
import 'package:lw_app/Widgets/Connect/connect_hero.dart';
import 'package:lw_app/Widgets/Dashboard/dashboard_grid_card.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.navConnect),
        actions: const <Widget>[LwpAnnouncementButton(), ProfileActionButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const ConnectHero(),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                DashboardGridCard(
                  title: context.l10n.connectGroupsTitle,
                  icon: Icons.people,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ConnectGroupsPage()),
                    );
                  },
                ),
                DashboardGridCard(
                  title: context.l10n.serveGroupsTitle,
                  icon: Icons.volunteer_activism,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ServeGroupsPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
