import 'package:flutter/material.dart';
import 'package:lw_app/Screens/Auth/register.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:lw_app/Screens/Container/container.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPassword = false;
  final _loginFormKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          LwpSnackbar.showError(context, "Intekening het misluk. Kontroleer asseblief jou besonderhede.");
        }

        if (state is AuthSuccessState) {
          sb.Session? session = sb.Supabase.instance.client.auth.currentSession;
          if (session != null) {
            LwpSnackbar.showSuccess(context, "Intekening suksesvol");

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ContainerPage()),
            );
          }
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Hero(
                tag: 'auth_top_section',
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                      ),
                      child: Image.asset(
                        "assets/icons/icon.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            theme.scaffoldBackgroundColor.withValues(alpha: 0.1),
                            theme.scaffoldBackgroundColor,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: theme.scaffoldBackgroundColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Welkom Terug",
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Teken in om voort te gaan",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (email) {
                            if (email == null || email.isEmpty) {
                              return 'E-pos is verpligtend';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: "E-pos",
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          validator: (password) {
                            if (password == null || password.isEmpty) {
                              return 'Wagwoord is verpligtend';
                            }
                            return null;
                          },
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            labelText: "Wagwoord",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setShowPassword(),
                              icon: Icon(
                                _showPassword ? Icons.visibility : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is AuthLoadingState
                                  ? null
                                  : () {
                                      if (_loginFormKey.currentState!.validate()) {
                                        authBloc.add(
                                          EmailSignInEvent(
                                            _emailController.text,
                                            _passwordController.text,
                                          ),
                                        );
                                      }
                                    },
                              child: state is AuthLoadingState
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text("Teken In"),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          ),
                          child: const Text("Het jy nie 'n rekening nie? Registreer hier"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
