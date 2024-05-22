import 'package:flutter/material.dart';
import 'package:lw_app/Widgets/AppDrawer/bottom_nav.dart';

// Screens
import 'package:lw_app/Screens/Dashboard/dashboard.dart';
import 'package:lw_app/Screens/Profile/profile.dart';
import 'package:lw_app/Screens/Notes/notes.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // TODO: add other bottom nav pages here
  static const List<Widget> _screens = <Widget>[
    DashPage(),
    NotesPage(),
    ProfilePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: AppBottomNav(handleScreenIndex: updateIndex),
    );
  }
}

// bottomNavigationBar: AppBottomNav(),