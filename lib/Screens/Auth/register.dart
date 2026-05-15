import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Screens/Container/container.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _currentStep = 0;
  bool _showPassword = false;
  final _registerFormKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    super.initState();
  }

  void setShowPassword() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_registerFormKey.currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() {
          _currentStep++;
        });
      } else {
        _submitRegistration();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitRegistration() {
    if (_imageFile == null) {
      LwpSnackbar.showWarning(context, "Kies asseblief 'n profiel foto");
      return;
    }

    context.read<AuthBloc>().add(
          EmailSignUpEvent(
            email: _emailController.text,
            password: _passwordController.text,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            imageFile: _imageFile,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          LwpSnackbar.showError(context, "Registrasie het misluk. Probeer asseblief weer.");
        }

        if (state is AuthSuccessState) {
          sb.Session? session = sb.Supabase.instance.client.auth.currentSession;
          if (session != null) {
            LwpSnackbar.showSuccess(context, "Registrasie suksesvol");

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ContainerPage()),
              (route) => false,
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
                        "assets/icons/icon.jpg",
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
                    key: _registerFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getStepTitle(),
                                    style: theme.textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getStepSubtitle(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_currentStep == 0)
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close,
                                  color: theme.primaryColor,
                                  size: 28,
                                ),
                                tooltip: "Terug na Intekening",
                              )
                            else
                              IconButton(
                                onPressed: _previousStep,
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: theme.primaryColor,
                                  size: 28,
                                ),
                                tooltip: "Vorige Stap",
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildStepContent(),
                        const SizedBox(height: 32),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is AuthLoadingState ? null : _nextStep,
                              child: state is AuthLoadingState
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(_currentStep < 2 ? "Volgende" : "Registreer"),
                            );
                          },
                        ),
                        if (_currentStep == 0) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Het jy reeds 'n rekening? Teken hier in"),
                          ),
                        ],
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

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return "Skep Rekening";
      case 1:
        return "Jou Besonderhede";
      case 2:
        return "Profiel Foto";
      default:
        return "";
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return "Stap 1 van 3: Toegang";
      case 1:
        return "Stap 2 van 3: Persoonlik";
      case 2:
        return "Stap 3 van 3: Identiteit";
      default:
        return "";
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCredentialsStep();
      case 1:
        return _buildProfileDetailsStep();
      case 2:
        return _buildProfilePictureStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCredentialsStep() {
    return Column(
      children: [
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
            if (password.length < 6) {
              return 'Wagwoord moet ten minste 6 karakters wees';
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
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Bevestig asseblief jou wagwoord';
            }
            if (value != _passwordController.text) {
              return 'Wagwoorde stem nie ooreen nie';
            }
            return null;
          },
          obscureText: !_showPassword,
          decoration: const InputDecoration(
            labelText: "Bevestig Wagwoord",
            prefixIcon: Icon(Icons.lock_reset_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetailsStep() {
    return Column(
      children: [
        TextFormField(
          controller: _firstNameController,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Voornaam is verpligtend';
            }
            return null;
          },
          decoration: const InputDecoration(
            labelText: "Voornaam",
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _lastNameController,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Van is verpligtend';
            }
            return null;
          },
          decoration: const InputDecoration(
            labelText: "Van",
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePictureStep() {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: () => _showImageSourcePicker(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Kies 'n foto sodat ons jou kan herken",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
