import 'package:flutter/material.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Screens/ProfileEdit/profile_edit.dart';
import 'package:lw_app/Screens/Notes/notes.dart';
import 'package:lw_app/Screens/Home/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: <Widget>[
            _profileListItem(
              Icon(Icons.person),
              'My Profile',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileEditPage()),
                );
              },
            ),
            _profileListItem(
              Icon(Icons.notes),
              'My Notes',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotesPage()),
                );
              },
            ),
            _profileListItem(
              Icon(Icons.settings),
              'Settings',
              () {
                print('item clicked');
              },
            ),
            _profileListItem(
              Icon(Icons.logout),
              'Sign Out',
              () {
                authBloc.add(const SignOutEvent());
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileListItem(Icon icon, String text, GestureTapCallback onTap) {
    return Card(
      child: ListTile(
        leading: icon,
        title: Text(text),
        trailing: Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}