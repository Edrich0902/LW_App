import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Auth/auth_bloc.dart';
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
import 'package:lw_app/Screens/Bible/bible.dart';

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
          LwpSnackbar.showError(context, "Fout, kon nie uitteken nie");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tuis'),
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
                    return Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const LwpLoader(message: ""),
                    );
                  } else if (state is SermonsError) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: LwpError(
                        message: state.error,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<VotdBloc, VotdState>(
                builder: (context, state) {
                  if (state is VotdSuccess) {
                    return DashboardVotdCard(
                      votd: state.votd,
                      onTap: () {
                        context.read<BibleBloc>().add(LoadSpecificPassage(
                              version: state.votd.version,
                              book: state.votd.book,
                              chapter: state.votd.chapter,
                            ));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BiblePage()),
                        );
                      },
                    );
                  } else if (state is VotdLoading) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const LwpLoader(message: ""),
                    );
                  } else if (state is VotdError) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: LwpError(
                        message: state.message,
                        onRetry: () => context.read<VotdBloc>().add(LoadVotd()),
                      ),
                    );
                  }
                  // Return nothing if initial - dashboard should still work
                  return const SizedBox.shrink();
                },
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
                    title: "Opkomende Gebeure",
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
                    title: "Tiendes & Offergawes",
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
                    title: "Eerste Keer Besoeker",
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
                    title: "Volg Ons",
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
                    title: "Kursusse",
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
                    title: "Gebedsversoeke",
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
