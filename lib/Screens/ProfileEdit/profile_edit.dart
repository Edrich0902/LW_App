import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/User/user_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/User/user_profile.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/LwpProfileImage/lwp_profile_image.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:lw_app/Widgets/LabeledCheckbox/labeled_checkbox.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  User? user = Supabase.instance.client.auth.currentUser;

  // Form key
  final _profileEditFormKey = GlobalKey<FormState>();

  // Form controllers
  late final TextEditingController _firstNameController =
      TextEditingController();
  late final TextEditingController _lastNameController =
      TextEditingController();
  late final TextEditingController _addressController = TextEditingController();
  bool _isMember = false;
  bool _isBaptized = false;
  bool _isInitialized = false;
  UserProfile? _currentUser;

  @override
  void initState() {
    context.read<UserBloc>().add(const LoadUser());
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void initForm(UserSuccess state) {
    if (_isInitialized) {
      _currentUser = state.user;
      return;
    }

    _firstNameController.text = state.user.firstName;
    _lastNameController.text = state.user.lastName;
    _addressController.text = state.user.address ?? '';
    _isMember = state.user.isMember ?? false;
    _isBaptized = state.user.isBaptized ?? false;
    _currentUser = state.user;
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = BlocProvider.of<UserBloc>(context);
    final theme = Theme.of(context);

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserUpdateSuccess) {
          LwpSnackbar.showSuccess(context, context.l10n.profileEditSuccess);
        }

        if (state is UserProfilePictureSuccess) {
          LwpSnackbar.showSuccess(
            context,
            context.l10n.profileEditPhotoSuccess,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.profileEditTitle),
        ),
        body: SafeArea(
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserSuccess) {
                initForm(state);
              }

              if (!_isInitialized && state is UserLoading) {
                return LwpLoader(message: context.l10n.profileLoading);
              }

              if (_isInitialized && _currentUser != null) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Form(
                    key: _profileEditFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 24),
                        _buildProfileImage(
                            state is UserSuccess
                                ? state.user.profilePublicId ?? ''
                                : _currentUser!.profilePublicId ?? '',
                            userBloc,
                            theme,
                            state is UserLoading),
                        const SizedBox(height: 32),
                        TextFormField(
                          initialValue: user?.email ?? 'N/A',
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: context.l10n.authEmail,
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _firstNameController,
                          textCapitalization: TextCapitalization.words,
                          validator: (firstName) {
                            if (firstName == null || firstName.isEmpty) {
                              return context.l10n.profileEditNameRequired;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: context.l10n.authFirstName,
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          textCapitalization: TextCapitalization.words,
                          validator: (lastName) {
                            if (lastName == null || lastName.isEmpty) {
                              return context.l10n.profileEditLastNameRequired;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: context.l10n.authLastName,
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: context.l10n.profileEditAddress,
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 24),
                        LabeledCheckbox(
                          value: _isBaptized,
                          label: context.l10n.profileEditIsBaptized,
                          onChanged: (bool? newValue) {
                            setState(() => _isBaptized = newValue!);
                          },
                        ),
                        LabeledCheckbox(
                          value: _isMember,
                          label: context.l10n.profileEditIsMember,
                          onChanged: (bool? newValue) {
                            setState(() => _isMember = newValue!);
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            if (_profileEditFormKey.currentState!.validate()) {
                              userBloc.add(
                                UpdateUser(
                                  firstName: _firstNameController.text,
                                  lastName: _lastNameController.text,
                                  address: _addressController.text,
                                  isMember: _isMember,
                                  isBaptized: _isBaptized,
                                ),
                              );
                            }
                          },
                          child: state is UserLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(context.l10n.profileEditUpdateButton),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              } else if (state is UserError && !_isInitialized) {
                return LwpError(
                  onRetry: () => context.read<UserBloc>().add(const LoadUser()),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(
      String publicId, UserBloc userBloc, ThemeData theme, bool isLoading) {
    return Center(
      child: Stack(
        children: [
          LwpProfileImage(
            publicId: publicId,
            height: 160,
            radius: 80,
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
                border:
                    Border.all(color: theme.scaffoldBackgroundColor, width: 2),
              ),
              child: IconButton(
                icon:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed:
                    isLoading ? null : () => _showImageSourcePicker(userBloc),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourcePicker(UserBloc userBloc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: LwpRadii.lgTop,
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(context.l10n.authGallery),
                onTap: () async {
                  Navigator.pop(context);
                  File? image = await _pickImageFromGallery();
                  if (image != null) {
                    userBloc.add(UploadProfilePicture(profileImageFile: image));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(context.l10n.authCamera),
                onTap: () async {
                  Navigator.pop(context);
                  File? image = await _pickImageFromCamera();
                  if (image != null) {
                    userBloc.add(UploadProfilePicture(profileImageFile: image));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File?> _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage == null) return null;
    File? imageFile = File(returnedImage.path);
    if (await imageFile.exists()) return imageFile;
    return null;
  }

  Future<File?> _pickImageFromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedImage == null) return null;
    File? imageFile = File(returnedImage.path);
    if (await imageFile.exists()) return imageFile;
    return null;
  }
}
