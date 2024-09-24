part of 'courses_bloc.dart';

abstract class CoursesState extends Equatable {
  const CoursesState();
}

class CoursesInitial extends CoursesState {
  @override
  List<Object> get props => [];
}

class CoursesLoading extends CoursesState {
  @override
  List<Object> get props => [];
}

class CoursesSuccess extends CoursesState {
  final List<Event> courses;

  const CoursesSuccess({required this.courses});

  @override
  List<Object> get props => [courses];
}

class CoursesError extends CoursesState {
  final String error;

  const CoursesError(this.error);

  @override
  List<Object> get props => [error];
}