import 'package:flutter/material.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Screens/ProfileEdit/profile_edit.dart';
import 'package:lw_app/Screens/Notes/notes.dart';
import 'package:lw_app/Screens/Home/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';

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
        title: const Text('Profiel'),
      ),
      floatingActionButton: const WhatsappContactFAB(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: <Widget>[
            _profileListItem(
              const Icon(Icons.person),
              'My Profiel',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileEditPage()),
                );
              },
            ),
            _profileListItem(
              const Icon(Icons.notes),
              'My Notas',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotesPage()),
                );
              },
            ),
            _profileListItem(
              const Icon(Icons.settings),
              'Instellings',
              () {
                debugPrint('item clicked');
              },
            ),
            _profileListItem(
              const Icon(Icons.logout),
              'Teken Uit',
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
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}