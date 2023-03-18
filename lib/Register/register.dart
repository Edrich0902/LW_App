import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  bool _isRedirecting = false;
  bool _showPassword = false;
  final _registerFormKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  // late final StreamSubscription<AuthState> _authStateSubscription; //TODO: add with supabase

  Future<void> signUp() async {
    setState(() {
      _isLoading = true;
    });

    print(_emailController.text);
    //TODO: add sign in logic with supabase

    setState(() {
      _isLoading = false;
    });
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
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Form(
            key: _registerFormKey,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              children: [
                Text(
                  "Register",
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
                      {if (_registerFormKey.currentState!.validate()) signUp()},
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                        )
                      : const Text("Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
