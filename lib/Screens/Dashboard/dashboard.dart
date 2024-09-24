import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Screens/Auth/login.dart';
import 'package:lw_app/Utils/snackbar.dart';
import 'package:lw_app/Screens/Sermons/sermons.dart';
import 'package:lw_app/Screens/UpcomingEvents/upcoming_events.dart';
import 'package:lw_app/Screens/SocialMedia/social_media.dart';
import 'package:lw_app/Screens/Courses/courses.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/LwpBanner/lwp_banner.dart';

class DashPage extends StatelessWidget {
  const DashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UnAuthedState) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        } else if (state is AuthErrorState) {
          SnackBarHelper.showErrorSnack(context, 'Error, could not Sign Out');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tuis'),
          actions: const <Widget>[ProfileActionButton()],
        ),
        floatingActionButton: const WhatsappContactFAB(),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LwpBanner(
                  imageUrl: "https://images.unsplash.com/photo-1673322880779-9c257a0cae44?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  message: "Preke",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SermonsPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                LwpBanner(
                  imageUrl: "https://images.unsplash.com/photo-1486591978090-58e619d37fe7?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  message: "Opkomende Gebeure",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UpcomingEventsPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                LwpBanner(
                  imageUrl: "https://images.unsplash.com/photo-1673042872287-a77ef03317a4?q=80&w=2008&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  message: "Tiendes & Offergawes",
                  onTap: () {
                    print('Card clicked'); // TODO: navigate to Tithes & Offerings
                  },
                ),
                const SizedBox(height: 16),
                LwpBanner(
                  imageUrl: "https://images.unsplash.com/photo-1519491050282-cf00c82424b4?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  message: "Eerste Keer Besoeker",
                  onTap: () {
                    print('Card clicked'); // TODO: navigate to Tithes & Offerings
                  },
                ),
                const SizedBox(height: 16),
                LwpBanner(
                  imageUrl: "https://images.unsplash.com/photo-1564177611049-76e2933c6017?q=80&w=1364&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  message: "Volg Ons",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SocialMediaPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                LwpBanner(
                  imageUrl: "https://images.unsplash.com/photo-1492052722242-2554d0e99e3a?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  message: "Kursusse",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CoursesPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
