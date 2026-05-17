import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/UserAnnouncements/user_announcement_bloc.dart';
import 'package:lw_app/Screens/UserAnnouncements/user_announcements.dart';

class LwpAnnouncementButton extends StatefulWidget {
  final Color? color;
  const LwpAnnouncementButton({super.key, this.color});

  @override
  State<LwpAnnouncementButton> createState() => _LwpAnnouncementButtonState();
}

class _LwpAnnouncementButtonState extends State<LwpAnnouncementButton> {
  @override
  void initState() {
    super.initState();
    context.read<UserAnnouncementBloc>().add(const LoadUserAnnouncements());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAnnouncementBloc, UserAnnouncementState>(
      builder: (context, state) {
        int unreadCount = 0;
        if (state is UserAnnouncementSuccess) {
          unreadCount = state.userAnnouncements.length;
        }

        return IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserAnnouncementsPage()),
            );
          },
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(unreadCount.toString()),
            offset: const Offset(8, 8),
            child: Icon(
              Icons.notifications,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}