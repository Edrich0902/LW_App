import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Blocs/Courses/courses_bloc.dart';
import 'package:lw_app/Models/Event/event_category.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/LwpDateBeaconCard/lwp_date_beacon_card.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';
import 'package:lw_app/Screens/Courses/course_detail.dart';
import 'package:lw_app/Widgets/LwpListEntrance/lwp_list_entrance.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _listEntrance = LwpListEntranceController();

  @override
  void dispose() {
    _listEntrance.dispose();
    super.dispose();
  }

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
      child: LwpChromeScaffold(
        title: context.l10n.dashboardCourses,
        showDefaultActions: true,
        body: BlocBuilder<CoursesBloc, CoursesState>(
            builder: (context, state) {
              if (state is CoursesLoading) {
                return LwpSkeletonList.media();
              } else if (state is CoursesSuccess) {
                if (state.courses.isNotEmpty) {
                  return LwpListEntranceScope(
                    controller: _listEntrance,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _listEntrance.bump();
                        coursesBloc.add(
                          LoadCourses(eventCategory: EventCategory.COURSE),
                        );
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 24.0),
                        itemCount: state.courses.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: LwpSpacing.sm),
                        itemBuilder: (BuildContext context, int index) {
                          final course = state.courses[index];
                          return LwpListEntrance(
                            id: course.id ?? 'course-$index',
                            child: LwpDateBeaconCard(
                              event: course,
                              heroTag: 'course_image_${course.id}',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseDetailPage(
                                      course: course,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  return LwpEmpty(message: context.l10n.coursesEmpty);
                }
              } else {
                return const LwpError();
              }
            },
          ),
      ),
    );
  }

}
