import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as SB;
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Screens/Profile/profile.dart';
import 'package:lw_app/Screens/Dashboard/dashboard.dart';
import 'package:lw_app/Blocs/User/user_bloc.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  SB.User? user = SB.Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    context.read<UserBloc>().add(LoadUser());
    super.initState();
  }

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
        child: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
          if (state is UserLoading) {
            return CircularProgressIndicator.adaptive();
          } else if (state is UserSuccess) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 45,
                  //TODO: update with actual user image and add placeholder
                  backgroundImage: NetworkImage(
                      "https://yt3.googleusercontent.com/ytc/AL5GRJUbsh7ILjzuEQAZTot_kkV2GohZR75CjoWM9NSI9Q=s900-c-k-c0x00ffffff-no-rj"),
                ),
                SizedBox(height: 8),
                Text("${state.user.firstName} ${state.user.lastName}" ?? ""),
                SizedBox(height: 8),
                Text(
                  user?.email ?? "",
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            );
          } else {
            return Text('Could not load Profile');
          }
        }),
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
