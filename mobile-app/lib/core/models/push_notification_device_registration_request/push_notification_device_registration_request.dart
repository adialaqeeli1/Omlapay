import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_notification_device_registration_request.freezed.dart';
part 'push_notification_device_registration_request.g.dart';

@freezed
abstract class PushNotificationDeviceRegistrationRequest
    with _$PushNotificationDeviceRegistrationRequest {
  const PushNotificationDeviceRegistrationRequest._();

  const factory PushNotificationDeviceRegistrationRequest({
    @JsonKey(name: 'device_token') required String deviceToken,
    @JsonKey(name: 'device_model') required String deviceModel,
    @JsonKey(name: 'device_uuid') required String deviceUuid,
  }) = _PushNotificationDeviceRegistrationRequest;

  factory PushNotificationDeviceRegistrationRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$PushNotificationDeviceRegistrationRequestFromJson(json);
}
