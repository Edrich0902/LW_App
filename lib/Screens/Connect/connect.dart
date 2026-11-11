import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Screens/ConnectGroups/connect_groups.dart';
import 'package:lw_app/Screens/ServeGroups/serve_groups.dart';
import 'package:lw_app/Widgets/Connect/connect_hero.dart';
import 'package:lw_app/Widgets/Dashboard/dashboard_grid_card.dart';
import 'package:lw_app/Widgets/Glass/lwp_shell_insets.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          LwpShellInsets.top(context) + 8,
          16,
          LwpShellInsets.bottom(context) + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const ConnectHero(),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                DashboardGridCard(
                  title: context.l10n.connectGroupsTitle,
                  icon: Icon(Icons.people),
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
                  icon: Icon(Icons.volunteer_activism),
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
