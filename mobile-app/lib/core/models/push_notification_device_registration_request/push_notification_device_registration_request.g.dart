// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notification_device_registration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PushNotificationDeviceRegistrationRequest
_$PushNotificationDeviceRegistrationRequestFromJson(
  Map<String, dynamic> json,
) => _PushNotificationDeviceRegistrationRequest(
  deviceToken: json['device_token'] as String,
  deviceModel: json['device_model'] as String,
  deviceUuid: json['device_uuid'] as String,
);

Map<String, dynamic> _$PushNotificationDeviceRegistrationRequestToJson(
  _PushNotificationDeviceRegistrationRequest instance,
) => <String, dynamic>{
  'device_token': instance.deviceToken,
  'device_model': instance.deviceModel,
  'device_uuid': instance.deviceUuid,
};
