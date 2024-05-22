import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// Screens
import 'package:lw_app/Screens/Profile/profile.dart';
import 'package:lw_app/Screens/Dashboard/dashboard.dart';
import 'package:lw_app/Screens/VisionMission/visionMission.dart';
import 'package:lw_app/Screens/Notes/notes.dart';

class AppBottomNav extends StatefulWidget {
  final void Function(int) handleScreenIndex;

  const AppBottomNav({super.key, required this.handleScreenIndex});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.primaryColor,
        border: Border.all(
          color: theme.primaryColor,
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24.0),
          topLeft: Radius.circular(24.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
        child: GNav(
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
              widget.handleScreenIndex(index);
            });
          },
          tabs: [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.notes,
              text: 'Notes',
            ),
            GButton(
              icon: Icons.info_outline,
              text: 'More Info',
            ),
            GButton(
              icon: Icons.person,
              text: 'Profile',
            ),
          ],
          gap: 8,
          padding: EdgeInsets.all(16.0),
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 300),
          haptic: true,
          tabBorderRadius: 24.0,
          tabBackgroundColor: Colors.white,
          activeColor: theme.primaryColor,
          color: Colors.white,
        ),
      ),
    );
  }
}
