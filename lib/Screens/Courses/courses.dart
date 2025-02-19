import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Blocs/Courses/courses_bloc.dart';
import 'package:lw_app/Models/Event/event_category.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  @override
  void initState() {
    context
        .read<CoursesBloc>()
        .add(LoadCourses(eventCategory: EventCategory.COURSE));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CoursesBloc coursesBloc = BlocProvider.of<CoursesBloc>(context);

    return BlocListener<CoursesBloc, CoursesState>(
      listener: (context, state) {
        // Listen to state updates and execute logic here
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Kursusse"),
          actions: const <Widget>[LwpAnnouncementButton(), ProfileActionButton()],
        ),
        body: SafeArea(
          child: BlocBuilder<CoursesBloc, CoursesState>(
            builder: (context, state) {
              if (state is CoursesLoading) {
                return const LwpLoader(message: "Laai Kursusse");
              } else if (state is CoursesSuccess) {
                if (state.courses.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => coursesBloc
                        .add(LoadCourses(eventCategory: EventCategory.COURSE)),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: state.courses.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildCourseCard(state.courses[index],
                            () => print("course clicked"));
                      },
                    ),
                  );
                } else {
                  return const LwpEmpty(message: "Geen Kursusse");
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

  Widget _buildCourseCard(Event course, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: <Widget>[
            CldImageWidget(
                publicId: course.bannerPublicId ?? 'samples/cloudinary-icon',
                fit: BoxFit.fill
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.event),
                          const SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(course.title,
                                  style: theme.textTheme.titleMedium),
                              Text(course.description,
                                  style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 16.0),
                              Text(_formatCourseDateTime(course),
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  String _formatCourseDateTime(Event course) {
    if (course.startDate == null) return 'N/A';
    return "${course.day} ${DateFormatter.formatDate(course.startDate)} ${DateFormatter.formatTime(course.time)}";
  }
}
