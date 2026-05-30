import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/AppFeedback/app_feedback.dart';
import 'package:lw_app/Services/AppFeedback/app_feedback_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'my_feedback_event.dart';
part 'my_feedback_state.dart';

class MyFeedbackBloc extends Bloc<MyFeedbackEvent, MyFeedbackState> {
  final AppFeedbackService _service = AppFeedbackService();

  MyFeedbackBloc() : super(MyFeedbackInitial()) {
    on<LoadMyFeedback>((event, emit) async {
      emit(MyFeedbackLoading());
      try {
        final feedbacks = await _service.getMyFeedback();
        emit(MyFeedbackSuccess(feedbacks: feedbacks));
      } catch (error) {
        emit(MyFeedbackError(error.toString()));
      }
    });

    on<CreateFeedbackEvent>((event, emit) async {
      final previousFeedbacks =
          state is MyFeedbackSuccess ? (state as MyFeedbackSuccess).feedbacks : <AppFeedback>[];

      emit(MyFeedbackSubmitting(previousFeedbacks: previousFeedbacks));

      try {
        final deviceInfo = await _resolveDeviceInfo();
        final packageInfo = await PackageInfo.fromPlatform();

        await _service.createFeedback(
          category: event.category,
          title: event.title,
          body: event.body,
          deviceOs: deviceInfo['os']!,
          deviceModel: deviceInfo['model']!,
          appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
        );

        emit(MyFeedbackSubmitSuccess());

        final updated = await _service.getMyFeedback();
        emit(MyFeedbackSuccess(feedbacks: updated));
      } catch (error) {
        emit(MyFeedbackError(error.toString()));
        emit(MyFeedbackSuccess(feedbacks: previousFeedbacks));
      }
    });
  }

  Future<Map<String, String>> _resolveDeviceInfo() async {
    final plugin = DeviceInfoPlugin();
    try {
      if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        return {
          'os': 'iOS ${info.systemVersion}',
          'model': '${info.name} (${info.utsname.machine})',
        };
      } else if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        return {
          'os': 'Android ${info.version.release}',
          'model': '${info.manufacturer} ${info.model}',
        };
      }
    } catch (_) {}
    return {'os': 'Unknown', 'model': 'Unknown'};
  }
}
