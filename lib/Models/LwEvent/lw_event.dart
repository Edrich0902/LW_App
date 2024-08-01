class LwEvent {
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  //final String bannerImage; //TODO: confirm this implementation

  const LwEvent({
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate = '',
    required this.startTime,
    this.endTime = ''
  });

  factory LwEvent.fromJson(Map<String, dynamic> json) {
    return LwEvent(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }
}