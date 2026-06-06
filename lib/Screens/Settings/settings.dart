import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Locale/locale_bloc.dart';
import 'package:lw_app/Blocs/Locale/locale_event.dart';
import 'package:lw_app/Blocs/Locale/locale_state.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/Theme/theme_bloc.dart';
import 'package:lw_app/Blocs/Theme/theme_event.dart';
import 'package:lw_app/Blocs/Theme/theme_state.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
