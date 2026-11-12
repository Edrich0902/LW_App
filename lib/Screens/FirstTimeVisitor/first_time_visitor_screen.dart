import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lw_app/Blocs/EventRsvp/event_rsvp_bloc.dart';
import 'package:lw_app/Blocs/Events/events_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Screens/MoreInfo/more_info.dart';
import 'package:lw_app/Screens/UpcomingEvents/upcoming_event_detail.dart';
import 'package:lw_app/Themes/lwp_icons.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Utils/event_occurrence.dart';
import 'package:lw_app/Utils/maps_helper.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';
import 'package:url_launcher/url_launcher.dart';

class FirstTimeVisitorScreen extends StatefulWidget {
  const FirstTimeVisitorScreen({super.key});

  @override
  State<FirstTimeVisitorScreen> createState() => _FirstTimeVisitorScreenState();
}

class _FirstTimeVisitorScreenState extends State<FirstTimeVisitorScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EventsBloc>().add(LoadUpcomingEvents(
          eventType: EventType.ONCE,
          date: DateTime.now(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LwpChromeScaffold(
      title: context.l10n.visitorWelcomeTitle,
      showDefaultActions: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          LwpSpacing.md,
          LwpSpacing.md,
          LwpSpacing.md,
          LwpSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.visitorWelcomeHeadline,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: LwpSpacing.xs),
            Text(
              context.l10n.visitorWelcomeBody,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.hintColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: LwpSpacing.lg),
            _sectionLabel(context.l10n.visitorSundayServices, theme),
            _serviceTimeRow(
              context.l10n.visitorMorningService,
              '09:30',
              theme,
            ),
            _serviceTimeRow(
              context.l10n.visitorEveningService,
              '18:00',
              theme,
            ),
            const SizedBox(height: LwpSpacing.md),
            _quietLink(
              icon: Icon(
                Icons.location_on_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              title: context.l10n.visitorFindUs,
              onTap: () => MapsHelper.openLocation('6 Mill Street Paarl'),
            ),
            _quietLink(
              icon: FaIcon(
                LwpIcons.whatsapp,
                size: 15,
                color: theme.colorScheme.primary,
              ),
              title: context.l10n.visitorContactUs,
              onTap: () {
                final Uri whatsappUri =
                    Uri.parse('https://wa.me/+27727238406');
                launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
              },
            ),
            _quietLink(
              icon: Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              title: context.l10n.visitorMoreAboutUs,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoreInfoPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: LwpSpacing.lg),
            _sectionLabel(context.l10n.visitorUpcomingEventsTitle, theme),
            _buildUpcomingEventsSection(),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LwpSpacing.xs),
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

  Widget _serviceTimeRow(String label, String time, ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: LwpSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodyLarge),
              Text(
                time,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
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
    );
  }

  Widget _quietLink({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(LwpRadii.xs),
                  ),
                  alignment: Alignment.center,
                  child: icon,
                ),
                const SizedBox(width: LwpSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
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

  Widget _buildUpcomingEventsSection() {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        if (state is EventsLoading) {
          return LwpSkeletonList.thumb(itemCount: 2, shrinkWrap: true);
        } else if (state is EventsSuccess) {
          final upcoming = state.events.take(3).toList();
          if (upcoming.isEmpty) {
            return Text(
              context.l10n.visitorNoUpcomingEvents,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            );
          }
          return Column(
            children: [
              for (var i = 0; i < upcoming.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context)
                        .dividerColor
                        .withValues(alpha: 0.45),
                  ),
                _buildEventRow(upcoming[i]),
              ],
            ],
          );
        } else {
          return LwpError(message: context.l10n.visitorUpcomingEventsError);
        }
      },
    );
  }

  Widget _buildEventRow(Event event) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final next = EventOccurrence.nextFor(event);
    final day = next != null ? '${next.day}' : '—';
    final mon = next != null ? DateFormat('MMM', locale).format(next) : '';
    final timeLabel = _formatEventTime(event.time);
    final metaParts = <String>[
      if (event.day.trim().isNotEmpty) event.day,
      if (timeLabel.isNotEmpty) timeLabel,
    ];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => EventRsvpBloc()..add(InitEventRsvp(event)),
              child: UpcomingEventDetailPage(event: event),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LwpSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: LwpRadii.smAll,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mon.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: LwpSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (metaParts.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      metaParts.join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatEventTime(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    try {
      return DateFormatter.formatTime(value);
    } catch (_) {
      final match = RegExp(r'^(\d{1,2}:\d{2})').firstMatch(value);
      return match?.group(1) ?? value;
    }
  }
}
