import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/UserAnnouncements/user_announcement_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/UserAnnouncement/user_announcement.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Widgets/LwpBottomSheet/lwp_bottom_sheet.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpListEntrance/lwp_list_entrance.dart';
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';

class UserAnnouncementsPage extends StatefulWidget {
  const UserAnnouncementsPage({super.key});

  @override
  State<UserAnnouncementsPage> createState() => _UserAnnouncementsPageState();
}

class _UserAnnouncementsPageState extends State<UserAnnouncementsPage> {
  final _listEntrance = LwpListEntranceController();

  @override
  void dispose() {
    _listEntrance.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<UserAnnouncementBloc>().add(const LoadUserAnnouncements());
    super.initState();
  }

  bool _hasImage(UserAnnouncement announcement) =>
      (announcement.imagePublicId ?? '').trim().isNotEmpty;

  void _dismiss(String id) {
    HapticFeedback.mediumImpact();
    context.read<UserAnnouncementBloc>().add(DismissUserAnnouncement(id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<UserAnnouncementBloc, UserAnnouncementState>(
      listener: (context, state) {},
      child: LwpChromeScaffold(
        title: context.l10n.announcementsTitle,
        body: BlocBuilder<UserAnnouncementBloc, UserAnnouncementState>(
          builder: (context, state) {
            if (state is UserAnnouncementSuccess) {
              if (state.userAnnouncements.isEmpty) {
                return LwpEmpty(message: context.l10n.announcementsEmpty);
              }

              final unread = state.userAnnouncements
                  .where((a) => a.isRead != true)
                  .length;

              return LwpListEntranceScope(
                controller: _listEntrance,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        LwpSpacing.md,
                        LwpSpacing.xs,
                        LwpSpacing.md,
                        LwpSpacing.xs,
                      ),
                      child: Text(
                        unread > 0
                            ? context.l10n.announcementsUnreadCount(unread)
                            : context.l10n.announcementsAllRead,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: LwpSpacing.xxl),
                        itemCount: state.userAnnouncements.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          thickness: 1,
                          color: theme.dividerColor.withValues(alpha: 0.35),
                        ),
                        itemBuilder: (context, index) {
                          final announcement =
                              state.userAnnouncements[index];
                          final id = announcement.id ?? 'announcement-$index';

                          return Dismissible(
                            key: Key(id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              if (announcement.id == null) return;
                              _dismiss(announcement.id!);
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(
                                right: LwpSpacing.lg,
                              ),
                              color: theme.primaryColor.withValues(alpha: 0.16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 20,
                                    color: theme.brightness == Brightness.dark
                                        ? const Color(0xFF9FD0F3)
                                        : theme.primaryColor,
                                  ),
                                  const SizedBox(width: LwpSpacing.xs),
                                  Text(
                                    context.l10n.announcementsMarkAsRead,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.brightness == Brightness.dark
                                          ? const Color(0xFF9FD0F3)
                                          : theme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            child: LwpListEntrance(
                              id: id,
                              child: _AnnouncementRow(
                                announcement: announcement,
                                hasImage: _hasImage(announcement),
                                onTap: () => _showAnnouncementDetails(
                                  context,
                                  announcement,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is UserAnnouncementError) {
              return const LwpError();
            }

            return LwpSkeletonList.text();
          },
        ),
      ),
    );
  }

  void _showAnnouncementDetails(
    BuildContext context,
    UserAnnouncement announcement,
  ) {
    final theme = Theme.of(context);
    final hasImage = _hasImage(announcement);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.88,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: LwpRadii.lgTop,
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(sheetContext).bottom + LwpSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: LwpSpacing.sm,
                      bottom: LwpSpacing.xs,
                    ),
                    child: LwpSheetHandle(),
                  ),
                ),
                if (hasImage)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      LwpSpacing.md,
                      LwpSpacing.xs,
                      LwpSpacing.md,
                      LwpSpacing.md,
                    ),
                    child: ClipRRect(
                      borderRadius: LwpRadii.lgAll,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CldImageWidget(
                          publicId: announcement.imagePublicId!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LwpSpacing.lg,
                    LwpSpacing.xs,
                    LwpSpacing.lg,
                    LwpSpacing.sm,
                  ),
                  child: Text(
                    announcement.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      height: 1.2,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      LwpSpacing.lg,
                      0,
                      LwpSpacing.lg,
                      LwpSpacing.md,
                    ),
                    child: Text(
                      announcement.body,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyLarge?.color
                            ?.withValues(alpha: 0.88),
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LwpSpacing.md,
                    0,
                    LwpSpacing.md,
                    LwpSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: Text(context.l10n.announcementsClose),
                        ),
                      ),
                      const SizedBox(width: LwpSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            final id = announcement.id;
                            if (id == null) return;
                            _dismiss(id);
                          },
                          child: Text(context.l10n.announcementsMarkAsRead),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnnouncementRow extends StatelessWidget {
  const _AnnouncementRow({
    required this.announcement,
    required this.hasImage,
    required this.onTap,
  });

  final UserAnnouncement announcement;
  final bool hasImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = (announcement.createdAt ?? '').isNotEmpty
        ? DateFormatter.formatDate(announcement.createdAt!)
        : null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LwpSpacing.md,
          vertical: LwpSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.25,
                      height: 1.25,
                    ),
                  ),
                  if (announcement.body.trim().isNotEmpty) ...[
                    const SizedBox(height: LwpSpacing.xxs),
                    Text(
                      announcement.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                        height: 1.45,
                      ),
                    ),
                  ],
                  if (date != null) ...[
                    const SizedBox(height: LwpSpacing.xs),
                    Text(
                      date,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.hintColor.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: LwpSpacing.sm),
              ClipRRect(
                borderRadius: LwpRadii.smAll,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: CldImageWidget(
                    publicId: announcement.imagePublicId!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
