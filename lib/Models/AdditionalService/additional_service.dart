import 'package:equatable/equatable.dart';

class AdditionalService extends Equatable {
  final String? serviceName;
  final String? serviceDay;
  final String? serviceTime;

  const AdditionalService({
    this.serviceName,
    this.serviceDay,
    this.serviceTime
  });

  @override
  List<Object?> get props => [
    serviceName,
    serviceDay,
    serviceTime,
  ];

  factory AdditionalService.fromJson(Map<String, dynamic> json) {
    return AdditionalService(
      serviceName: json['serviceName'] ?? '',
      serviceDay: json['serviceDay'] ?? '',
      serviceTime: json['serviceTime'] ?? '',
    );
  }
}