import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Services/Event/event_service.dart';

part 'courses_event.dart';
part 'courses_state.dart';

class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  final EventService _eventService = EventService();

  CoursesBloc() : super(CoursesInitial()) {
    on<LoadCourses>((event, emit) async {
      emit(CoursesLoading());
      try {
        List<Event> events = await _eventService.getEvents(type: null, category: event.eventCategory);
        emit(CoursesSuccess(courses: events));
      } catch (error) {
        emit(CoursesError(error.toString()));
      }
    });
  }
}
