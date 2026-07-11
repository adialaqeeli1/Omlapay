// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'push_notification_device_registration_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PushNotificationDeviceRegistrationRequest {

@JsonKey(name: 'device_token') String get deviceToken;@JsonKey(name: 'device_model') String get deviceModel;@JsonKey(name: 'device_uuid') String get deviceUuid;
/// Create a copy of PushNotificationDeviceRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushNotificationDeviceRegistrationRequestCopyWith<PushNotificationDeviceRegistrationRequest> get copyWith => _$PushNotificationDeviceRegistrationRequestCopyWithImpl<PushNotificationDeviceRegistrationRequest>(this as PushNotificationDeviceRegistrationRequest, _$identity);

  /// Serializes this PushNotificationDeviceRegistrationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PushNotificationDeviceRegistrationRequest&&(identical(other.deviceToken, deviceToken) || other.deviceToken == deviceToken)&&(identical(other.deviceModel, deviceModel) || other.deviceModel == deviceModel)&&(identical(other.deviceUuid, deviceUuid) || other.deviceUuid == deviceUuid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceToken,deviceModel,deviceUuid);

@override
String toString() {
  return 'PushNotificationDeviceRegistrationRequest(deviceToken: $deviceToken, deviceModel: $deviceModel, deviceUuid: $deviceUuid)';
}


}

/// @nodoc
abstract mixin class $PushNotificationDeviceRegistrationRequestCopyWith<$Res>  {
  factory $PushNotificationDeviceRegistrationRequestCopyWith(PushNotificationDeviceRegistrationRequest value, $Res Function(PushNotificationDeviceRegistrationRequest) _then) = _$PushNotificationDeviceRegistrationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'device_token') String deviceToken,@JsonKey(name: 'device_model') String deviceModel,@JsonKey(name: 'device_uuid') String deviceUuid
});




}
/// @nodoc
class _$PushNotificationDeviceRegistrationRequestCopyWithImpl<$Res>
    implements $PushNotificationDeviceRegistrationRequestCopyWith<$Res> {
  _$PushNotificationDeviceRegistrationRequestCopyWithImpl(this._self, this._then);

  final PushNotificationDeviceRegistrationRequest _self;
  final $Res Function(PushNotificationDeviceRegistrationRequest) _then;

/// Create a copy of PushNotificationDeviceRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceToken = null,Object? deviceModel = null,Object? deviceUuid = null,}) {
  return _then(_self.copyWith(
deviceToken: null == deviceToken ? _self.deviceToken : deviceToken // ignore: cast_nullable_to_non_nullable
as String,deviceModel: null == deviceModel ? _self.deviceModel : deviceModel // ignore: cast_nullable_to_non_nullable
as String,deviceUuid: null == deviceUuid ? _self.deviceUuid : deviceUuid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PushNotificationDeviceRegistrationRequest].
extension PushNotificationDeviceRegistrationRequestPatterns on PushNotificationDeviceRegistrationRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PushNotificationDeviceRegistrationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PushNotificationDeviceRegistrationRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PushNotificationDeviceRegistrationRequest value)  $default,){
final _that = this;
switch (_that) {
case _PushNotificationDeviceRegistrationRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PushNotificationDeviceRegistrationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PushNotificationDeviceRegistrationRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'device_token')  String deviceToken, @JsonKey(name: 'device_model')  String deviceModel, @JsonKey(name: 'device_uuid')  String deviceUuid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PushNotificationDeviceRegistrationRequest() when $default != null:
return $default(_that.deviceToken,_that.deviceModel,_that.deviceUuid);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'device_token')  String deviceToken, @JsonKey(name: 'device_model')  String deviceModel, @JsonKey(name: 'device_uuid')  String deviceUuid)  $default,) {final _that = this;
switch (_that) {
case _PushNotificationDeviceRegistrationRequest():
return $default(_that.deviceToken,_that.deviceModel,_that.deviceUuid);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'device_token')  String deviceToken, @JsonKey(name: 'device_model')  String deviceModel, @JsonKey(name: 'device_uuid')  String deviceUuid)?  $default,) {final _that = this;
switch (_that) {
case _PushNotificationDeviceRegistrationRequest() when $default != null:
return $default(_that.deviceToken,_that.deviceModel,_that.deviceUuid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PushNotificationDeviceRegistrationRequest extends PushNotificationDeviceRegistrationRequest {
  const _PushNotificationDeviceRegistrationRequest({@JsonKey(name: 'device_token') required this.deviceToken, @JsonKey(name: 'device_model') required this.deviceModel, @JsonKey(name: 'device_uuid') required this.deviceUuid}): super._();
  factory _PushNotificationDeviceRegistrationRequest.fromJson(Map<String, dynamic> json) => _$PushNotificationDeviceRegistrationRequestFromJson(json);

@override@JsonKey(name: 'device_token') final  String deviceToken;
@override@JsonKey(name: 'device_model') final  String deviceModel;
@override@JsonKey(name: 'device_uuid') final  String deviceUuid;

/// Create a copy of PushNotificationDeviceRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PushNotificationDeviceRegistrationRequestCopyWith<_PushNotificationDeviceRegistrationRequest> get copyWith => __$PushNotificationDeviceRegistrationRequestCopyWithImpl<_PushNotificationDeviceRegistrationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PushNotificationDeviceRegistrationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PushNotificationDeviceRegistrationRequest&&(identical(other.deviceToken, deviceToken) || other.deviceToken == deviceToken)&&(identical(other.deviceModel, deviceModel) || other.deviceModel == deviceModel)&&(identical(other.deviceUuid, deviceUuid) || other.deviceUuid == deviceUuid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceToken,deviceModel,deviceUuid);

@override
String toString() {
  return 'PushNotificationDeviceRegistrationRequest(deviceToken: $deviceToken, deviceModel: $deviceModel, deviceUuid: $deviceUuid)';
}


}

/// @nodoc
abstract mixin class _$PushNotificationDeviceRegistrationRequestCopyWith<$Res> implements $PushNotificationDeviceRegistrationRequestCopyWith<$Res> {
  factory _$PushNotificationDeviceRegistrationRequestCopyWith(_PushNotificationDeviceRegistrationRequest value, $Res Function(_PushNotificationDeviceRegistrationRequest) _then) = __$PushNotificationDeviceRegistrationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'device_token') String deviceToken,@JsonKey(name: 'device_model') String deviceModel,@JsonKey(name: 'device_uuid') String deviceUuid
});




}
/// @nodoc
class __$PushNotificationDeviceRegistrationRequestCopyWithImpl<$Res>
    implements _$PushNotificationDeviceRegistrationRequestCopyWith<$Res> {
  __$PushNotificationDeviceRegistrationRequestCopyWithImpl(this._self, this._then);

  final _PushNotificationDeviceRegistrationRequest _self;
  final $Res Function(_PushNotificationDeviceRegistrationRequest) _then;

/// Create a copy of PushNotificationDeviceRegistrationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceToken = null,Object? deviceModel = null,Object? deviceUuid = null,}) {
  return _then(_PushNotificationDeviceRegistrationRequest(
deviceToken: null == deviceToken ? _self.deviceToken : deviceToken // ignore: cast_nullable_to_non_nullable
as String,deviceModel: null == deviceModel ? _self.deviceModel : deviceModel // ignore: cast_nullable_to_non_nullable
as String,deviceUuid: null == deviceUuid ? _self.deviceUuid : deviceUuid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
