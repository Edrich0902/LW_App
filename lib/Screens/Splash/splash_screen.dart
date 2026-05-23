import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Screens/Container/container.dart';
import 'package:lw_app/Screens/Home/home.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';

class LwpSplashScreen extends StatefulWidget {
  const LwpSplashScreen({super.key});

  @override
  State<LwpSplashScreen> createState() => _LwpSplashScreenState();
}

class _LwpSplashScreenState extends State<LwpSplashScreen> {
  late final StreamSubscription<AuthState> _authSubscription;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted || _hasNavigated) return;
      
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _hasNavigated = true;
        _authSubscription.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ContainerPage()),
        );
      }
    });
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    _authSubscription.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Top Section (Hero) - Follows the 2:3 ratio standard
          // We wrap the entire Stack in the Hero widget to match the LoginPage structure
          // This ensures a seamless transition without the "briefly appear" glitch
          Expanded(
            flex: 2,
            child: Hero(
              tag: 'auth_top_section',
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [theme.cardTheme.color!, theme.cardTheme.color!.withValues(alpha: 0.8)]
                            : [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Image.asset(
                      "assets/icons/icon.png",
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Gradient Overlay for seamless transition into the bottom section
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.7, 1.0],
                        colors: [
                          Colors.transparent,
                          theme.scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Section - Loading indicator and message
          const Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LwpLoader(message: "Welkom"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
