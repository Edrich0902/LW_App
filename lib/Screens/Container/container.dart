import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// Screens
import 'package:lw_app/Screens/Dashboard/dashboard.dart';
import 'package:lw_app/Screens/MoreInfo/moreInfo.dart';
import 'package:lw_app/Screens/Bible/bible.dart';
import 'package:lw_app/Screens/Connect/connect.dart';
import 'package:lw_app/Screens/Calendar/calendar.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {
  final _pageViewController = PageController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void itemChanged(int index) {
    setState(() {
      _selectedIndex = index;
      _pageViewController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.ease);
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
        children: const <Widget>[
          DashPage(),
          CalendarPage(),
          BiblePage(),
          MoreInfoPage(),
          ConnectPage(),
        ],
        onPageChanged: (index) => pageChanged(index),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.primaryColor,
          border: Border.all(
            color: theme.primaryColor,
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24.0),
            topLeft: Radius.circular(24.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
          child: GNav(
            selectedIndex: _selectedIndex,
            onTabChange: (index) => itemChanged(index),
            tabs: const [
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
                text: 'Meer Oor Ons',
              ),
              GButton(
                padding: EdgeInsets.all(8.0),
                icon: Icons.group,
                text: 'Skakel In',
              ),
            ],
            gap: 8,
            padding: const EdgeInsets.all(16.0),
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 300),
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