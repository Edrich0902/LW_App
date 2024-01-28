part of 'vision_mission_bloc.dart';

abstract class VisionMissionState extends Equatable {
  const VisionMissionState();
}

class VisionMissionInitial extends VisionMissionState {
  @override
  List<Object> get props => [];
}

class VisionMissionLoading extends VisionMissionState {
  @override
  List<Object> get props => [];
}

class VisionMissionSuccess extends VisionMissionState {
  final List<MetaData> data;

  const VisionMissionSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class VisionMissionError extends VisionMissionState {
  final String error;

  const VisionMissionError(this.error);

  @override
  List<Object> get props => [error];
}