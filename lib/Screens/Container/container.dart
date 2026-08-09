import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';

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
  /// Index of the Bible tab in PageView / GNav (FAB is hidden here).
  static const int _bibleTabIndex = 2;

  final _pageViewController = PageController();
  int _selectedIndex = 0;

  void itemChanged(int index) {
    setState(() {
      _selectedIndex = index;
      _pageViewController.animateToPage(index,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  void pageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// WhatsApp contact FAB on all bottom-nav roots except Bible (reading chrome).
  bool get _showWhatsappFab => _selectedIndex != _bibleTabIndex;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
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
      floatingActionButton:
          _showWhatsappFab ? const WhatsappContactFAB() : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : theme.primaryColor,
          borderRadius: LwpRadii.lgTop,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
          child: GNav(
            selectedIndex: _selectedIndex,
            onTabChange: (index) => itemChanged(index),
            tabs: [
              GButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                icon: Icons.home,
                text: context.l10n.navHome,
              ),
              GButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                icon: Icons.calendar_month,
                text: context.l10n.navCalendar,
              ),
              GButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                icon: Icons.menu_book,
                text: context.l10n.navBible,
              ),
              GButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                icon: Icons.info_outline,
                text: context.l10n.navMoreInfo,
              ),
              GButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                icon: Icons.group,
                text: context.l10n.navConnect,
              ),
            ],
            gap: 4,
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 300),
            haptic: true,
            tabBorderRadius: LwpRadii.lg,
            tabBackgroundColor: isDark
                ? theme.primaryColor.withValues(alpha: 0.1)
                : Colors.white,
            activeColor: theme.primaryColor,
            color: isDark ? Colors.white70 : Colors.white,
          ),
        ),
      ),
    );
  }
}

// bottomNavigationBar: AppBottomNav(),
