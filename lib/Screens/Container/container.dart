import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// Screens
import 'package:lw_app/Screens/Dashboard/dashboard.dart';
import 'package:lw_app/Screens/Notes/notes.dart';
import 'package:lw_app/Screens/Profile/profile.dart';
import 'package:lw_app/Screens/VisionMission/visionMission.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {
  PageController _pageViewController = PageController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void itemChanged(int index) {
    setState(() {
      _selectedIndex = index;
      _pageViewController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  void pageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      // body: _screens[_selectedIndex],
      body: PageView(
        controller: _pageViewController,
        children: <Widget>[
          // TODO: add other pages to the page view here
          DashPage(),
          DashPage(), // TODO: change this to upcoming events page
          VisionMissionPage(), // Bible page // TODO: update to Bible page
          VisionMissionPage(),
          ProfilePage(), // TODO: update to konnek page
        ],
        onPageChanged: (index) => pageChanged(index),
      ),
      bottomNavigationBar: Container(
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
            onTabChange: (index) => itemChanged(index),
            tabs: [
              // TODO: add buttons to bottom nav pages here
              GButton(
                padding: EdgeInsets.all(12.0),
                icon: Icons.home,
                text: 'Tuis',
              ),
              GButton(
                padding: EdgeInsets.all(8.0),
                icon: Icons.calendar_month,
                text: 'Kalender',
              ),
              GButton(
                padding: EdgeInsets.all(8.0),
                icon: Icons.menu_book,
                text: 'Bybel',
              ),
              GButton(
                padding: EdgeInsets.all(8.0),
                icon: Icons.info_outline,
                text: 'Visie & Missie',
              ),
              GButton(
                padding: EdgeInsets.all(8.0),
                icon: Icons.group,
                text: 'Konnek',
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
      ),
    );
  }
}

// bottomNavigationBar: AppBottomNav(),