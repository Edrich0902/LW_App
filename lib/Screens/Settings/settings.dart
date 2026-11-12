import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Locale/locale_bloc.dart';
import 'package:lw_app/Blocs/Locale/locale_event.dart';
import 'package:lw_app/Blocs/Locale/locale_state.dart';
import 'package:lw_app/Blocs/Theme/theme_bloc.dart';
import 'package:lw_app/Blocs/Theme/theme_event.dart';
import 'package:lw_app/Blocs/Theme/theme_state.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Services/Push/push_notification_service.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
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

    return LwpChromeScaffold(
      title: context.l10n.settingsTitle,
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(LwpSpacing.md),
          children: [
            _sectionLabel(context.l10n.settingsAppearanceSection, theme),
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return _SegmentedControl<ThemeMode>(
                  values: const [
                    ThemeMode.system,
                    ThemeMode.light,
                    ThemeMode.dark,
                  ],
                  labels: [
                    context.l10n.settingsThemeSystem,
                    context.l10n.settingsThemeLight,
                    context.l10n.settingsThemeDark,
                  ],
                  selected: state.themeMode,
                  onChanged: (mode) {
                    context.read<ThemeBloc>().add(UpdateThemeEvent(mode));
                  },
                );
              },
            ),
            const SizedBox(height: LwpSpacing.lg),
            _sectionLabel(context.l10n.settingsLanguageSection, theme),
            BlocBuilder<LocaleBloc, LocaleState>(
              builder: (context, state) {
                return _SegmentedControl<String>(
                  values: const ['af', 'en'],
                  labels: [
                    context.l10n.settingsLanguageAfrikaans,
                    context.l10n.settingsLanguageEnglish,
                  ],
                  selected: state.locale.languageCode,
                  onChanged: (code) {
                    context.read<LocaleBloc>().add(
                          UpdateLocaleEvent(Locale(code)),
                        );
                  },
                );
              },
            ),
            const SizedBox(height: LwpSpacing.lg),
            _sectionLabel(context.l10n.settingsNotificationsSection, theme),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: LwpSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(LwpRadii.xs),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _statusIcon(),
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: LwpSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusLabel(context),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.settingsNotificationsDescription,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: LwpSpacing.sm),
                        OutlinedButton(
                          onPressed:
                              _notificationBusy ? null : _onEnableNotifications,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurface,
                            side: BorderSide(
                              color:
                                  theme.dividerColor.withValues(alpha: 0.6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: LwpSpacing.sm,
                              vertical: LwpSpacing.xs,
                            ),
                            visualDensity: VisualDensity.compact,
                            shape: const StadiumBorder(),
                          ),
                          child: _notificationBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _notificationStatus ==
                                          AuthorizationStatus.denied
                                      ? context.l10n
                                          .settingsNotificationsActionOpenSettings
                                      : context.l10n
                                          .settingsNotificationsActionEnable,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.dividerColor.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LwpSpacing.sm),
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
}

class _SegmentedControl<T> extends StatelessWidget {
  const _SegmentedControl({
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.35),
        borderRadius: LwpRadii.mdAll,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Material(
                color: values[i] == selected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(LwpRadii.xs),
                child: InkWell(
                  borderRadius: BorderRadius.circular(LwpRadii.xs),
                  onTap: () => onChanged(values[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: LwpSpacing.sm,
                      horizontal: LwpSpacing.xs,
                    ),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: values[i] == selected
                            ? theme.colorScheme.onPrimary
                            : theme.hintColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
