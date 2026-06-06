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
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LwpSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CategoryChip(category: feedback.category),
                const SizedBox(width: LwpSpacing.sm),
                _StatusChip(status: feedback.status),
                const Spacer(),
                if (feedback.createdAt != null)
                  Text(
                    _formatDate(feedback.createdAt!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: LwpSpacing.md),
            Text(
              feedback.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: LwpSpacing.xs),
            Text(
              feedback.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (feedback.adminNote != null &&
                feedback.adminNote!.isNotEmpty) ...[
              const SizedBox(height: LwpSpacing.md),
              _AdminNoteBox(note: feedback.adminNote!),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate).toLocal();
      return DateFormat('d MMM yyyy').format(date);
    } catch (_) {
      return '';
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final FeedbackCategory category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        category.label(context.l10n),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: LwpSpacing.xs),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final FeedbackStatus status;

  const _StatusChip({required this.status});

  Color _chipColor(BuildContext context) {
    switch (status) {
      case FeedbackStatus.open:
        return Colors.orange;
      case FeedbackStatus.underReview:
        return Colors.amber.shade700;
      case FeedbackStatus.planned:
        return Colors.blue;
      case FeedbackStatus.resolved:
        return Colors.green;
      case FeedbackStatus.closed:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _chipColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LwpSpacing.sm,
        vertical: LwpSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(LwpRadii.pill),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.label(context.l10n),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(LwpSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(LwpRadii.lg),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(width: LwpSpacing.sm),
          Expanded(
            child: Text(
              note,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
