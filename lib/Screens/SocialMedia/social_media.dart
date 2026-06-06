import 'package:flutter/material.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/SocialMedia/social_media_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';

class SocialMediaPage extends StatefulWidget {
  const SocialMediaPage({super.key});

  @override
  State<SocialMediaPage> createState() => _SocialMediaPageState();
}

class _SocialMediaPageState extends State<SocialMediaPage> {
  @override
  void initState() {
    context.read<SocialMediaBloc>().add(const LoadSocialMedia());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SocialMediaBloc socialMediaBloc = BlocProvider.of<SocialMediaBloc>(context);

    return BlocListener<SocialMediaBloc, SocialMediaState>(
      listener: (context, state) {
        // Listen to state updates and execute logic here
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.dashboardFollowUs),
          actions: const <Widget>[
            LwpAnnouncementButton(),
            ProfileActionButton()
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<SocialMediaBloc, SocialMediaState>(
            builder: (context, state) {
              if (state is SocialMediaLoading) {
                return LwpLoader(message: context.l10n.socialMediaLoading);
              } else if (state is SocialMediaSuccess) {
                if (state.socialMedia.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async =>
                        socialMediaBloc.add(const LoadSocialMedia()),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 24.0),
                      itemCount: state.socialMedia.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16.0),
                      itemBuilder: (BuildContext context, int index) {
                        final social = state.socialMedia[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: LwpRadii.lgAll,
                          ),
                          child: InkWell(
                            borderRadius: LwpRadii.lgAll,
                            onTap: () {
                              if (social.link != null &&
                                  social.link!.isNotEmpty) {
                                launchUrl(Uri.parse(social.link!),
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: LwpRadii.smAll,
                                    ),
                                    child: Icon(
                                      _getSocialMediaIcon(social.type ?? ''),
                                      color: Theme.of(context).primaryColor,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Text(
                                      social.title ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: 0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
