import 'package:flutter/material.dart';
import 'package:lw_app/Widgets/AppDrawer/drawer.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: AppDrawer(),
      body: const Text('Profile'),
    );
  }
}