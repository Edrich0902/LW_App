import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/User/user_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

class DashboardGreeting extends StatelessWidget {
  const DashboardGreeting({super.key});

  static String _greetingPhrase(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return context.l10n.dashboardMorningGreeting;
    if (hour >= 12 && hour < 18) return context.l10n.dashboardAfternoonGreeting;
    if (hour >= 18 && hour < 22) return context.l10n.dashboardEveningGreeting;
    return context.l10n.dashboardNightGreeting;
  }

  static IconData _greetingIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return Icons.wb_sunny_outlined;
    if (hour >= 12 && hour < 18) return Icons.wb_sunny;
    return Icons.nightlight_round;
  }

  @override
  Widget build(BuildContext context) {
    final phrase = _greetingPhrase(context);
    final icon = _greetingIcon();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? DarkColors.muted : LightColors.muted;

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final String greetingText =
            state is UserSuccess ? '$phrase, ${state.user.firstName}' : phrase;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: LwpSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: LwpSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greetingText,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    context.l10n.dashboardChurchName,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: mutedColor),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
