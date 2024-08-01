import 'package:flutter/material.dart';
import 'package:lw_app/Screens/Profile/profile.dart';

class ProfileActionButton extends StatefulWidget {
  const ProfileActionButton({super.key});

  @override
  State<ProfileActionButton> createState() => _ProfileActionButtonState();
}

class _ProfileActionButtonState extends State<ProfileActionButton> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      },
      icon: const Icon(Icons.account_circle_outlined),
    );
  }
}