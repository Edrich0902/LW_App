import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// Screens
import 'package:lw_app/Screens/Dashboard/dashboard.dart';
import 'package:lw_app/Screens/MoreInfo/more_info.dart';
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
    final bool isDark = theme.brightness == Brightness.dark;

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
          color: isDark ? const Color(0xFF1E1E1E) : theme.primaryColor,
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
              GButton(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                icon: Icons.home,
                text: 'Tuis',
              ),
              GButton(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                icon: Icons.calendar_month,
                text: 'Kalender',
              ),
              GButton(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                icon: Icons.menu_book,
                text: 'Bybel',
              ),
              GButton(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                icon: Icons.info_outline,
                text: 'Meer Oor Ons',
              ),
              GButton(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                icon: Icons.group,
                text: 'Skakel In',
              ),
            ],
            gap: 4,
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 300),
            haptic: true,
            tabBorderRadius: 24.0,
            tabBackgroundColor: isDark 
                ? const Color(0xFFF2C94C).withValues(alpha: 0.1) 
                : Colors.white,
            activeColor: isDark ? const Color(0xFFF2C94C) : theme.primaryColor,
            color: isDark ? Colors.white70 : Colors.white,
          ),
        ),
      ),
    );
  }
}

// bottomNavigationBar: AppBottomNav(),