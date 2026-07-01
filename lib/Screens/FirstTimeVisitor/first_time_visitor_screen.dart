import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Blocs/Events/events_bloc.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Blocs/EventRsvp/event_rsvp_bloc.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Screens/MoreInfo/more_info.dart';
import 'package:lw_app/Screens/UpcomingEvents/upcoming_event_detail.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Utils/maps_helper.dart';
import 'package:lw_app/Widgets/Dashboard/dashboard_grid_card.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';

class FirstTimeVisitorScreen extends StatefulWidget {
  const FirstTimeVisitorScreen({super.key});

  @override
  State<FirstTimeVisitorScreen> createState() => _FirstTimeVisitorScreenState();
}

class _FirstTimeVisitorScreenState extends State<FirstTimeVisitorScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EventsBloc>().add(LoadUpcomingEvents(
          eventType: EventType.ONCE,
          date: DateTime.now(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.visitorWelcomeTitle),
        actions: const [LwpAnnouncementButton(), ProfileActionButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHero(theme),
            const SizedBox(height: 24),
            _buildServiceTimesCard(theme),
            const SizedBox(height: 24),
            _buildQuickLinksGrid(context),
            const SizedBox(height: 32),
            Text(
              context.l10n.visitorUpcomingEventsTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildUpcomingEventsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHero(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: LwpRadii.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.favorite,
            color: theme.primaryColor,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.visitorWelcomeHeadline,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.visitorWelcomeBody,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTimesCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: theme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  context.l10n.visitorSundayServices,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildServiceTimeRow(
              context.l10n.visitorMorningService,
              '09:30',
              theme,
            ),
            const SizedBox(height: 12),
            _buildServiceTimeRow(
              context.l10n.visitorEveningService,
              '18:00',
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTimeRow(String label, String time, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        Text(
          time,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLinksGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        DashboardGridCard(
          title: context.l10n.visitorFindUs,
          icon: Icons.location_on,
          onTap: () => MapsHelper.openLocation("6 Mill Street Paarl"),
        ),
        DashboardGridCard(
          title: context.l10n.visitorContactUs,
          icon: Icons.chat_bubble,
          onTap: () {
            final Uri whatsappUri = Uri.parse("https://wa.me/+27727238406");
            launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
          },
        ),
        DashboardGridCard(
          title: context.l10n.visitorMoreAboutUs,
          icon: Icons.info,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MoreInfoPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingEventsSection() {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        if (state is EventsLoading) {
          return LwpLoader(message: context.l10n.upcomingEventsLoading);
        } else if (state is EventsSuccess) {
          final upcoming = state.events.take(3).toList();
          if (upcoming.isEmpty) {
            return Text(context.l10n.visitorNoUpcomingEvents);
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcoming.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildCompactEventCard(upcoming[index]);
            },
          );
        } else {
          return LwpError(message: context.l10n.visitorUpcomingEventsError);
        }
      },
    );
  }

  Widget _buildCompactEventCard(Event event) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: LwpRadii.lgAll,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => EventRsvpBloc()..add(InitEventRsvp(event)),
                child: UpcomingEventDetailPage(event: event),
              ),
            ),
          );
        },
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CldImageWidget(
                publicId: event.bannerPublicId ?? 'samples/cloudinary-icon',
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${event.day} ${DateFormatter.formatDate(event.startDate)}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
