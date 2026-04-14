// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'send_resend_otp_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SendResendOtpResponseModel {

 String get sendToken; int get otpExpirySeconds; int get remainingResends;
/// Create a copy of SendResendOtpResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendResendOtpResponseModelCopyWith<SendResendOtpResponseModel> get copyWith => _$SendResendOtpResponseModelCopyWithImpl<SendResendOtpResponseModel>(this as SendResendOtpResponseModel, _$identity);

  /// Serializes this SendResendOtpResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendResendOtpResponseModel&&(identical(other.sendToken, sendToken) || other.sendToken == sendToken)&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds)&&(identical(other.remainingResends, remainingResends) || other.remainingResends == remainingResends));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sendToken,otpExpirySeconds,remainingResends);

@override
String toString() {
  return 'SendResendOtpResponseModel(sendToken: $sendToken, otpExpirySeconds: $otpExpirySeconds, remainingResends: $remainingResends)';
}


}

/// @nodoc
abstract mixin class $SendResendOtpResponseModelCopyWith<$Res>  {
  factory $SendResendOtpResponseModelCopyWith(SendResendOtpResponseModel value, $Res Function(SendResendOtpResponseModel) _then) = _$SendResendOtpResponseModelCopyWithImpl;
@useResult
$Res call({
 String sendToken, int otpExpirySeconds, int remainingResends
});




}
/// @nodoc
class _$SendResendOtpResponseModelCopyWithImpl<$Res>
    implements $SendResendOtpResponseModelCopyWith<$Res> {
  _$SendResendOtpResponseModelCopyWithImpl(this._self, this._then);

  final SendResendOtpResponseModel _self;
  final $Res Function(SendResendOtpResponseModel) _then;

/// Create a copy of SendResendOtpResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sendToken = null,Object? otpExpirySeconds = null,Object? remainingResends = null,}) {
  return _then(_self.copyWith(
sendToken: null == sendToken ? _self.sendToken : sendToken // ignore: cast_nullable_to_non_nullable
as String,otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,remainingResends: null == remainingResends ? _self.remainingResends : remainingResends // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SendResendOtpResponseModel].
extension SendResendOtpResponseModelPatterns on SendResendOtpResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SendResendOtpResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendResendOtpResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SendResendOtpResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _SendResendOtpResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SendResendOtpResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _SendResendOtpResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sendToken,  int otpExpirySeconds,  int remainingResends)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendResendOtpResponseModel() when $default != null:
return $default(_that.sendToken,_that.otpExpirySeconds,_that.remainingResends);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sendToken,  int otpExpirySeconds,  int remainingResends)  $default,) {final _that = this;
switch (_that) {
case _SendResendOtpResponseModel():
return $default(_that.sendToken,_that.otpExpirySeconds,_that.remainingResends);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sendToken,  int otpExpirySeconds,  int remainingResends)?  $default,) {final _that = this;
switch (_that) {
case _SendResendOtpResponseModel() when $default != null:
return $default(_that.sendToken,_that.otpExpirySeconds,_that.remainingResends);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SendResendOtpResponseModel implements SendResendOtpResponseModel {
  const _SendResendOtpResponseModel({this.sendToken = '', this.otpExpirySeconds = 60, this.remainingResends = 0});
  factory _SendResendOtpResponseModel.fromJson(Map<String, dynamic> json) => _$SendResendOtpResponseModelFromJson(json);

@override@JsonKey() final  String sendToken;
@override@JsonKey() final  int otpExpirySeconds;
@override@JsonKey() final  int remainingResends;

/// Create a copy of SendResendOtpResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendResendOtpResponseModelCopyWith<_SendResendOtpResponseModel> get copyWith => __$SendResendOtpResponseModelCopyWithImpl<_SendResendOtpResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SendResendOtpResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendResendOtpResponseModel&&(identical(other.sendToken, sendToken) || other.sendToken == sendToken)&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds)&&(identical(other.remainingResends, remainingResends) || other.remainingResends == remainingResends));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sendToken,otpExpirySeconds,remainingResends);

@override
String toString() {
  return 'SendResendOtpResponseModel(sendToken: $sendToken, otpExpirySeconds: $otpExpirySeconds, remainingResends: $remainingResends)';
}


}

/// @nodoc
abstract mixin class _$SendResendOtpResponseModelCopyWith<$Res> implements $SendResendOtpResponseModelCopyWith<$Res> {
  factory _$SendResendOtpResponseModelCopyWith(_SendResendOtpResponseModel value, $Res Function(_SendResendOtpResponseModel) _then) = __$SendResendOtpResponseModelCopyWithImpl;
@override @useResult
$Res call({
 String sendToken, int otpExpirySeconds, int remainingResends
});




}
/// @nodoc
class __$SendResendOtpResponseModelCopyWithImpl<$Res>
    implements _$SendResendOtpResponseModelCopyWith<$Res> {
  __$SendResendOtpResponseModelCopyWithImpl(this._self, this._then);

  final _SendResendOtpResponseModel _self;
  final $Res Function(_SendResendOtpResponseModel) _then;

/// Create a copy of SendResendOtpResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sendToken = null,Object? otpExpirySeconds = null,Object? remainingResends = null,}) {
  return _then(_SendResendOtpResponseModel(
sendToken: null == sendToken ? _self.sendToken : sendToken // ignore: cast_nullable_to_non_nullable
as String,otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,remainingResends: null == remainingResends ? _self.remainingResends : remainingResends // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
