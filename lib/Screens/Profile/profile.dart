import 'package:flutter/material.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Blocs/User/user_bloc.dart';
import 'package:lw_app/Screens/ProfileEdit/profile_edit.dart';
import 'package:lw_app/Screens/Notes/notes.dart';
import 'package:lw_app/Screens/Home/home.dart';
import 'package:lw_app/Screens/PrayerRequests/my_prayer_requests.dart';
import 'package:lw_app/Screens/Settings/settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';
import 'package:lw_app/Widgets/LwpProfileImage/lwp_profile_image.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final userBloc = context.read<UserBloc>();
    if (userBloc.state is UserInitial) {
      userBloc.add(LoadUser());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiel'),
      ),
      floatingActionButton: const WhatsappContactFAB(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildHeroSection(),
              const SizedBox(height: 32),
              _buildMenuSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading || state is UserInitial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: LwpLoader(message: 'Laai profiel...'),
          );
        }

        if (state is UserError) {
          return LwpError(
            message: 'Kon nie profiel laai nie.',
            onRetry: () => context.read<UserBloc>().add(LoadUser()),
          );
        }

        String fullName = 'Gebruiker';
        String publicId = '';
        String? role;

        if (state is UserSuccess) {
          fullName = '${state.user.firstName} ${state.user.lastName}';
          publicId = state.user.profilePublicId ?? '';
          role = state.user.role;
        }

        return Column(
          children: [
            LwpProfileImage(
              publicId: publicId,
              height: 120,
              radius: 60,
            ),
            const SizedBox(height: 16),
            Text(
              fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (role != null && role.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _formatRole(role),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatRole(String role) {
    // Convert snake_case to human readable (e.g., super_admin -> Super Admin)
    return role.split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'My Profiel',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileEditPage()),
                );
              },
            ),
            const Divider(height: 1, indent: 56),
            _buildMenuItem(
              icon: Icons.notes_outlined,
              title: 'My Notas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotesPage()),
                );
              },
            ),
            const Divider(height: 1, indent: 56),
            _buildMenuItem(
              icon: Icons.favorite_outline,
              title: 'My Gebedsversoeke',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyPrayerRequestsPage(),
                  ),
                );
              },
            ),
            const Divider(height: 1, indent: 56),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Instellings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            const Divider(height: 1, indent: 56),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Teken Uit',
              titleColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Teken Uit'),
                      content: const Text('Is u seker u wil uitteken?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Kanseleer'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<AuthBloc>().add(const SignOutEvent());
                            context.read<UserBloc>().add(const ResetUser());
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()),
                            );
                          },
                          child: const Text(
                            'Teken Uit',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
