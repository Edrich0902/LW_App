import 'package:flutter/material.dart';
import 'package:lw_app/Blocs/UserAnnouncements/user_announcement_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Screens/UserAnnouncements/user_announcements.dart';

class LwpAnnouncementButton extends StatefulWidget {
  const LwpAnnouncementButton({super.key});

  @override
  State<LwpAnnouncementButton> createState() => _LwpAnnouncementButtonState();
}

class _LwpAnnouncementButtonState extends State<LwpAnnouncementButton> {
  SupabaseClient supabase = Supabase.instance.client;
  GoTrueClient _auth = Supabase.instance.client.auth;
  int _unreadAnnouncements = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadAnnouncements();
  }

  void _loadUnreadAnnouncements() async {
    final response = await supabase
        .from('user_announcements')
        .select('is_read', const FetchOptions(count: CountOption.exact))
        .eq('is_read', false)
        .eq('user_id', _auth.currentUser?.id);

    _setUnreadAnnouncements(response.count);
  }

  void _setUnreadAnnouncements(int unreadAnnouncements) {
    if (!mounted) return;
    setState(() {
      _unreadAnnouncements = unreadAnnouncements;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserAnnouncementsPage()),
        );
      },
      icon: Badge(
        isLabelVisible: _unreadAnnouncements > 0,
        label: Text(_unreadAnnouncements.toString()),
        offset: const Offset(8, 8),
        child: const Icon(Icons.notifications),
      ),
    );
  }
}