import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/GroupDetail/group_detail_bloc.dart';
import 'package:lw_app/Models/Group/group_post.dart';
import 'package:lw_app/Screens/GroupPostEdit/group_post_edit.dart';
import 'package:lw_app/Themes/custom_theme.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Utils/quill_helper.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
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

          return Scaffold(
            appBar: AppBar(
              title: Text(group?.title ?? context.l10n.groupFeedTitle),
            ),
            floatingActionButton: group?.isLeader == true
                ? FloatingActionButton.extended(
                    onPressed: state.isFeedActionInProgress
                        ? null
                        : () => _openCreatePost(context),
                    icon: const Icon(Icons.post_add_outlined),
                    label: Text(context.l10n.groupPostNewTitle),
                  )
                : null,
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, GroupDetailState state) {
    if (state.status == GroupDetailStatus.loading &&
        state.group == null &&
        !state.isRefreshing) {
      return LwpLoader(message: context.l10n.groupFeedLoading);
    }

    if (state.status == GroupDetailStatus.error && state.group == null) {
      return LwpError(
        message: state.error ?? 'Kon nie groepfeed laai nie.',
        onRetry: () => context
            .read<GroupDetailBloc>()
            .add(LoadGroupDetail(widget.groupId)),
      );
    }

    final group = state.group;
    if (group == null) {
      return LwpEmpty(message: context.l10n.groupFeedGroupNotFound);
    }

    if (!group.isActiveMember && !group.isLeader) {
      return const LwpEmpty(
        message: 'Jy moet eers \'n aktiewe lid van hierdie groep wees.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<GroupDetailBloc>().add(RefreshGroupDetail(widget.groupId));
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _GroupFeedHeader(
              title: group.title,
              description: group.description,
              bannerPublicId: group.bannerPublicId,
              bannerUrl: group.bannerUrl,
              memberCount: group.memberCount,
              postCount: state.posts.length,
              isLeader: group.isLeader,
            ),
          ),
          if (state.posts.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(LwpSpacing.xl),
                  child: LwpEmpty(
                    message: 'Nog geen plasings in hierdie groep nie.',
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                LwpSpacing.md,
                0,
                LwpSpacing.md,
                LwpSpacing.xxl,
              ),
              sliver: SliverList.separated(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  final isLeader = state.group?.isLeader == true;
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
                        ? () => context.read<GroupDetailBloc>().add(
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
                    const SizedBox(height: LwpSpacing.md),
              ),
            ),
        ],
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
                child: const Text('Kanselleer'),
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

class _GroupFeedHeader extends StatelessWidget {
  final String title;
  final String description;
  final String? bannerPublicId;
  final String? bannerUrl;
  final int memberCount;
  final int postCount;
  final bool isLeader;

  const _GroupFeedHeader({
    required this.title,
    required this.description,
    required this.bannerPublicId,
    required this.bannerUrl,
    required this.memberCount,
    required this.postCount,
    required this.isLeader,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(LwpSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: LwpRadii.lgAll,
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withValues(alpha: 0.95),
              theme.primaryColor.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CldImageWidget(
                    publicId: bannerPublicId ?? 'samples/cloudinary-icon',
                    fit: BoxFit.cover,
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.35)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(LwpSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: LwpSpacing.xs,
                    runSpacing: LwpSpacing.xs,
                    children: [
                      _HeaderChip(
                    label: context.l10n.groupMembersCount(memberCount),
                        icon: Icons.people_outline,
                      ),
                      _HeaderChip(
                        label: context.l10n.groupFeedPostCount(postCount),
                        icon: Icons.dynamic_feed_outlined,
                      ),
                      if (isLeader)
                        const _HeaderChip(
                          label: 'Leier',
                          icon: Icons.shield_outlined,
                        ),
                    ],
                  ),
                  const SizedBox(height: LwpSpacing.md),
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: LwpSpacing.sm),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.5,
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
}

class _HeaderChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HeaderChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LwpSpacing.sm,
        vertical: LwpSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(LwpRadii.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: LwpSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LwpSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: LwpRadii.lgAll,
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white12
              : LightColors.outline,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.isPinned) ...[
            Row(
              children: [
                Icon(Icons.push_pin, size: 14, color: theme.primaryColor),
                const SizedBox(width: LwpSpacing.xxs),
                Text(
                  context.l10n.groupFeedPinned,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w700,
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
                radius: 24,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.12),
                child: Icon(
                  Icons.campaign_outlined,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: LwpSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.displayAuthorName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: LwpSpacing.xxs),
                    Text(
                      _formatOptionalDate(post.updatedAt ?? post.createdAt),
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
                            const Icon(Icons.delete_outline, size: 20, color: Colors.red),
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
            const SizedBox(height: LwpSpacing.md),
            Text(
              post.title!.trim(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: LwpSpacing.md),
          _GroupPostContent(content: post.content),
          const SizedBox(height: LwpSpacing.md),
          Divider(color: theme.dividerColor),
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
    final foregroundColor =
        isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color;

    return ActionChip(
      onPressed: isBusy ? null : onTap,
      avatar: Icon(icon, size: 18, color: foregroundColor),
      label: Text('$label ($count)'),
      backgroundColor: isSelected
          ? theme.primaryColor.withValues(alpha: 0.12)
          : theme.cardColor,
      side: BorderSide(
        color: isSelected
            ? theme.primaryColor.withValues(alpha: 0.35)
            : theme.dividerColor,
      ),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        color: foregroundColor,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
