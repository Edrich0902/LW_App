import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lw_app/Blocs/User/user_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/User/user_profile.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpProfileImage/lwp_profile_image.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  User? user = Supabase.instance.client.auth.currentUser;

  final _profileEditFormKey = GlobalKey<FormState>();
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
    final userBloc = BlocProvider.of<UserBloc>(context);
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
      child: LwpChromeScaffold(
        title: context.l10n.profileEditTitle,
        body: SafeArea(
          top: false,
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserSuccess) {
                initForm(state);
              }

              if (!_isInitialized && state is UserLoading) {
                return LwpLoader(message: context.l10n.profileLoading);
              }

              if (_isInitialized && _currentUser != null) {
                final publicId = state is UserSuccess
                    ? state.user.profilePublicId ?? ''
                    : _currentUser!.profilePublicId ?? '';
                final fullName =
                    '${_firstNameController.text} ${_lastNameController.text}'
                        .trim();

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    LwpSpacing.md,
                    LwpSpacing.sm,
                    LwpSpacing.md,
                    LwpSpacing.xl,
                  ),
                  child: Form(
                    key: _profileEditFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildIdentityHeader(
                          publicId: publicId,
                          fullName: fullName.isEmpty
                              ? context.l10n.profileDefaultName
                              : fullName,
                          userBloc: userBloc,
                          theme: theme,
                          isLoading: state is UserLoading,
                        ),
                        const SizedBox(height: LwpSpacing.md),
                        _sectionLabel(
                          context.l10n.profileEditDetailsSection,
                          theme,
                        ),
                        _QuietField(
                          label: context.l10n.authEmail,
                          child: Text(
                            user?.email ?? 'N/A',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _QuietField(
                          label: context.l10n.authFirstName,
                          child: TextFormField(
                            controller: _firstNameController,
                            textCapitalization: TextCapitalization.words,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _quietInputDecoration,
                            validator: (firstName) {
                              if (firstName == null || firstName.isEmpty) {
                                return context.l10n.profileEditNameRequired;
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        _QuietField(
                          label: context.l10n.authLastName,
                          child: TextFormField(
                            controller: _lastNameController,
                            textCapitalization: TextCapitalization.words,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _quietInputDecoration,
                            validator: (lastName) {
                              if (lastName == null || lastName.isEmpty) {
                                return context
                                    .l10n.profileEditLastNameRequired;
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        _QuietField(
                          label: context.l10n.profileEditAddress,
                          child: TextFormField(
                            controller: _addressController,
                            textCapitalization: TextCapitalization.sentences,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _quietInputDecoration,
                          ),
                        ),
                        const SizedBox(height: LwpSpacing.md),
                        _sectionLabel(
                          context.l10n.profileEditFaithSection,
                          theme,
                        ),
                        _ToggleRow(
                          label: context.l10n.profileEditBaptizedLabel,
                          value: _isBaptized,
                          onChanged: (value) =>
                              setState(() => _isBaptized = value),
                        ),
                        _ToggleRow(
                          label: context.l10n.profileEditMemberLabel,
                          value: _isMember,
                          onChanged: (value) =>
                              setState(() => _isMember = value),
                        ),
                        const SizedBox(height: LwpSpacing.lg),
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
                              : Text(context.l10n.commonSave),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is UserError && !_isInitialized) {
                return LwpError(
                  onRetry: () =>
                      context.read<UserBloc>().add(const LoadUser()),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LwpSpacing.xs),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.hintColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildIdentityHeader({
    required String publicId,
    required String fullName,
    required UserBloc userBloc,
    required ThemeData theme,
    required bool isLoading,
  }) {
    return Row(
      children: [
        Stack(
          children: [
            LwpProfileImage(
              publicId: publicId,
              height: 84,
              radius: 42,
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Material(
                color: theme.primaryColor,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isLoading
                      ? null
                      : () => _showImageSourcePicker(userBloc),
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: LwpSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                context.l10n.dashboardChurchName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: LwpSpacing.xs),
              InkWell(
                onTap: isLoading
                    ? null
                    : () => _showImageSourcePicker(userBloc),
                child: Text(
                  context.l10n.profileEditChangePhoto,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
                  final image = await _pickImageFromGallery();
                  if (image != null) {
                    userBloc.add(
                      UploadProfilePicture(profileImageFile: image),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(context.l10n.authCamera),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await _pickImageFromCamera();
                  if (image != null) {
                    userBloc.add(
                      UploadProfilePicture(profileImageFile: image),
                    );
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
    final imageFile = File(returnedImage.path);
    if (await imageFile.exists()) return imageFile;
    return null;
  }

  Future<File?> _pickImageFromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedImage == null) return null;
    final imageFile = File(returnedImage.path);
    if (await imageFile.exists()) return imageFile;
    return null;
  }
}

/// Strips the global filled InputDecorationTheme so quiet fields stay bare text.
const _quietInputDecoration = InputDecoration(
  filled: false,
  fillColor: Colors.transparent,
  isDense: true,
  contentPadding: EdgeInsets.zero,
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  focusedErrorBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
);

class _QuietField extends StatelessWidget {
  const _QuietField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: LwpSpacing.sm, bottom: 4),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.hintColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        child,
        Divider(
          height: LwpSpacing.md,
          thickness: 1,
          color: theme.dividerColor.withValues(alpha: 0.45),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: LwpSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor:
                    theme.dividerColor.withValues(alpha: 0.55),
                trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.transparent;
                  }
                  return theme.dividerColor.withValues(alpha: 0.7);
                }),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: theme.dividerColor.withValues(alpha: 0.45),
        ),
      ],
    );
  }
}
