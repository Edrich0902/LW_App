part of 'courses_bloc.dart';

abstract class CoursesEvent extends Equatable {
  const CoursesEvent();

  @override
  List<Object?> get props => [];
}

class LoadCourses extends CoursesEvent {
  final String? eventCategory;

  const LoadCourses({required this.eventCategory});

  @override
  List<Object?> get props => [eventCategory];
}