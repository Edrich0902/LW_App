import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Screens/Bible/bible.dart';
import 'package:lw_app/Screens/Calendar/calendar.dart';
import 'package:lw_app/Screens/Connect/connect.dart';
import 'package:lw_app/Screens/Dashboard/dashboard.dart';
import 'package:lw_app/Screens/MoreInfo/more_info.dart';
import 'package:lw_app/Widgets/Glass/lwp_phone_bar.dart';
import 'package:lw_app/Widgets/Glass/lwp_top_bar.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {
  /// Bible tab keeps its own AppBar (book/chapter chrome).
  static const int _bibleTabIndex = 2;

  final _pageViewController = PageController();
  final _backdrop = BackdropKey();
  int _selectedIndex = 0;

  void itemChanged(int index) {
    setState(() {
      _selectedIndex = index;
      _pageViewController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  void pageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  bool get _showFloatingTop => _selectedIndex != _bibleTabIndex;

  String _titleForIndex(BuildContext context) {
    final l10n = context.l10n;
    switch (_selectedIndex) {
      case 1:
        return l10n.navCalendar;
      case 2:
        return l10n.navBible;
      case 3:
        return l10n.navMoreInfo;
      case 4:
        return l10n.navConnect;
      case 0:
      default:
        return l10n.navHome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = [
      LwpNavTab(icon: Icons.home, label: l10n.navHome),
      LwpNavTab(icon: Icons.calendar_month, label: l10n.navCalendar),
      LwpNavTab(icon: Icons.menu_book, label: l10n.navBible),
      LwpNavTab(icon: Icons.info_outline, label: l10n.navMoreInfo),
      LwpNavTab(icon: Icons.group, label: l10n.navConnect),
    ];

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: BackdropGroup(
        backdropKey: _backdrop,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: PageView(
                controller: _pageViewController,
                onPageChanged: pageChanged,
                children: const <Widget>[
                  DashPage(),
                  CalendarPage(),
                  BiblePage(),
                  MoreInfoPage(),
                  ConnectPage(),
                ],
              ),
            ),
            // Keep slot stable so the phone-bar State (lens spring) is never remounted.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: !_showFloatingTop,
                child: Opacity(
                  opacity: _showFloatingTop ? 1 : 0,
                  child: LwpTopBar(title: _titleForIndex(context)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LwpPhoneBar(
                tabs: tabs,
                selectedIndex: _selectedIndex,
                onTabSelected: itemChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
