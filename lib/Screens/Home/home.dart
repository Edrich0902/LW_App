import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Utils/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

// Screens
import 'package:lw_app/Screens/Auth/login.dart';
import 'package:lw_app/Screens/Container/container.dart';
import 'package:lw_app/Screens/Dashboard/dashboard.dart';

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

    sb.Session? session = sb.Supabase.instance.client.auth.currentSession;
    if (session != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ContainerPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccessState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ContainerPage()),
          );
        } else if (state is UnAuthedState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else if (state is AuthErrorState) {
          SnackBarHelper.showErrorSnack(context, 'Login Failed');
        }
      },
      child: const LoginPage(),
    );
  }
}
