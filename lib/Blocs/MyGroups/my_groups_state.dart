part of 'my_groups_bloc.dart';

enum MyGroupsStatus { initial, loading, success, error }

class MyGroupsState extends Equatable {
  final MyGroupsStatus status;
  final List<Group> activeGroups;
  final List<Group> pendingGroups;
  final bool isRefreshing;
  final String? error;

  const MyGroupsState({
    this.status = MyGroupsStatus.initial,
    this.activeGroups = const [],
    this.pendingGroups = const [],
    this.isRefreshing = false,
    this.error,
  });

  bool get hasGroups => activeGroups.isNotEmpty || pendingGroups.isNotEmpty;

  MyGroupsState copyWith({
    MyGroupsStatus? status,
    List<Group>? activeGroups,
    List<Group>? pendingGroups,
    bool? isRefreshing,
    String? error,
  }) {
    return MyGroupsState(
      status: status ?? this.status,
      activeGroups: activeGroups ?? this.activeGroups,
      pendingGroups: pendingGroups ?? this.pendingGroups,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeGroups,
        pendingGroups,
        isRefreshing,
        error,
      ];
}
