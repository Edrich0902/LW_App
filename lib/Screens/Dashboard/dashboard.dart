import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Screens/Auth/login.dart';
import 'package:lw_app/Utils/environment.dart';
import 'package:lw_app/Utils/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as SB;

class DashPage extends StatelessWidget {
  const DashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);

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
              ListTile(
                  title: const Text("Sign Out"),
                  onTap: () {
                    authBloc.add(SignOutEvent());
                  }),
            ],
          ),
        ),
        body: Center(
          child: Text(
            SB.Supabase.instance.client.auth.currentUser?.email ?? "No email",
          ),
        ),
      ),
    );
  }
}
