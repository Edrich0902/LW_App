import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/Sermons/sermons_bloc.dart';
import 'package:lw_app/Screens/Auth/login.dart';
import 'package:lw_app/Screens/Sermons/sermons.dart';
import 'package:lw_app/Screens/Sermons/sermon_detail.dart';
import 'package:lw_app/Screens/UpcomingEvents/upcoming_events.dart';
import 'package:lw_app/Screens/SocialMedia/social_media.dart';
import 'package:lw_app/Screens/Courses/courses.dart';
import 'package:lw_app/Screens/FirstTimeVisitor/first_time_visitor_screen.dart';
import 'package:lw_app/Screens/TithesOfferings/tithes_offerings.dart';
import 'package:lw_app/Screens/PrayerRequests/prayer_requests.dart';
import 'package:lw_app/Screens/PastoralBlog/pastoral_blog.dart';
import 'package:lw_app/Screens/PastoralBlog/pastoral_blog_reader.dart';
import 'package:lw_app/Blocs/PastoralBlog/pastoral_blog_bloc.dart';
import 'package:lw_app/Widgets/Dashboard/dashboard_hero_blog.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/Dashboard/dashboard_grid_card.dart';
import 'package:lw_app/Widgets/Dashboard/dashboard_hero_sermon.dart';
import 'package:lw_app/Widgets/Dashboard/dashboard_votd_card.dart';
import 'package:lw_app/Blocs/Votd/votd_bloc.dart';
import 'package:lw_app/Blocs/Votd/votd_event.dart';
import 'package:lw_app/Blocs/Votd/votd_state.dart';
import 'package:lw_app/Blocs/Bible/bible_bloc.dart';
import 'package:lw_app/Blocs/Bible/bible_event.dart';
import 'package:lw_app/Blocs/Bible/bible_state.dart';
import 'package:lw_app/Blocs/User/user_bloc.dart';
import 'package:lw_app/Screens/Bible/bible.dart';
import 'package:lw_app/Screens/Bible/verse_image_editor.dart';
import 'package:lw_app/Utils/verse_image_formatter.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/Dashboard/dashboard_greeting.dart';

class DashPage extends StatefulWidget {
  const DashPage({super.key});

  @override
  State<DashPage> createState() => _DashPageState();
}

class _DashPageState extends State<DashPage> {
  @override
  void initState() {
    super.initState();
    context.read<SermonsBloc>().add(LoadSermons());
    context.read<PastoralBlogBloc>().add(const LoadPastoralBlog());
    final userBloc = context.read<UserBloc>();
    if (userBloc.state is UserInitial) {
      userBloc.add(LoadUser());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadVotdForCurrentBibleVersion(context);
    });
  }

  void _loadVotdForCurrentBibleVersion(BuildContext context) {
    final bibleState = context.read<BibleBloc>().state;
    context.read<VotdBloc>().add(LoadVotd(
          version: bibleState is BibleLoaded ? bibleState.currentVersion : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UnAuthedState) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        } else if (state is AuthErrorState) {
          LwpSnackbar.showError(context, context.l10n.profileSignOutFailed);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.navHome),
          actions: const <Widget>[
            LwpAnnouncementButton(),
            ProfileActionButton()
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const DashboardGreeting(),
              const SizedBox(height: 8),
              BlocBuilder<SermonsBloc, SermonsState>(
                builder: (context, state) {
                  if (state is SermonsSuccess && state.sermons.isNotEmpty) {
                    return DashboardHeroSermon(
                      sermon: state.sermons.first,
                      onTap: () {
                        if (state.youtubeVideos.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SermonDetailPage(
                                    video: state.youtubeVideos.first)),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SermonsPage()),
                          );
                        }
                      },
                    );
                  } else if (state is SermonsLoading) {
                    return const _DashboardPlaceholder(
                      child: LwpLoader(message: ""),
                    );
                  } else if (state is SermonsError) {
                    return _DashboardPlaceholder(
                      child: LwpError(
                        message: state.error,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              BlocBuilder<PastoralBlogBloc, PastoralBlogState>(
                builder: (context, state) {
                  if (state.status == PastoralBlogStatus.success && state.posts.isNotEmpty) {
                    final latestPost = state.posts.first;
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: DashboardHeroBlog(
                        post: latestPost,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PastoralBlogReaderPage(
                                postId: latestPost.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),
              BlocListener<BibleBloc, BibleState>(
                listenWhen: (previous, current) {
                  if (current is! BibleLoaded) return false;
                  if (previous is! BibleLoaded) return true;
                  return previous.currentVersion.id !=
                      current.currentVersion.id;
                },
                listener: (context, state) {
                  if (state is BibleLoaded) {
                    context
                        .read<VotdBloc>()
                        .add(LoadVotd(version: state.currentVersion));
                  }
                },
                child: BlocBuilder<VotdBloc, VotdState>(
                  builder: (context, state) {
                    if (state is VotdSuccess) {
                      return DashboardVotdCard(
                        votd: state.votd,
                        onTap: () {
                          final parts = state.votd.passageId.split('.');
                          final verseNum = parts.length > 2
                              ? parts[2].split('-').first
                              : null;
                          context.read<BibleBloc>().add(LoadSpecificPassage(
                                version: state.votd.version,
                                book: state.votd.book,
                                chapter: state.votd.chapter,
                                focusVerseNumber: verseNum,
                              ));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BiblePage()),
                          );
                        },
                        onCreateImage: () {
                          final draft =
                              buildVerseImageDraftFromVotd(state.votd);
                          if (draft == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VerseImageEditorScreen(draft: draft),
                            ),
                          );
                        },
                      );
                    } else if (state is VotdLoading) {
                      return const _DashboardPlaceholder(
                        child: LwpLoader(message: ""),
                      );
                    } else if (state is VotdError) {
                      return _DashboardPlaceholder(
                        height: null,
                        padding: const EdgeInsets.all(LwpSpacing.md),
                        child: LwpError(
                          message: state.getLocalizedMessage(context),
                          onRetry: () =>
                              _loadVotdForCurrentBibleVersion(context),
                        ),
                      );
                    }
                    // Return nothing if initial - dashboard should still work
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  DashboardGridCard(
                    title: context.l10n.dashboardUpcomingEvents,
                    icon: Icons.event,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UpcomingEventsPage()),
                      );
                    },
                  ),
                  DashboardGridCard(
                    title: context.l10n.dashboardTithesOfferings,
                    icon: Icons.volunteer_activism,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const TithesOfferingsScreen()),
                      );
                    },
                  ),
                  DashboardGridCard(
                    title: context.l10n.dashboardFirstTimeVisitor,
                    icon: Icons.waving_hand,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const FirstTimeVisitorScreen()),
                      );
                    },
                  ),
                  DashboardGridCard(
                    title: context.l10n.dashboardFollowUs,
                    icon: Icons.share,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SocialMediaPage()),
                      );
                    },
                  ),
                  DashboardGridCard(
                    title: context.l10n.dashboardCourses,
                    icon: Icons.school,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CoursesPage()),
                      );
                    },
                  ),
                  DashboardGridCard(
                    title: context.l10n.dashboardPrayerRequests,
                    icon: Icons.favorite_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrayerRequestsPage(),
                        ),
                      );
                    },
                  ),
                  DashboardGridCard(
                    title: context.l10n.dashboardBlog,
                    icon: Icons.article_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PastoralBlogPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardPlaceholder extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const _DashboardPlaceholder({
    required this.child,
    this.height = 180,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: LwpRadii.lgAll,
      ),
      child: child,
    );
  }
}
