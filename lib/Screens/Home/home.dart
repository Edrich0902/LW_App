import 'package:flutter/material.dart';
import 'package:lw_app/Screens/Auth/login.dart';
import 'package:lw_app/Screens/Dashboard/dashboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Utils/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as SB;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    handleSession();
  }

  Future<void> handleSession() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    SB.Session? session = SB.Supabase.instance.client.auth.currentSession;
    if (session != null) {
      print('session not null');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print(state);
        if (state is AuthSuccessState) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DashPage()),
          );
        } else if (state is AuthErrorState) {
          SnackBarHelper.showErrorSnack(context, 'Login Failed');
        }
      },
      child: const LoginPage(),
    );
  }
}
