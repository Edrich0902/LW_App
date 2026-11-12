import 'package:flutter/material.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/SocialMedia/social_media_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';
import 'package:lw_app/Widgets/LwpListEntrance/lwp_list_entrance.dart';

class SocialMediaPage extends StatefulWidget {
  const SocialMediaPage({super.key});

  @override
  State<SocialMediaPage> createState() => _SocialMediaPageState();
}

class _SocialMediaPageState extends State<SocialMediaPage> {
  final _listEntrance = LwpListEntranceController();

  @override
  void dispose() {
    _listEntrance.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<SocialMediaBloc>().add(const LoadSocialMedia());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final socialMediaBloc = BlocProvider.of<SocialMediaBloc>(context);
    final theme = Theme.of(context);
    final openColor = theme.brightness == Brightness.dark
        ? const Color(0xFF9FD0F3)
        : theme.primaryColor;

    return BlocListener<SocialMediaBloc, SocialMediaState>(
      listener: (context, state) {},
      child: LwpChromeScaffold(
        title: context.l10n.dashboardFollowUs,
        showDefaultActions: true,
        body: BlocBuilder<SocialMediaBloc, SocialMediaState>(
          builder: (context, state) {
            if (state is SocialMediaLoading) {
              return LwpSkeletonList.text();
            } else if (state is SocialMediaSuccess) {
              if (state.socialMedia.isNotEmpty) {
                return LwpListEntranceScope(
                  controller: _listEntrance,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _listEntrance.bump();
                      socialMediaBloc.add(const LoadSocialMedia());
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        LwpSpacing.md,
                        LwpSpacing.lg,
                        LwpSpacing.md,
                        LwpSpacing.xxl,
                      ),
                      itemCount: state.socialMedia.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.dividerColor.withValues(alpha: 0.35),
                      ),
                      itemBuilder: (context, index) {
                        final social = state.socialMedia[index];
                        return LwpListEntrance(
                          id: social.id ?? 'social-$index',
                          child: InkWell(
                            onTap: () {
                              if (social.link != null &&
                                  social.link!.isNotEmpty) {
                                launchUrl(
                                  Uri.parse(social.link!),
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: LwpSpacing.sm + 2,
                                horizontal: LwpSpacing.xxs,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor
                                          .withValues(alpha: 0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getSocialMediaIcon(social.type ?? ''),
                                      color: theme.primaryColor,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: LwpSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      social.title ?? '',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    context.l10n.socialMediaOpen.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: openColor,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                return LwpEmpty(message: context.l10n.socialMediaEmpty);
              }
            } else {
              return const LwpError();
            }
          },
        ),
      ),
    );
  }

  IconData _getSocialMediaIcon(String type) {
    switch (type.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt_rounded;
      case 'youtube':
        return Icons.play_circle_fill_rounded;
      case 'tiktok':
        return Icons.music_note_rounded;
      case 'threads':
        return Icons.alternate_email_rounded;
      case 'x':
        return Icons.close_rounded;
      default:
        return Icons.link_rounded;
    }
  }
}
