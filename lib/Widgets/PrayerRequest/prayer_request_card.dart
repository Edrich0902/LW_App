import 'package:flutter/material.dart';
import 'package:lw_app/Models/PrayerRequest/prayer_request.dart';
import 'package:lw_app/Utils/date_formatter.dart';

class PrayerRequestCard extends StatelessWidget {
  const PrayerRequestCard({
    super.key,
    required this.request,
    this.onPrayTap,
    this.onResolveTap,
    this.showStatus = false,
  });

  final PrayerRequest request;
  final VoidCallback? onPrayTap;
  final VoidCallback? onResolveTap;
  final bool showStatus;

  Color _statusColor(BuildContext context) {
    switch (request.status) {
      case PrayerRequestStatus.pending:
        return Colors.orange;
      case PrayerRequestStatus.approved:
        return Colors.green;
      case PrayerRequestStatus.rejected:
        return Colors.red;
      case PrayerRequestStatus.resolved:
        return Theme.of(context).primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  label: Text(request.category.afrikaansLabel),
                  visualDensity: VisualDensity.compact,
                ),
                if (showStatus)
                  Chip(
                    label: Text(request.status.afrikaansLabel),
                    backgroundColor:
                        _statusColor(context).withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: _statusColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              request.body,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.displayName ?? 'Anoniem',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (request.createdAt != null)
                  Text(
                    DateFormatter.formatDate(request.createdAt!),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
            if (request.moderationNote != null &&
                request.moderationNote!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Nota: ${request.moderationNote!}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onPrayTap != null)
                  ActionChip(
                    avatar: Icon(
                      request.hasReacted
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 18,
                      color: request.hasReacted
                          ? Colors.red
                          : theme.colorScheme.primary,
                    ),
                    label: Text('Ek bid vir jou (${request.reactionCount})'),
                    onPressed: onPrayTap,
                  ),
                if (onResolveTap != null &&
                    request.status != PrayerRequestStatus.resolved)
                  ActionChip(
                    avatar: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Merk as afgehandel'),
                    onPressed: onResolveTap,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
