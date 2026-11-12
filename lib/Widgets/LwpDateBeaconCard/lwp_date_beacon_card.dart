import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';

/// Compact event/course card: short cover + date tile + quiet meta row.
class LwpDateBeaconCard extends StatelessWidget {
  const LwpDateBeaconCard({
    super.key,
    required this.event,
    required this.heroTag,
    required this.onTap,
    this.showAttendance = false,
    this.coverHeight = 120,
    this.displayDate,
  });

  final Event event;
  final String heroTag;
  final VoidCallback onTap;
  final bool showAttendance;
  final double coverHeight;

  /// When set (e.g. next weekly occurrence), overrides [event.startDate].
  final DateTime? displayDate;

  static const double dateTileWidth = 56.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final date = displayDate ?? parseStartDate(event.startDate);
    final hasRsvps = showAttendance &&
        (event.attendingCount + event.interestedCount) > 0;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: const RoundedRectangleBorder(borderRadius: LwpRadii.lgAll),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: coverHeight,
              width: double.infinity,
              child: Hero(
                tag: heroTag,
                child: CldImageWidget(
                  publicId: event.bannerPublicId ?? 'samples/cloudinary-icon',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(LwpSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LwpDateTile(
                    date: date,
                    locale: locale,
                    fallbackDayName: event.day,
                  ),
                  const SizedBox(width: LwpSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (event.description.trim().isNotEmpty) ...[
                          const SizedBox(height: LwpSpacing.xxs),
                          Text(
                            event.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                              height: 1.35,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: LwpSpacing.xs),
                        _MetaRow(
                          timeLabel: DateFormatter.formatTime(event.time),
                          theme: theme,
                          trailing: hasRsvps
                              ? _AttendanceMeta(
                                  attending: event.attendingCount,
                                  interested: event.interestedCount,
                                  theme: theme,
                                )
                              : (event.category.trim().isNotEmpty
                                  ? Text(
                                      event.category,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.hintColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static DateTime? parseStartDate(String? startDate) {
    if (startDate == null || startDate.isEmpty) return null;
    try {
      return DateTime.parse(startDate);
    } catch (_) {
      return null;
    }
  }
}

/// Accent date tile used on Date Beacon cards and detail stages.
class LwpDateTile extends StatelessWidget {
  const LwpDateTile({
    super.key,
    required this.date,
    required this.locale,
    this.fallbackDayName,
  });

  final DateTime? date;
  final String locale;
  final String? fallbackDayName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    String dow;
    if (date != null) {
      dow = DateFormat('EEE', locale).format(date!);
    } else if (fallbackDayName != null && fallbackDayName!.isNotEmpty) {
      dow = fallbackDayName!.length <= 3
          ? fallbackDayName!
          : fallbackDayName!.substring(0, 3);
    } else {
      dow = '—';
    }

    final day = date != null ? '${date!.day}' : '—';
    final mon = date != null ? DateFormat('MMM', locale).format(date!) : '';

    return Container(
      width: LwpDateBeaconCard.dateTileWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: LwpSpacing.xxs,
        vertical: LwpSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: LwpRadii.smAll,
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            dow.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 9,
              letterSpacing: 0.8,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            day,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (mon.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              mon.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
                letterSpacing: 0.4,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.timeLabel,
    required this.theme,
    required this.trailing,
  });

  final String timeLabel;
  final ThemeData theme;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (timeLabel.isNotEmpty)
          Text(
            timeLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        if (timeLabel.isNotEmpty && trailing != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LwpSpacing.xs),
            child: Text(
              '·',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        if (trailing != null) Flexible(child: trailing!),
      ],
    );
  }
}

class _AttendanceMeta extends StatelessWidget {
  const _AttendanceMeta({
    required this.attending,
    required this.interested,
    required this.theme,
  });

  final int attending;
  final int interested;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    const good = Color(0xFF7DCEB0);

    return Row(
      children: [
        const Icon(Icons.check_rounded, size: 12, color: good),
        const SizedBox(width: LwpSpacing.xxs),
        Flexible(
          child: Text(
            interested > 0
                ? '${context.l10n.upcomingEventsAttendingCount(attending)}'
                    ' · ${context.l10n.upcomingEventsInterestedCount(interested)}'
                : context.l10n.upcomingEventsAttendingCount(attending),
            style: theme.textTheme.bodySmall?.copyWith(
              color: good,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
