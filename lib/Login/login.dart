import 'package:flutter/material.dart';
import 'package:lw_app/Register/register.dart';
import 'package:lw_app/Dashboard/dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _isRedirecting = false;
  bool _showPassword = false;
  final _loginFormKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  // late final StreamSubscription<AuthState> _authStateSubscription; //TODO: add with supabase

  Future<void> signIn() async {
    setState(() {
      _isLoading = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DashPage()),
    );

    setState(() {
      _isLoading = false;
      // Clear field values
      _emailController.text = "";
      _passwordController.text = "";
    });
    //TODO: add sign in logic with supabase
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    //TODO: Set auth state subscription

    if (_isRedirecting) return;

    super.initState();
  }

  void setShowPassword() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    // TODO: dispose subscription here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Form(
            key: _loginFormKey,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Image.network(
                    "https://yt3.googleusercontent.com/ytc/AL5GRJUbsh7ILjzuEQAZTot_kkV2GohZR75CjoWM9NSI9Q=s900-c-k-c0x00ffffff-no-rj",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Sign In",
                  style: theme.textTheme.headline4,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  validator: (email) {
                    if (email == null || email.isEmpty)
                      return 'Email is required';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Email",
                    suffixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  validator: (password) {
                    if (password == null || password.isEmpty)
                      return 'Password is required';
                    if (password.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  },
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                      labelText: "Password",
                      suffixIcon: IconButton(
                          onPressed: () => setShowPassword(),
                          icon: Icon(_showPassword
                              ? Icons.visibility
                              : Icons.visibility_off))),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      {if (_loginFormKey.currentState!.validate()) signIn()},
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                        )
                      : const Text("Sign In"),
                ),
                const SizedBox(height: 4),
                TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage())),
                    child: const Text("Don't have an account? Register Here")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
