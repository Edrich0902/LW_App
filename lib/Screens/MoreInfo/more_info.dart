import 'package:lw_app/Screens/MoreInfo/roleplayer_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/MoreInfo/more_info_bloc.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/Glass/lwp_shell_insets.dart';
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';
import 'package:collection/collection.dart';
import 'package:lw_app/Widgets/LwpListEntrance/lwp_list_entrance.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Models/Roleplayer/roleplayer.dart';

class MoreInfoPage extends StatefulWidget {
  const MoreInfoPage({super.key});

  @override
  State<MoreInfoPage> createState() => _MoreInfoPageState();
}

class _MoreInfoPageState extends State<MoreInfoPage> {
  final _listEntrance = LwpListEntranceController();

  @override
  void dispose() {
    _listEntrance.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<MoreInfoBloc>().add(const LoadMoreInfo());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<MoreInfoBloc, MoreInfoState>(
      builder: (context, state) {
        if (state is MoreInfoLoading) {
          return Scaffold(
            body: Padding(
              padding: LwpShellInsets.paddingOf(context),
              child: LwpSkeletonList.text(itemCount: 6),
            ),
          );
        } else if (state is MoreInfoSuccess) {
          final mission = state.data
              .firstWhereOrNull((m) => m.key == 'mission_statement');
          final vision = state.data
              .firstWhereOrNull((v) => v.key == 'vision_statement');

          return Scaffold(
            body: LwpListEntranceScope(
              controller: _listEntrance,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  LwpSpacing.md,
                  LwpShellInsets.top(context) + LwpSpacing.xs,
                  LwpSpacing.md,
                  LwpShellInsets.bottom(context) + LwpSpacing.md,
                ),
                children: [
                  if (mission != null || vision != null) ...[
                    if (mission != null) ...[
                      Text(
                        context.l10n.moreInfoMission.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: LwpSpacing.xs),
                      Text(
                        mission.content ?? '',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          height: 1.3,
                        ),
                      ),
                    ],
                    if (vision != null) ...[
                      SizedBox(
                        height: mission != null ? LwpSpacing.sm : 0,
                      ),
                      Text(
                        vision.content ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: LwpSpacing.lg,
                      ),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.dividerColor.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                  Text(
                    context.l10n.moreInfoTeam.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.hintColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: LwpSpacing.sm),
                  ...List.generate(state.roleplayers.length, (index) {
                    final roleplayer = state.roleplayers[index];
                    final isLast = index == state.roleplayers.length - 1;
                    return LwpListEntrance(
                      id: roleplayer.id ?? 'roleplayer-$index',
                      child: _LeadershipRow(
                        roleplayer: roleplayer,
                        showDivider: !isLast,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoleplayerDetailScreen(
                                roleplayer: roleplayer,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(body: LwpError());
        }
      },
    );
  }
}

class _LeadershipRow extends StatelessWidget {
  const _LeadershipRow({
    required this.roleplayer,
    required this.onTap,
    required this.showDivider,
  });

  final Roleplayer roleplayer;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: LwpSpacing.sm),
            child: Row(
              children: [
                Hero(
                  tag: 'roleplayer_image_${roleplayer.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: LwpRadii.smAll,
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: CldImageWidget(
                          publicId:
                              (roleplayer.profilePublicId ?? '').isEmpty
                                  ? 'samples/cloudinary-icon'
                                  : roleplayer.profilePublicId!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: LwpSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roleplayer.fullname ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((roleplayer.title ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          roleplayer.title!,
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
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor.withValues(alpha: 0.35),
          ),
      ],
    );
  }
}
