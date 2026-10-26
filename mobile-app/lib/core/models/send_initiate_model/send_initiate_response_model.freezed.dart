// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'send_initiate_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SendInitiateResponseModel {

 String get sendToken; int get otpExpirySeconds;
/// Create a copy of SendInitiateResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendInitiateResponseModelCopyWith<SendInitiateResponseModel> get copyWith => _$SendInitiateResponseModelCopyWithImpl<SendInitiateResponseModel>(this as SendInitiateResponseModel, _$identity);

  /// Serializes this SendInitiateResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendInitiateResponseModel&&(identical(other.sendToken, sendToken) || other.sendToken == sendToken)&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sendToken,otpExpirySeconds);

@override
String toString() {
  return 'SendInitiateResponseModel(sendToken: $sendToken, otpExpirySeconds: $otpExpirySeconds)';
}


}

/// @nodoc
abstract mixin class $SendInitiateResponseModelCopyWith<$Res>  {
  factory $SendInitiateResponseModelCopyWith(SendInitiateResponseModel value, $Res Function(SendInitiateResponseModel) _then) = _$SendInitiateResponseModelCopyWithImpl;
@useResult
$Res call({
 String sendToken, int otpExpirySeconds
});




}
/// @nodoc
class _$SendInitiateResponseModelCopyWithImpl<$Res>
    implements $SendInitiateResponseModelCopyWith<$Res> {
  _$SendInitiateResponseModelCopyWithImpl(this._self, this._then);

  final SendInitiateResponseModel _self;
  final $Res Function(SendInitiateResponseModel) _then;

/// Create a copy of SendInitiateResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sendToken = null,Object? otpExpirySeconds = null,}) {
  return _then(_self.copyWith(
sendToken: null == sendToken ? _self.sendToken : sendToken // ignore: cast_nullable_to_non_nullable
as String,otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SendInitiateResponseModel].
extension SendInitiateResponseModelPatterns on SendInitiateResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SendInitiateResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendInitiateResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SendInitiateResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _SendInitiateResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SendInitiateResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _SendInitiateResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sendToken,  int otpExpirySeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendInitiateResponseModel() when $default != null:
return $default(_that.sendToken,_that.otpExpirySeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sendToken,  int otpExpirySeconds)  $default,) {final _that = this;
switch (_that) {
case _SendInitiateResponseModel():
return $default(_that.sendToken,_that.otpExpirySeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sendToken,  int otpExpirySeconds)?  $default,) {final _that = this;
switch (_that) {
case _SendInitiateResponseModel() when $default != null:
return $default(_that.sendToken,_that.otpExpirySeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SendInitiateResponseModel implements SendInitiateResponseModel {
  const _SendInitiateResponseModel({this.sendToken = '', this.otpExpirySeconds = 60});
  factory _SendInitiateResponseModel.fromJson(Map<String, dynamic> json) => _$SendInitiateResponseModelFromJson(json);

@override@JsonKey() final  String sendToken;
@override@JsonKey() final  int otpExpirySeconds;

/// Create a copy of SendInitiateResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendInitiateResponseModelCopyWith<_SendInitiateResponseModel> get copyWith => __$SendInitiateResponseModelCopyWithImpl<_SendInitiateResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SendInitiateResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendInitiateResponseModel&&(identical(other.sendToken, sendToken) || other.sendToken == sendToken)&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sendToken,otpExpirySeconds);

@override
String toString() {
  return 'SendInitiateResponseModel(sendToken: $sendToken, otpExpirySeconds: $otpExpirySeconds)';
}


}

/// @nodoc
abstract mixin class _$SendInitiateResponseModelCopyWith<$Res> implements $SendInitiateResponseModelCopyWith<$Res> {
  factory _$SendInitiateResponseModelCopyWith(_SendInitiateResponseModel value, $Res Function(_SendInitiateResponseModel) _then) = __$SendInitiateResponseModelCopyWithImpl;
@override @useResult
$Res call({
 String sendToken, int otpExpirySeconds
});




}
/// @nodoc
class __$SendInitiateResponseModelCopyWithImpl<$Res>
    implements _$SendInitiateResponseModelCopyWith<$Res> {
  __$SendInitiateResponseModelCopyWithImpl(this._self, this._then);

  final _SendInitiateResponseModel _self;
  final $Res Function(_SendInitiateResponseModel) _then;

/// Create a copy of SendInitiateResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sendToken = null,Object? otpExpirySeconds = null,}) {
  return _then(_SendInitiateResponseModel(
sendToken: null == sendToken ? _self.sendToken : sendToken // ignore: cast_nullable_to_non_nullable
as String,otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
