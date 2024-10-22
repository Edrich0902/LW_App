import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/User/user_bloc.dart';
import 'package:lw_app/Utils/snackbar.dart';
import 'package:lw_app/Widgets/LabeledCheckbox/labeled_checkbox.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloudinary_url_gen/transformation/transformation.dart';
import 'package:cloudinary_url_gen/transformation/delivery/delivery.dart';
import 'package:cloudinary_url_gen/transformation/delivery/delivery_actions.dart';

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
  late final TextEditingController _addressController =
      TextEditingController();
  bool _isMember = false;
  bool _isBaptized = false;
  String _profilePublicId = '';

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
    _firstNameController.text = state.user.firstName;
    _lastNameController.text = state.user.lastName;
    _addressController.text = state.user.address ?? '';
    _isMember = state.user.isMember ?? false;
    _isBaptized = state.user.isBaptized ?? false;
    _profilePublicId = state.user.profilePublicId ?? '';
  }

  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = BlocProvider.of<UserBloc>(context);
    final theme = Theme.of(context);

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserUpdateSuccess) {
          SnackBarHelper.showSuccessSnack(context, 'Profile Updated');
        }

        if (state is UserProfilePictureSuccess) {
          SnackBarHelper.showSuccessSnack(context, 'Profile Image Updated');
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Center(
            child: Form(
              key: _profileEditFormKey,
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoading) {
                    return const LwpLoader(message: "Loading Profile");
                  } else if (state is UserSuccess) {
                    initForm(state);
                    return SingleChildScrollView(
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ClipOval(
                                  child: CldImageWidget(
                                    publicId: _profilePublicId,
                                    transformation: Transformation()
                                        .delivery(Delivery.quality(Quality.auto()))
                                        .delivery(Delivery.format(Format.auto)),
                                    placeholder: (context, url) => CircularProgressIndicator(),
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300], // Background color for the fallback
                                        child: Center(
                                          child: Icon(Icons.person, size: 100.0), // Fallback icon
                                        ),
                                      );
                                    },
                                    width: 250,
                                    height: 250,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    IconButton(
                                      onPressed: () async {
                                        File? image = await _pickImageFromCamera();
                                        if (image == null) return;
                                        userBloc.add(
                                            UploadProfilePicture(profileImageFile: image)
                                        );
                                      },
                                      icon: Icon(Icons.camera_alt_outlined),
                                      style: ButtonStyle(
                                        foregroundColor: MaterialStateProperty.all(Colors.white),
                                        backgroundColor: MaterialStateProperty.all(theme.primaryColor)
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        File? image = await _pickImageFromGallery();
                                        if (image == null) return;
                                        userBloc.add(
                                          UploadProfilePicture(profileImageFile: image)
                                        );
                                      },
                                      icon: Icon(Icons.attach_file),
                                      style: ButtonStyle(
                                        foregroundColor: MaterialStateProperty.all(Colors.white),
                                        backgroundColor: MaterialStateProperty.all(theme.primaryColor)
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  initialValue: user?.email ?? 'N/A',
                                  enabled: false,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    suffixIcon: Icon(Icons.email),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  // initialValue: state.user?.userMetadata?['firstName'],
                                  controller: _firstNameController,
                                  validator: (firstName) {
                                    if (firstName == null || firstName.isEmpty) {
                                      return 'First Name is required';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                    suffixIcon: Icon(Icons.account_circle),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _lastNameController,
                                  validator: (lastName) {
                                    if (lastName == null || lastName.isEmpty) {
                                      return 'Last Name is required';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                    suffixIcon: Icon(Icons.account_circle),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _addressController,
                                  decoration: const InputDecoration(
                                    labelText: 'Address',
                                    suffixIcon: Icon(Icons.location_on),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                LabeledCheckbox(
                                  value: _isBaptized,
                                  label: 'Are you baptized?',
                                  onChanged: (bool? newValue) {
                                    setState(() => _isBaptized = newValue!);
                                  },
                                ),
                                LabeledCheckbox(
                                  value: _isMember,
                                  label: 'Are you a member?',
                                  onChanged: (bool? newValue) {
                                    setState(() => _isMember = newValue!);
                                  },
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => {
                                    if (_profileEditFormKey.currentState!.validate())
                                      {
                                        userBloc.add(
                                          UpdateUser(
                                            firstName: _firstNameController.text,
                                            lastName: _lastNameController.text,
                                            address: _addressController.text,
                                            isMember: _isMember,
                                            isBaptized: _isBaptized
                                          ),
                                        )
                                      },
                                  },
                                  child: state is UserLoading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                      : const Text("Update Profile"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const LwpError();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<File?> _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    File? imageFile = File(returnedImage!.path);
    if (await imageFile.exists()) return imageFile;
    return null;
  }

  Future<File?> _pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    File? imageFile = File(returnedImage!.path);
    if (await imageFile.exists()) return imageFile;
    return null;
  }
}
