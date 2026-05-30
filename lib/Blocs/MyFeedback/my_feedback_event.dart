part of 'my_feedback_bloc.dart';

abstract class MyFeedbackEvent extends Equatable {
  const MyFeedbackEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyFeedback extends MyFeedbackEvent {
  const LoadMyFeedback();
}

class CreateFeedbackEvent extends MyFeedbackEvent {
  final FeedbackCategory category;
  final String title;
  final String body;

  const CreateFeedbackEvent({
    required this.category,
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [category, title, body];
}
