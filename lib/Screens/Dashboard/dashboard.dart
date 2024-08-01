import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Screens/Auth/login.dart';
import 'package:lw_app/Utils/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:lw_app/Screens/Sermons/sermons.dart';
import 'package:lw_app/Screens/Events/events.dart';

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
          title: Text('Dashboard'),
        ),
        body: Padding(
          padding: EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _createDashCard(
                  context,
                  "Upcoming Events",
                  "https://images.unsplash.com/photo-1486591978090-58e619d37fe7?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EventsPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _createDashCard(
                  context,
                  "Recent Sermons",
                  "https://images.unsplash.com/photo-1673322880779-9c257a0cae44?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SermonsPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _createDashCard(
                  context,
                  "Tithes & Offerings",
                  "https://images.unsplash.com/photo-1673042872287-a77ef03317a4?q=80&w=2008&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  () {
                    print('Card clicked'); // TODO: navigate to Tithes & Offerings
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createDashCard(
    BuildContext context,
    String text,
    String imagePath,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: 200.00,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imagePath),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.center,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white, // hard coded to white regardless of theme to better display on background
                  letterSpacing: 3.0,
                  shadows: <Shadow>[
                    Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: Color.fromARGB(255, 0, 0, 0)),
                    Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: Color.fromARGB(255, 0, 0, 0)),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
