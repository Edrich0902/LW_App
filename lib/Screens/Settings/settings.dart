import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Theme/theme_bloc.dart';
import 'package:lw_app/Blocs/Theme/theme_event.dart';
import 'package:lw_app/Blocs/Theme/theme_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instellings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                'Voorkoms',
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
                        'Stelsel',
                        Icons.brightness_auto,
                        ThemeMode.system,
                        state.themeMode == ThemeMode.system,
                      ),
                      const Divider(height: 1, indent: 56),
                      _themeOption(
                        context,
                        'Lig',
                        Icons.light_mode,
                        ThemeMode.light,
                        state.themeMode == ThemeMode.light,
                      ),
                      const Divider(height: 1, indent: 56),
                      _themeOption(
                        context,
                        'Donker',
                        Icons.dark_mode,
                        ThemeMode.dark,
                        state.themeMode == ThemeMode.dark,
                      ),
                    ],
                  );
                },
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
