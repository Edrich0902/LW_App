import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as SB;
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Screens/Profile/profile.dart';
import 'package:lw_app/Screens/Dashboard/dashboard.dart';

class AppDrawer extends StatelessWidget {
  SB.User? user = SB.Supabase.instance.client.auth.currentUser;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(
            theme: theme,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          _createDrawerItem(
            theme: theme,
            label: 'Home',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashPage()),
              );
            },
          ),
          _createDrawerItem(theme: theme, label: 'Communities'),
          _createDrawerItem(theme: theme, label: 'My Bible'),
          Divider(),
          _createDrawerItem(
            theme: theme,
            label: 'Sign Out',
            onTap: () {
              authBloc.add(SignOutEvent());
            },
          ),
          // _createFooter(), //TODO: add footer item later
        ],
      ),
    );
  }

  Widget _createHeader({required ThemeData theme, GestureTapCallback? onTap}) {
    return DrawerHeader(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24.0),
        ),
        color: theme.primaryColor,
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              //TODO: update with actual user image and add placeholder
              backgroundImage: NetworkImage(
                  "https://yt3.googleusercontent.com/ytc/AL5GRJUbsh7ILjzuEQAZTot_kkV2GohZR75CjoWM9NSI9Q=s900-c-k-c0x00ffffff-no-rj"),
            ),
            SizedBox(height: 8),
            Text(user?.email ?? ""),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem({
    required ThemeData theme,
    required String label,
    GestureTapCallback? onTap,
  }) {
    return ListTile(title: Text(label), onTap: onTap);
  }
}
