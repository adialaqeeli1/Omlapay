// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'change_phone_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChangePhoneRequestData {

@JsonKey(name: 'masked_mobile') String get maskedMobile;@JsonKey(name: 'otp_expiry_seconds') int get otpExpirySeconds;
/// Create a copy of ChangePhoneRequestData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangePhoneRequestDataCopyWith<ChangePhoneRequestData> get copyWith => _$ChangePhoneRequestDataCopyWithImpl<ChangePhoneRequestData>(this as ChangePhoneRequestData, _$identity);

  /// Serializes this ChangePhoneRequestData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangePhoneRequestData&&(identical(other.maskedMobile, maskedMobile) || other.maskedMobile == maskedMobile)&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maskedMobile,otpExpirySeconds);

@override
String toString() {
  return 'ChangePhoneRequestData(maskedMobile: $maskedMobile, otpExpirySeconds: $otpExpirySeconds)';
}


}

/// @nodoc
abstract mixin class $ChangePhoneRequestDataCopyWith<$Res>  {
  factory $ChangePhoneRequestDataCopyWith(ChangePhoneRequestData value, $Res Function(ChangePhoneRequestData) _then) = _$ChangePhoneRequestDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'masked_mobile') String maskedMobile,@JsonKey(name: 'otp_expiry_seconds') int otpExpirySeconds
});




}
/// @nodoc
class _$ChangePhoneRequestDataCopyWithImpl<$Res>
    implements $ChangePhoneRequestDataCopyWith<$Res> {
  _$ChangePhoneRequestDataCopyWithImpl(this._self, this._then);

  final ChangePhoneRequestData _self;
  final $Res Function(ChangePhoneRequestData) _then;

/// Create a copy of ChangePhoneRequestData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maskedMobile = null,Object? otpExpirySeconds = null,}) {
  return _then(_self.copyWith(
maskedMobile: null == maskedMobile ? _self.maskedMobile : maskedMobile // ignore: cast_nullable_to_non_nullable
as String,otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangePhoneRequestData].
extension ChangePhoneRequestDataPatterns on ChangePhoneRequestData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangePhoneRequestData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangePhoneRequestData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangePhoneRequestData value)  $default,){
final _that = this;
switch (_that) {
case _ChangePhoneRequestData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangePhoneRequestData value)?  $default,){
final _that = this;
switch (_that) {
case _ChangePhoneRequestData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'masked_mobile')  String maskedMobile, @JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangePhoneRequestData() when $default != null:
return $default(_that.maskedMobile,_that.otpExpirySeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'masked_mobile')  String maskedMobile, @JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds)  $default,) {final _that = this;
switch (_that) {
case _ChangePhoneRequestData():
return $default(_that.maskedMobile,_that.otpExpirySeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'masked_mobile')  String maskedMobile, @JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds)?  $default,) {final _that = this;
switch (_that) {
case _ChangePhoneRequestData() when $default != null:
return $default(_that.maskedMobile,_that.otpExpirySeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangePhoneRequestData implements ChangePhoneRequestData {
  const _ChangePhoneRequestData({@JsonKey(name: 'masked_mobile') required this.maskedMobile, @JsonKey(name: 'otp_expiry_seconds') required this.otpExpirySeconds});
  factory _ChangePhoneRequestData.fromJson(Map<String, dynamic> json) => _$ChangePhoneRequestDataFromJson(json);

@override@JsonKey(name: 'masked_mobile') final  String maskedMobile;
@override@JsonKey(name: 'otp_expiry_seconds') final  int otpExpirySeconds;

/// Create a copy of ChangePhoneRequestData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangePhoneRequestDataCopyWith<_ChangePhoneRequestData> get copyWith => __$ChangePhoneRequestDataCopyWithImpl<_ChangePhoneRequestData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangePhoneRequestDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangePhoneRequestData&&(identical(other.maskedMobile, maskedMobile) || other.maskedMobile == maskedMobile)&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maskedMobile,otpExpirySeconds);

@override
String toString() {
  return 'ChangePhoneRequestData(maskedMobile: $maskedMobile, otpExpirySeconds: $otpExpirySeconds)';
}


}

/// @nodoc
abstract mixin class _$ChangePhoneRequestDataCopyWith<$Res> implements $ChangePhoneRequestDataCopyWith<$Res> {
  factory _$ChangePhoneRequestDataCopyWith(_ChangePhoneRequestData value, $Res Function(_ChangePhoneRequestData) _then) = __$ChangePhoneRequestDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'masked_mobile') String maskedMobile,@JsonKey(name: 'otp_expiry_seconds') int otpExpirySeconds
});




}
/// @nodoc
class __$ChangePhoneRequestDataCopyWithImpl<$Res>
    implements _$ChangePhoneRequestDataCopyWith<$Res> {
  __$ChangePhoneRequestDataCopyWithImpl(this._self, this._then);

  final _ChangePhoneRequestData _self;
  final $Res Function(_ChangePhoneRequestData) _then;

/// Create a copy of ChangePhoneRequestData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maskedMobile = null,Object? otpExpirySeconds = null,}) {
  return _then(_ChangePhoneRequestData(
maskedMobile: null == maskedMobile ? _self.maskedMobile : maskedMobile // ignore: cast_nullable_to_non_nullable
as String,otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ChangePhoneVerifyData {

@JsonKey(name: 'masked_mobile') String get maskedMobile;
/// Create a copy of ChangePhoneVerifyData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangePhoneVerifyDataCopyWith<ChangePhoneVerifyData> get copyWith => _$ChangePhoneVerifyDataCopyWithImpl<ChangePhoneVerifyData>(this as ChangePhoneVerifyData, _$identity);

  /// Serializes this ChangePhoneVerifyData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangePhoneVerifyData&&(identical(other.maskedMobile, maskedMobile) || other.maskedMobile == maskedMobile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maskedMobile);

@override
String toString() {
  return 'ChangePhoneVerifyData(maskedMobile: $maskedMobile)';
}


}

/// @nodoc
abstract mixin class $ChangePhoneVerifyDataCopyWith<$Res>  {
  factory $ChangePhoneVerifyDataCopyWith(ChangePhoneVerifyData value, $Res Function(ChangePhoneVerifyData) _then) = _$ChangePhoneVerifyDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'masked_mobile') String maskedMobile
});




}
/// @nodoc
class _$ChangePhoneVerifyDataCopyWithImpl<$Res>
    implements $ChangePhoneVerifyDataCopyWith<$Res> {
  _$ChangePhoneVerifyDataCopyWithImpl(this._self, this._then);

  final ChangePhoneVerifyData _self;
  final $Res Function(ChangePhoneVerifyData) _then;

/// Create a copy of ChangePhoneVerifyData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maskedMobile = null,}) {
  return _then(_self.copyWith(
maskedMobile: null == maskedMobile ? _self.maskedMobile : maskedMobile // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangePhoneVerifyData].
extension ChangePhoneVerifyDataPatterns on ChangePhoneVerifyData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangePhoneVerifyData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangePhoneVerifyData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangePhoneVerifyData value)  $default,){
final _that = this;
switch (_that) {
case _ChangePhoneVerifyData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangePhoneVerifyData value)?  $default,){
final _that = this;
switch (_that) {
case _ChangePhoneVerifyData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'masked_mobile')  String maskedMobile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangePhoneVerifyData() when $default != null:
return $default(_that.maskedMobile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'masked_mobile')  String maskedMobile)  $default,) {final _that = this;
switch (_that) {
case _ChangePhoneVerifyData():
return $default(_that.maskedMobile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'masked_mobile')  String maskedMobile)?  $default,) {final _that = this;
switch (_that) {
case _ChangePhoneVerifyData() when $default != null:
return $default(_that.maskedMobile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangePhoneVerifyData implements ChangePhoneVerifyData {
  const _ChangePhoneVerifyData({@JsonKey(name: 'masked_mobile') required this.maskedMobile});
  factory _ChangePhoneVerifyData.fromJson(Map<String, dynamic> json) => _$ChangePhoneVerifyDataFromJson(json);

@override@JsonKey(name: 'masked_mobile') final  String maskedMobile;

/// Create a copy of ChangePhoneVerifyData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangePhoneVerifyDataCopyWith<_ChangePhoneVerifyData> get copyWith => __$ChangePhoneVerifyDataCopyWithImpl<_ChangePhoneVerifyData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangePhoneVerifyDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangePhoneVerifyData&&(identical(other.maskedMobile, maskedMobile) || other.maskedMobile == maskedMobile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maskedMobile);

@override
String toString() {
  return 'ChangePhoneVerifyData(maskedMobile: $maskedMobile)';
}


}

/// @nodoc
abstract mixin class _$ChangePhoneVerifyDataCopyWith<$Res> implements $ChangePhoneVerifyDataCopyWith<$Res> {
  factory _$ChangePhoneVerifyDataCopyWith(_ChangePhoneVerifyData value, $Res Function(_ChangePhoneVerifyData) _then) = __$ChangePhoneVerifyDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'masked_mobile') String maskedMobile
});




}
/// @nodoc
class __$ChangePhoneVerifyDataCopyWithImpl<$Res>
    implements _$ChangePhoneVerifyDataCopyWith<$Res> {
  __$ChangePhoneVerifyDataCopyWithImpl(this._self, this._then);

  final _ChangePhoneVerifyData _self;
  final $Res Function(_ChangePhoneVerifyData) _then;

/// Create a copy of ChangePhoneVerifyData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maskedMobile = null,}) {
  return _then(_ChangePhoneVerifyData(
maskedMobile: null == maskedMobile ? _self.maskedMobile : maskedMobile // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
