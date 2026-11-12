import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Blocs/User/user_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Screens/Feedback/my_feedback.dart';
import 'package:lw_app/Screens/Home/home.dart';
import 'package:lw_app/Screens/MyGroups/my_groups.dart';
import 'package:lw_app/Screens/Notes/notes.dart';
import 'package:lw_app/Screens/PrayerRequests/my_prayer_requests.dart';
import 'package:lw_app/Screens/ProfileEdit/profile_edit.dart';
import 'package:lw_app/Screens/Settings/settings.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpProfileImage/lwp_profile_image.dart';
import 'package:lw_app/Widgets/WhatsappContactFAB/whatsapp_contact_fab.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final userBloc = context.read<UserBloc>();
    if (userBloc.state is UserInitial) {
      userBloc.add(LoadUser());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LwpChromeScaffold(
      title: context.l10n.profileTitle,
      floatingActionButton: const WhatsappContactFAB(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          LwpSpacing.md,
          LwpSpacing.sm,
          LwpSpacing.md,
          LwpSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIdentity(theme),
            const SizedBox(height: LwpSpacing.md),
            _sectionLabel(context.l10n.profileMyStuffSection, theme),
            _quietRow(
              icon: Icons.notes_outlined,
              title: context.l10n.profileMyNotes,
              onTap: () => _push(const NotesPage()),
            ),
            _quietRow(
              icon: Icons.favorite_outline,
              title: context.l10n.profileMyPrayerRequests,
              onTap: () => _push(const MyPrayerRequestsPage()),
            ),
            _quietRow(
              icon: Icons.groups_outlined,
              title: context.l10n.profileMyGroups,
              onTap: () => _push(const MyGroupsPage()),
            ),
            _quietRow(
              icon: Icons.feedback_outlined,
              title: context.l10n.profileFeedbackReports,
              onTap: () => _push(const MyFeedbackPage()),
            ),
            const SizedBox(height: LwpSpacing.md),
            _sectionLabel(context.l10n.profileAppSection, theme),
            _quietRow(
              icon: Icons.settings_outlined,
              title: context.l10n.profileSettings,
              onTap: () => _push(const SettingsPage()),
            ),
            _quietRow(
              icon: Icons.logout,
              title: context.l10n.profileSignOut,
              danger: true,
              onTap: _confirmSignOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentity(ThemeData theme) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading || state is UserInitial) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: LwpSpacing.lg),
            child: LwpLoader(message: context.l10n.profileLoading),
          );
        }

        if (state is UserError) {
          return LwpError(
            message: context.l10n.profileLoadError,
            onRetry: () => context.read<UserBloc>().add(LoadUser()),
          );
        }

        String fullName = context.l10n.profileDefaultName;
        String publicId = '';
        String? role;

        if (state is UserSuccess) {
          fullName = '${state.user.firstName} ${state.user.lastName}'.trim();
          publicId = state.user.profilePublicId ?? '';
          role = state.user.role;
        }

        final meta = <String>[
          if (role != null && role.isNotEmpty) _formatRole(role),
          context.l10n.dashboardChurchName,
        ].join(' · ');

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LwpProfileImage(
              publicId: publicId,
              height: 72,
              radius: 36,
            ),
            const SizedBox(width: LwpSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    meta,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: LwpSpacing.xs),
                  InkWell(
                    onTap: () => _push(const ProfileEditPage()),
                    borderRadius: LwpRadii.smAll,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.l10n.profileEditTitle,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionLabel(String label, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LwpSpacing.xxs),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.hintColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _quietRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final theme = Theme.of(context);
    final color = danger ? Colors.redAccent : theme.colorScheme.onSurface;
    final iconBg = danger
        ? Colors.redAccent.withValues(alpha: 0.08)
        : theme.colorScheme.surface.withValues(alpha: 0.0);
    final iconBorder = danger
        ? Colors.redAccent.withValues(alpha: 0.28)
        : theme.dividerColor.withValues(alpha: 0.55);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: LwpSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(LwpRadii.xs),
                    border: Border.all(color: iconBorder),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: LwpSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: theme.hintColor,
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: theme.dividerColor.withValues(alpha: 0.45),
        ),
      ],
    );
  }

  void _push(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.profileSignOutConfirmTitle),
          content: Text(context.l10n.profileSignOutConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.l10n.commonCancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(const SignOutEvent());
                context.read<UserBloc>().add(const ResetUser());
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
              child: Text(
                context.l10n.profileSignOut,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatRole(String role) {
    return role.split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
