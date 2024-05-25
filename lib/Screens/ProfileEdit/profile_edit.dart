import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/User/user_bloc.dart';
import 'package:lw_app/Utils/snackbar.dart';

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

  @override
  void initState() {
    context.read<UserBloc>().add(const LoadUser());
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void initForm(UserSuccess state) {
    _firstNameController.text = state.user.firstName;
    _lastNameController.text = state.user.lastName;
  }

  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = BlocProvider.of<UserBloc>(context);

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserUpdateSuccess) {
          SnackBarHelper.showSuccessSnack(context, 'Profile Updated');
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
                    return const CircularProgressIndicator();
                  } else if (state is UserSuccess) {
                    initForm(state);
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 16),
                          //TODO: add profile photo functionality
                          const CircleAvatar(
                            radius: 100,
                            //TODO: update with actual user image and add placeholder
                            backgroundImage: NetworkImage(
                                "https://yt3.googleusercontent.com/ytc/AL5GRJUbsh7ILjzuEQAZTot_kkV2GohZR75CjoWM9NSI9Q=s900-c-k-c0x00ffffff-no-rj"),
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
                            // initialValue: state.user?.userMetadata?['lastName'],
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
                          ElevatedButton(
                            onPressed: () => {
                              if (_profileEditFormKey.currentState!.validate())
                                {
                                  userBloc.add(
                                    UpdateUser(
                                      _firstNameController.text,
                                      _lastNameController.text,
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
                  } else {
                    return const Text("Something went wrong!");
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
