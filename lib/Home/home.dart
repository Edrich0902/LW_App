import 'package:flutter/material.dart';
import 'package:lw_app/Login/login.dart';

//TODO: check user session and either route to login or dashboard

//TODO: setup Supabase

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _redirectCalled = false;
  final session = null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (_redirectCalled || !mounted) return;

    _redirectCalled = true;
    if (session == null) {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
