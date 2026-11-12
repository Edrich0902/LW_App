import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lw_app/Extensions/app_localizations_x.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/AppFeedback/app_feedback.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';

class FeedbackItemCard extends StatelessWidget {
  final AppFeedback feedback;

  const FeedbackItemCard({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = feedback.createdAt != null
        ? _formatDate(feedback.createdAt!)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LwpSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusChip(status: feedback.status),
              const SizedBox(width: LwpSpacing.xs),
              Expanded(
                child: Text(
                  feedback.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (date.isNotEmpty)
                Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: LwpSpacing.xs),
          Text(
            feedback.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
              height: 1.45,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if ((feedback.adminNote ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: LwpSpacing.sm),
            _AdminNoteBox(note: feedback.adminNote!),
          ],
        ],
      ),
    );
  }

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate).toLocal();
      return DateFormat('d MMM').format(date);
    } catch (_) {
      return '';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final FeedbackStatus status;

  const _StatusChip({required this.status});

  Color _chipColor(BuildContext context) {
    switch (status) {
      case FeedbackStatus.open:
        return Theme.of(context).hintColor;
      case FeedbackStatus.underReview:
        return Colors.amber.shade700;
      case FeedbackStatus.planned:
        return Theme.of(context).colorScheme.primary;
      case FeedbackStatus.resolved:
        return const Color(0xFF10B981);
      case FeedbackStatus.closed:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _chipColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LwpSpacing.sm,
        vertical: LwpSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(LwpRadii.pill),
      ),
      child: Text(
        status.label(context.l10n),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: color,
        ),
      ),
    );
  }
}

class _AdminNoteBox extends StatelessWidget {
  final String note;

  const _AdminNoteBox({required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LwpSpacing.sm),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      child: Text(
        note,
        style: theme.textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.hintColor,
          height: 1.4,
        ),
      ),
    );
  }
}
