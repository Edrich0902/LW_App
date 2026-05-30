part of 'my_feedback_bloc.dart';

abstract class MyFeedbackState extends Equatable {
  const MyFeedbackState();

  @override
  List<Object?> get props => [];
}

class MyFeedbackInitial extends MyFeedbackState {}

class MyFeedbackLoading extends MyFeedbackState {}

class MyFeedbackSuccess extends MyFeedbackState {
  final List<AppFeedback> feedbacks;

  const MyFeedbackSuccess({required this.feedbacks});

  @override
  List<Object?> get props => [feedbacks];
}

class MyFeedbackSubmitting extends MyFeedbackState {
  final List<AppFeedback> previousFeedbacks;

  const MyFeedbackSubmitting({required this.previousFeedbacks});

  @override
  List<Object?> get props => [previousFeedbacks];
}

class MyFeedbackSubmitSuccess extends MyFeedbackState {}

class MyFeedbackError extends MyFeedbackState {
  final String error;

  const MyFeedbackError(this.error);

  @override
  List<Object?> get props => [error];
}
