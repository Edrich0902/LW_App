import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

// Screens
import 'package:lw_app/Screens/Auth/login.dart';
import 'package:lw_app/Screens/Container/container.dart';

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
    return const LoginPage();
  }
}
