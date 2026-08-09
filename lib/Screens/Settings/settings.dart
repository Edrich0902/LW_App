import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Locale/locale_bloc.dart';
import 'package:lw_app/Blocs/Locale/locale_event.dart';
import 'package:lw_app/Blocs/Locale/locale_state.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/Theme/theme_bloc.dart';
import 'package:lw_app/Blocs/Theme/theme_event.dart';
import 'package:lw_app/Blocs/Theme/theme_state.dart';
import 'package:lw_app/Services/Push/push_notification_service.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  AuthorizationStatus? _notificationStatus;
  bool _notificationBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNotificationStatus();
    }
  }

  Future<void> _refreshNotificationStatus() async {
    final status =
        await PushNotificationService.instance.getAuthorizationStatus();
    if (!mounted) return;
    setState(() => _notificationStatus = status);
  }

  Future<void> _onEnableNotifications() async {
    setState(() => _notificationBusy = true);
    try {
      final status =
          await PushNotificationService.instance.getAuthorizationStatus();
      if (status == AuthorizationStatus.denied) {
        await PushNotificationService.instance.openSystemNotificationSettings();
        if (!mounted) return;
        LwpSnackbar.showInfo(
          context,
          context.l10n.settingsNotificationsDeniedSnack,
        );
      } else {
        final enabled =
            await PushNotificationService.instance.registerForPush();
        if (!mounted) return;
        if (enabled) {
          LwpSnackbar.showSuccess(
            context,
            context.l10n.settingsNotificationsEnabledSnack,
          );
        } else {
          await PushNotificationService.instance
              .openSystemNotificationSettings();
          if (!mounted) return;
          LwpSnackbar.showInfo(
            context,
            context.l10n.settingsNotificationsDeniedSnack,
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _notificationBusy = false);
        await _refreshNotificationStatus();
      }
    }
  }

  String _statusLabel(BuildContext context) {
    switch (_notificationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return context.l10n.settingsNotificationsStatusEnabled;
      case AuthorizationStatus.denied:
        return context.l10n.settingsNotificationsStatusDenied;
      case AuthorizationStatus.notDetermined:
      case null:
        return context.l10n.settingsNotificationsStatusUnknown;
    }
  }

  IconData _statusIcon() {
    switch (_notificationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return Icons.notifications_active_outlined;
      case AuthorizationStatus.denied:
        return Icons.notifications_off_outlined;
      case AuthorizationStatus.notDetermined:
      case null:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(LwpSpacing.md),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: LwpSpacing.xs, bottom: LwpSpacing.xs),
              child: Text(
                context.l10n.settingsAppearanceSection,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.hintColor,
                ),
              ),
            ),
            Card(
              child: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      _themeOption(
                        context,
                        context.l10n.settingsThemeSystem,
                        Icons.brightness_auto,
                        ThemeMode.system,
                        state.themeMode == ThemeMode.system,
                      ),
                      const Divider(height: 1, indent: 56),
                      _themeOption(
                        context,
                        context.l10n.settingsThemeLight,
                        Icons.light_mode,
                        ThemeMode.light,
                        state.themeMode == ThemeMode.light,
                      ),
                      const Divider(height: 1, indent: 56),
                      _themeOption(
                        context,
                        context.l10n.settingsThemeDark,
                        Icons.dark_mode,
                        ThemeMode.dark,
                        state.themeMode == ThemeMode.dark,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: LwpSpacing.lg),
            Padding(
              padding: const EdgeInsets.only(
                  left: LwpSpacing.xs, bottom: LwpSpacing.xs),
              child: Text(
                context.l10n.settingsLanguageSection,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.hintColor,
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(LwpSpacing.md),
                child: BlocBuilder<LocaleBloc, LocaleState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.settingsLanguageDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: LwpSpacing.md),
                        SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: 'af',
                              label:
                                  Text(context.l10n.settingsLanguageAfrikaans),
                            ),
                            ButtonSegment(
                              value: 'en',
                              label: Text(context.l10n.settingsLanguageEnglish),
                            ),
                          ],
                          selected: {state.locale.languageCode},
                          onSelectionChanged: (selected) {
                            context.read<LocaleBloc>().add(
                                  UpdateLocaleEvent(
                                    Locale(selected.first),
                                  ),
                                );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: LwpSpacing.lg),
            Padding(
              padding: const EdgeInsets.only(
                  left: LwpSpacing.xs, bottom: LwpSpacing.xs),
              child: Text(
                context.l10n.settingsNotificationsSection,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.hintColor,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      _statusIcon(),
                      color: theme.primaryColor,
                    ),
                    title: Text(_statusLabel(context)),
                    subtitle: Text(
                      context.l10n.settingsNotificationsDescription,
                    ),
                    isThreeLine: true,
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: _notificationBusy
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.notifications_outlined,
                            color: theme.primaryColor,
                          ),
                    title: Text(
                      _notificationStatus == AuthorizationStatus.denied
                          ? context.l10n.settingsNotificationsActionOpenSettings
                          : context.l10n.settingsNotificationsActionEnable,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _notificationBusy ? null : _onEnableNotifications,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(
    BuildContext context,
    String title,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.primaryColor : null,
      ),
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.primaryColor)
          : Icon(Icons.circle_outlined, color: theme.hintColor),
      onTap: () {
        context.read<ThemeBloc>().add(UpdateThemeEvent(mode));
      },
    );
  }
}
