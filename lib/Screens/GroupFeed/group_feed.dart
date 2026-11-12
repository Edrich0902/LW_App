import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lw_app/Blocs/GroupDetail/group_detail_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Group/group.dart';
import 'package:lw_app/Models/Group/group_post.dart';
import 'package:lw_app/Screens/GroupPostEdit/group_post_edit.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Utils/quill_helper.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Widgets/Glass/lwp_glass_fab.dart';
import 'package:lw_app/Widgets/Glass/lwp_top_bar.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';

class GroupFeedPage extends StatelessWidget {
  final String groupId;

  const GroupFeedPage({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupDetailBloc()..add(LoadGroupDetail(groupId)),
      child: _GroupFeedView(groupId: groupId),
    );
  }
}

class _GroupFeedView extends StatefulWidget {
  final String groupId;

  const _GroupFeedView({
    required this.groupId,
  });

  @override
  State<_GroupFeedView> createState() => _GroupFeedViewState();
}

class _GroupFeedViewState extends State<_GroupFeedView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupDetailBloc, GroupDetailState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        if (state.message == null || state.message!.isEmpty) return;

        if (state.isErrorMessage) {
          LwpSnackbar.showError(context, state.message!);
        } else {
          LwpSnackbar.showSuccess(context, state.message!);
        }

        context.read<GroupDetailBloc>().add(const ClearGroupDetailMessage());
      },
      child: BlocBuilder<GroupDetailBloc, GroupDetailState>(
        builder: (context, state) {
          final group = state.group;

          if (state.status == GroupDetailStatus.loading &&
              group == null &&
              !state.isRefreshing) {
            return LwpChromeScaffold(
              title: context.l10n.groupFeedTitle,
              body: LwpSkeletonList.text(),
            );
          }

          if (state.status == GroupDetailStatus.error && group == null) {
            return LwpChromeScaffold(
              title: context.l10n.groupFeedTitle,
              body: LwpError(
                message: state.error ?? context.l10n.groupFeedLoadError,
                onRetry: () => context
                    .read<GroupDetailBloc>()
                    .add(LoadGroupDetail(widget.groupId)),
              ),
            );
          }

          if (group == null) {
            return LwpChromeScaffold(
              title: context.l10n.groupFeedTitle,
              body: LwpEmpty(message: context.l10n.groupFeedGroupNotFound),
            );
          }

          if (!group.isActiveMember && !group.isLeader) {
            return LwpChromeScaffold(
              title: group.title,
              body: LwpEmpty(message: context.l10n.groupFeedMembersOnly),
            );
          }

          return Scaffold(
            floatingActionButton: group.isLeader
                ? LwpGlassFab.extended(
                    heroTag: 'group-feed-fab',
                    onPressed: state.isFeedActionInProgress
                        ? null
                        : () => _openCreatePost(context),
                    icon: const Icon(Icons.add),
                    label: Text(context.l10n.groupPostNewTitle),
                  )
                : null,
            body: Stack(
              fit: StackFit.expand,
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<GroupDetailBloc>()
                        .add(RefreshGroupDetail(widget.groupId));
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _GroupFeedHero(
                          group: group,
                          postCount: state.posts.length,
                        ),
                      ),
                      if (state.posts.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              LwpSpacing.md,
                              LwpSpacing.sm,
                              LwpSpacing.md,
                              LwpSpacing.xxl,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _UpdatesLabel(count: 0),
                                const SizedBox(height: LwpSpacing.sm),
                                Expanded(
                                  child: Center(
                                    child: LwpEmpty(
                                      message: context.l10n.groupFeedEmpty,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              LwpSpacing.md,
                              LwpSpacing.sm,
                              LwpSpacing.md,
                              LwpSpacing.xs,
                            ),
                            child: _UpdatesLabel(count: state.posts.length),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            LwpSpacing.md,
                            0,
                            LwpSpacing.md,
                            MediaQuery.paddingOf(context).bottom +
                                (group.isLeader ? 96 : LwpSpacing.xl),
                          ),
                          sliver: SliverList.separated(
                            itemCount: state.posts.length,
                            itemBuilder: (context, index) {
                              final post = state.posts[index];
                              final isLeader = group.isLeader;
                              return _GroupFeedPostCard(
                                post: post,
                                isBusy: state.isFeedActionInProgress,
                                onEdit: post.isAuthor
                                    ? () => _openEditPost(context, post)
                                    : null,
                                onDelete: post.isAuthor
                                    ? () => _confirmDeletePost(context, post)
                                    : null,
                                onPin: isLeader
                                    ? () =>
                                        context.read<GroupDetailBloc>().add(
                                              TogglePinPost(
                                                groupId: widget.groupId,
                                                post: post,
                                              ),
                                            )
                                    : null,
                                onReact: (reactionType) =>
                                    context.read<GroupDetailBloc>().add(
                                          ToggleGroupPostReaction(
                                            groupId: widget.groupId,
                                            post: post,
                                            reactionType: reactionType,
                                          ),
                                        ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: LwpSpacing.sm),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LwpTopBar(
                    title: group.title,
                    showBack: true,
                    showActions: false,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openCreatePost(BuildContext context) async {
    final draft = await Navigator.push<GroupPostDraft>(
      context,
      MaterialPageRoute(
        builder: (_) => const GroupPostEditPage(),
      ),
    );

    if (!context.mounted || draft == null) return;

    context.read<GroupDetailBloc>().add(
          CreateGroupPost(
            groupId: widget.groupId,
            title: draft.title,
            content: draft.content,
          ),
        );
  }

  Future<void> _openEditPost(BuildContext context, GroupPost post) async {
    final draft = await Navigator.push<GroupPostDraft>(
      context,
      MaterialPageRoute(
        builder: (_) => GroupPostEditPage(post: post),
      ),
    );

    if (!context.mounted || draft == null) return;

    context.read<GroupDetailBloc>().add(
          UpdateExistingGroupPost(
            groupId: widget.groupId,
            postId: post.id,
            title: draft.title,
            content: draft.content,
          ),
        );
  }

  Future<void> _confirmDeletePost(BuildContext context, GroupPost post) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.groupFeedDeletePostTitle),
            content: Text(
              context.l10n.groupFeedDeletePostBody(_postTitle(context, post)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.commonCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.commonDelete),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    context.read<GroupDetailBloc>().add(
          DeleteGroupPost(
            groupId: widget.groupId,
            postId: post.id,
          ),
        );
  }
}

class _UpdatesLabel extends StatelessWidget {
  final int count;

  const _UpdatesLabel({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.groupFeedUpdatesLabel.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.hintColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Text(
          '$count',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }
}

class _GroupFeedHero extends StatelessWidget {
  final Group group;
  final int postCount;

  const _GroupFeedHero({
    required this.group,
    required this.postCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topClearance =
        LwpTopBar.heightOf(context) + LwpSpacing.xxl + LwpSpacing.lg;
    const contentBlock = 132.0;
    final heroHeight = topClearance + contentBlock + LwpSpacing.md;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CldImageWidget(
            publicId: group.bannerPublicId ?? 'samples/cloudinary-icon',
            width: double.infinity,
            height: heroHeight,
            fit: BoxFit.cover,
          ),
          // Dark scrim under chips/title so white type stays readable in
          // light mode and on bright banners; soft handoff into the page.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.28),
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.72),
                  theme.scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.28, 0.58, 0.88, 1.0],
              ),
            ),
          ),
          Positioned(
            left: LwpSpacing.md,
            right: LwpSpacing.md,
            top: topClearance,
            bottom: LwpSpacing.md,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: LwpSpacing.xs,
                    runSpacing: LwpSpacing.xs,
                    children: [
                      _HeroChip(
                        icon: Icons.people_outline,
                        label: context.l10n.groupMembersCount(group.memberCount),
                      ),
                      _HeroChip(
                        icon: Icons.dynamic_feed_outlined,
                        label: context.l10n.groupFeedPostCount(postCount),
                      ),
                      if (group.isLeader)
                        _HeroChip(
                          icon: Icons.shield_outlined,
                          label: context.l10n.groupLeaderBadge,
                          accent: Colors.amber,
                        ),
                    ],
                  ),
                  const SizedBox(height: LwpSpacing.sm),
                  Text(
                    group.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (group.description.trim().isNotEmpty) ...[
                    const SizedBox(height: LwpSpacing.xs),
                    Text(
                      group.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? accent;

  const _HeroChip({
    required this.icon,
    required this.label,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accent ?? theme.primaryColor;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: LwpSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(LwpRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupFeedPostCard extends StatelessWidget {
  final GroupPost post;
  final bool isBusy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final ValueChanged<String> onReact;

  const _GroupFeedPostCard({
    required this.post,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
    required this.onPin,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : LightColors.outline;
    final pinnedBorder = theme.primaryColor.withValues(alpha: 0.35);
    final author = post.displayAuthorName;
    final when = _formatOptionalDate(post.updatedAt ?? post.createdAt);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: LwpRadii.lgAll,
        border: Border.all(
          color: post.isPinned ? pinnedBorder : line,
        ),
        gradient: post.isPinned
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.primaryColor.withValues(alpha: 0.08),
                  theme.cardColor,
                ],
                stops: const [0.0, 0.45],
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(LwpSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.isPinned) ...[
              Row(
                children: [
                  Icon(
                    Icons.push_pin,
                    size: 12,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: LwpSpacing.xxs),
                  Text(
                    context.l10n.groupFeedPinned.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LwpSpacing.sm),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.12),
                  child: Text(
                    _initials(author),
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: LwpSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (when.isNotEmpty)
                        Text(
                          when,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor),
                        ),
                    ],
                  ),
                ),
                if (onEdit != null || onDelete != null || onPin != null)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                      if (value == 'pin') onPin?.call();
                    },
                    itemBuilder: (context) => [
                      if (onPin != null)
                        PopupMenuItem<String>(
                          value: 'pin',
                          child: Row(
                            children: [
                              Icon(
                                post.isPinned
                                    ? Icons.push_pin_outlined
                                    : Icons.push_pin,
                                size: 20,
                              ),
                              const SizedBox(width: LwpSpacing.sm),
                              Text(
                                post.isPinned
                                    ? context.l10n.groupFeedUnpin
                                    : context.l10n.groupFeedPin,
                              ),
                            ],
                          ),
                        ),
                      if (onEdit != null)
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined, size: 20),
                              const SizedBox(width: LwpSpacing.sm),
                              Text(context.l10n.groupPostEditTitle),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              const SizedBox(width: LwpSpacing.sm),
                              Text(
                                context.l10n.commonDelete,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            if ((post.title ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: LwpSpacing.sm),
              Text(
                post.title!.trim(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
            const SizedBox(height: LwpSpacing.sm),
            _GroupPostContent(content: post.content),
            const SizedBox(height: LwpSpacing.sm),
            Divider(height: 1, thickness: 1, color: line),
            const SizedBox(height: LwpSpacing.sm),
            Wrap(
              spacing: LwpSpacing.xs,
              runSpacing: LwpSpacing.xs,
              children: GroupPostReactionType.values
                  .map(
                    (reactionType) => _ReactionChip(
                      label: GroupPostReactionType.label(
                        context.l10n,
                        reactionType,
                      ),
                      count: post.reactionCountFor(reactionType),
                      icon: _reactionIcon(reactionType),
                      isSelected: post.currentUserReaction == reactionType,
                      isBusy: isBusy,
                      onTap: () => onReact(reactionType),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final bool isSelected;
  final bool isBusy;
  final VoidCallback onTap;

  const _ReactionChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.isSelected,
    required this.isBusy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : LightColors.outline;
    final foreground = isSelected
        ? theme.primaryColor
        : theme.textTheme.bodyMedium?.color;

    return Material(
      color: isSelected
          ? theme.primaryColor.withValues(alpha: 0.12)
          : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.35)
              : line,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isBusy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LwpSpacing.sm,
            vertical: LwpSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 6),
              Text(
                '$label · $count',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupPostContent extends StatefulWidget {
  final String content;

  const _GroupPostContent({
    required this.content,
  });

  @override
  State<_GroupPostContent> createState() => _GroupPostContentState();
}

class _GroupPostContentState extends State<_GroupPostContent> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = _buildController(widget.content);
  }

  @override
  void didUpdateWidget(covariant _GroupPostContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _controller.dispose();
      _controller = _buildController(widget.content);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: QuillEditor(
        controller: _controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
        config: const QuillEditorConfig(
          scrollable: false,
          expands: false,
          padding: EdgeInsets.zero,
          showCursor: false,
          enableInteractiveSelection: false,
        ),
      ),
    );
  }

  QuillController _buildController(String content) {
    return QuillController(
      document: QuillHelper.fromContent(content),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  }
}

String _postTitle(BuildContext context, GroupPost post) {
  final title = (post.title ?? '').trim();
  if (title.isNotEmpty) return '"$title"';

  return context.l10n.groupFeedThisPost;
}

String _formatOptionalDate(String? date) {
  final value = (date ?? '').trim();
  if (value.isEmpty) return '';
  return DateFormatter.formatDate(value);
}

String _initials(String name) {
  final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

IconData _reactionIcon(String reactionType) {
  switch (reactionType) {
    case GroupPostReactionType.amen:
      return Icons.thumb_up_alt_outlined;
    case GroupPostReactionType.prayer:
      return Icons.volunteer_activism_outlined;
    case GroupPostReactionType.heart:
      return Icons.favorite_border;
    default:
      return Icons.add_reaction_outlined;
  }
}
