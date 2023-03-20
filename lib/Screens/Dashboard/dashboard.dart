import 'package:flutter/material.dart';
import 'package:lw_app/Utils/environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashPage extends StatelessWidget {
  const DashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24.0),
                ),
                color: theme.primaryColor,
              ),
              child: Text('Header'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
            Supabase.instance.client.auth.currentUser?.email ?? "No email"),
      ),
    );
  }
}
