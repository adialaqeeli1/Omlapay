// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'change_email_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChangeEmailStep1Data {

@JsonKey(name: 'masked_phone') String get maskedPhone;@JsonKey(name: 'otp_expiry_seconds') int get otpExpirySeconds;
/// Create a copy of ChangeEmailStep1Data
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeEmailStep1DataCopyWith<ChangeEmailStep1Data> get copyWith => _$ChangeEmailStep1DataCopyWithImpl<ChangeEmailStep1Data>(this as ChangeEmailStep1Data, _$identity);

  /// Serializes this ChangeEmailStep1Data to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeEmailStep1Data&&(identical(other.maskedPhone, maskedPhone) || other.maskedPhone == maskedPhone)&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maskedPhone,otpExpirySeconds);

@override
String toString() {
  return 'ChangeEmailStep1Data(maskedPhone: $maskedPhone, otpExpirySeconds: $otpExpirySeconds)';
}


}

/// @nodoc
abstract mixin class $ChangeEmailStep1DataCopyWith<$Res>  {
  factory $ChangeEmailStep1DataCopyWith(ChangeEmailStep1Data value, $Res Function(ChangeEmailStep1Data) _then) = _$ChangeEmailStep1DataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'masked_phone') String maskedPhone,@JsonKey(name: 'otp_expiry_seconds') int otpExpirySeconds
});




}
/// @nodoc
class _$ChangeEmailStep1DataCopyWithImpl<$Res>
    implements $ChangeEmailStep1DataCopyWith<$Res> {
  _$ChangeEmailStep1DataCopyWithImpl(this._self, this._then);

  final ChangeEmailStep1Data _self;
  final $Res Function(ChangeEmailStep1Data) _then;

/// Create a copy of ChangeEmailStep1Data
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maskedPhone = null,Object? otpExpirySeconds = null,}) {
  return _then(_self.copyWith(
maskedPhone: null == maskedPhone ? _self.maskedPhone : maskedPhone // ignore: cast_nullable_to_non_nullable
as String,otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangeEmailStep1Data].
extension ChangeEmailStep1DataPatterns on ChangeEmailStep1Data {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeEmailStep1Data value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeEmailStep1Data() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeEmailStep1Data value)  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailStep1Data():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeEmailStep1Data value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailStep1Data() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'masked_phone')  String maskedPhone, @JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeEmailStep1Data() when $default != null:
return $default(_that.maskedPhone,_that.otpExpirySeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'masked_phone')  String maskedPhone, @JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds)  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailStep1Data():
return $default(_that.maskedPhone,_that.otpExpirySeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'masked_phone')  String maskedPhone, @JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds)?  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailStep1Data() when $default != null:
return $default(_that.maskedPhone,_that.otpExpirySeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeEmailStep1Data implements ChangeEmailStep1Data {
  const _ChangeEmailStep1Data({@JsonKey(name: 'masked_phone') required this.maskedPhone, @JsonKey(name: 'otp_expiry_seconds') required this.otpExpirySeconds});
  factory _ChangeEmailStep1Data.fromJson(Map<String, dynamic> json) => _$ChangeEmailStep1DataFromJson(json);

@override@JsonKey(name: 'masked_phone') final  String maskedPhone;
@override@JsonKey(name: 'otp_expiry_seconds') final  int otpExpirySeconds;

/// Create a copy of ChangeEmailStep1Data
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeEmailStep1DataCopyWith<_ChangeEmailStep1Data> get copyWith => __$ChangeEmailStep1DataCopyWithImpl<_ChangeEmailStep1Data>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeEmailStep1DataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeEmailStep1Data&&(identical(other.maskedPhone, maskedPhone) || other.maskedPhone == maskedPhone)&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maskedPhone,otpExpirySeconds);

@override
String toString() {
  return 'ChangeEmailStep1Data(maskedPhone: $maskedPhone, otpExpirySeconds: $otpExpirySeconds)';
}


}

/// @nodoc
abstract mixin class _$ChangeEmailStep1DataCopyWith<$Res> implements $ChangeEmailStep1DataCopyWith<$Res> {
  factory _$ChangeEmailStep1DataCopyWith(_ChangeEmailStep1Data value, $Res Function(_ChangeEmailStep1Data) _then) = __$ChangeEmailStep1DataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'masked_phone') String maskedPhone,@JsonKey(name: 'otp_expiry_seconds') int otpExpirySeconds
});




}
/// @nodoc
class __$ChangeEmailStep1DataCopyWithImpl<$Res>
    implements _$ChangeEmailStep1DataCopyWith<$Res> {
  __$ChangeEmailStep1DataCopyWithImpl(this._self, this._then);

  final _ChangeEmailStep1Data _self;
  final $Res Function(_ChangeEmailStep1Data) _then;

/// Create a copy of ChangeEmailStep1Data
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maskedPhone = null,Object? otpExpirySeconds = null,}) {
  return _then(_ChangeEmailStep1Data(
maskedPhone: null == maskedPhone ? _self.maskedPhone : maskedPhone // ignore: cast_nullable_to_non_nullable
as String,otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ChangeEmailStep2Data {

@JsonKey(name: 'change_email_token') String get changeEmailToken;
/// Create a copy of ChangeEmailStep2Data
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeEmailStep2DataCopyWith<ChangeEmailStep2Data> get copyWith => _$ChangeEmailStep2DataCopyWithImpl<ChangeEmailStep2Data>(this as ChangeEmailStep2Data, _$identity);

  /// Serializes this ChangeEmailStep2Data to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeEmailStep2Data&&(identical(other.changeEmailToken, changeEmailToken) || other.changeEmailToken == changeEmailToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,changeEmailToken);

@override
String toString() {
  return 'ChangeEmailStep2Data(changeEmailToken: $changeEmailToken)';
}


}

/// @nodoc
abstract mixin class $ChangeEmailStep2DataCopyWith<$Res>  {
  factory $ChangeEmailStep2DataCopyWith(ChangeEmailStep2Data value, $Res Function(ChangeEmailStep2Data) _then) = _$ChangeEmailStep2DataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'change_email_token') String changeEmailToken
});




}
/// @nodoc
class _$ChangeEmailStep2DataCopyWithImpl<$Res>
    implements $ChangeEmailStep2DataCopyWith<$Res> {
  _$ChangeEmailStep2DataCopyWithImpl(this._self, this._then);

  final ChangeEmailStep2Data _self;
  final $Res Function(ChangeEmailStep2Data) _then;

/// Create a copy of ChangeEmailStep2Data
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? changeEmailToken = null,}) {
  return _then(_self.copyWith(
changeEmailToken: null == changeEmailToken ? _self.changeEmailToken : changeEmailToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangeEmailStep2Data].
extension ChangeEmailStep2DataPatterns on ChangeEmailStep2Data {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeEmailStep2Data value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeEmailStep2Data() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeEmailStep2Data value)  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailStep2Data():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeEmailStep2Data value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailStep2Data() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'change_email_token')  String changeEmailToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeEmailStep2Data() when $default != null:
return $default(_that.changeEmailToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'change_email_token')  String changeEmailToken)  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailStep2Data():
return $default(_that.changeEmailToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'change_email_token')  String changeEmailToken)?  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailStep2Data() when $default != null:
return $default(_that.changeEmailToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeEmailStep2Data implements ChangeEmailStep2Data {
  const _ChangeEmailStep2Data({@JsonKey(name: 'change_email_token') required this.changeEmailToken});
  factory _ChangeEmailStep2Data.fromJson(Map<String, dynamic> json) => _$ChangeEmailStep2DataFromJson(json);

@override@JsonKey(name: 'change_email_token') final  String changeEmailToken;

/// Create a copy of ChangeEmailStep2Data
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeEmailStep2DataCopyWith<_ChangeEmailStep2Data> get copyWith => __$ChangeEmailStep2DataCopyWithImpl<_ChangeEmailStep2Data>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeEmailStep2DataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeEmailStep2Data&&(identical(other.changeEmailToken, changeEmailToken) || other.changeEmailToken == changeEmailToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,changeEmailToken);

@override
String toString() {
  return 'ChangeEmailStep2Data(changeEmailToken: $changeEmailToken)';
}


}

/// @nodoc
abstract mixin class _$ChangeEmailStep2DataCopyWith<$Res> implements $ChangeEmailStep2DataCopyWith<$Res> {
  factory _$ChangeEmailStep2DataCopyWith(_ChangeEmailStep2Data value, $Res Function(_ChangeEmailStep2Data) _then) = __$ChangeEmailStep2DataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'change_email_token') String changeEmailToken
});




}
/// @nodoc
class __$ChangeEmailStep2DataCopyWithImpl<$Res>
    implements _$ChangeEmailStep2DataCopyWith<$Res> {
  __$ChangeEmailStep2DataCopyWithImpl(this._self, this._then);

  final _ChangeEmailStep2Data _self;
  final $Res Function(_ChangeEmailStep2Data) _then;

/// Create a copy of ChangeEmailStep2Data
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? changeEmailToken = null,}) {
  return _then(_ChangeEmailStep2Data(
changeEmailToken: null == changeEmailToken ? _self.changeEmailToken : changeEmailToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ChangeEmailStep3Data {

@JsonKey(name: 'change_email_token') String get changeEmailToken; String get email;@JsonKey(name: 'otp_expiry_seconds') int get otpExpirySeconds;
/// Create a copy of ChangeEmailStep3Data
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeEmailStep3DataCopyWith<ChangeEmailStep3Data> get copyWith => _$ChangeEmailStep3DataCopyWithImpl<ChangeEmailStep3Data>(this as ChangeEmailStep3Data, _$identity);

  /// Serializes this ChangeEmailStep3Data to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeEmailStep3Data&&(identical(other.changeEmailToken, changeEmailToken) || other.changeEmailToken == changeEmailToken)&&(identical(other.email, email) || other.email == email)&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,changeEmailToken,email,otpExpirySeconds);

@override
String toString() {
  return 'ChangeEmailStep3Data(changeEmailToken: $changeEmailToken, email: $email, otpExpirySeconds: $otpExpirySeconds)';
}


}

/// @nodoc
abstract mixin class $ChangeEmailStep3DataCopyWith<$Res>  {
  factory $ChangeEmailStep3DataCopyWith(ChangeEmailStep3Data value, $Res Function(ChangeEmailStep3Data) _then) = _$ChangeEmailStep3DataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'change_email_token') String changeEmailToken, String email,@JsonKey(name: 'otp_expiry_seconds') int otpExpirySeconds
});




}
/// @nodoc
class _$ChangeEmailStep3DataCopyWithImpl<$Res>
    implements $ChangeEmailStep3DataCopyWith<$Res> {
  _$ChangeEmailStep3DataCopyWithImpl(this._self, this._then);

  final ChangeEmailStep3Data _self;
  final $Res Function(ChangeEmailStep3Data) _then;

/// Create a copy of ChangeEmailStep3Data
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? changeEmailToken = null,Object? email = null,Object? otpExpirySeconds = null,}) {
  return _then(_self.copyWith(
changeEmailToken: null == changeEmailToken ? _self.changeEmailToken : changeEmailToken // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangeEmailStep3Data].
extension ChangeEmailStep3DataPatterns on ChangeEmailStep3Data {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeEmailStep3Data value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeEmailStep3Data() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeEmailStep3Data value)  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailStep3Data():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeEmailStep3Data value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailStep3Data() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'change_email_token')  String changeEmailToken,  String email, @JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeEmailStep3Data() when $default != null:
return $default(_that.changeEmailToken,_that.email,_that.otpExpirySeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'change_email_token')  String changeEmailToken,  String email, @JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds)  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailStep3Data():
return $default(_that.changeEmailToken,_that.email,_that.otpExpirySeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'change_email_token')  String changeEmailToken,  String email, @JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds)?  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailStep3Data() when $default != null:
return $default(_that.changeEmailToken,_that.email,_that.otpExpirySeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeEmailStep3Data implements ChangeEmailStep3Data {
  const _ChangeEmailStep3Data({@JsonKey(name: 'change_email_token') required this.changeEmailToken, required this.email, @JsonKey(name: 'otp_expiry_seconds') required this.otpExpirySeconds});
  factory _ChangeEmailStep3Data.fromJson(Map<String, dynamic> json) => _$ChangeEmailStep3DataFromJson(json);

@override@JsonKey(name: 'change_email_token') final  String changeEmailToken;
@override final  String email;
@override@JsonKey(name: 'otp_expiry_seconds') final  int otpExpirySeconds;

/// Create a copy of ChangeEmailStep3Data
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeEmailStep3DataCopyWith<_ChangeEmailStep3Data> get copyWith => __$ChangeEmailStep3DataCopyWithImpl<_ChangeEmailStep3Data>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeEmailStep3DataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeEmailStep3Data&&(identical(other.changeEmailToken, changeEmailToken) || other.changeEmailToken == changeEmailToken)&&(identical(other.email, email) || other.email == email)&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,changeEmailToken,email,otpExpirySeconds);

@override
String toString() {
  return 'ChangeEmailStep3Data(changeEmailToken: $changeEmailToken, email: $email, otpExpirySeconds: $otpExpirySeconds)';
}


}

/// @nodoc
abstract mixin class _$ChangeEmailStep3DataCopyWith<$Res> implements $ChangeEmailStep3DataCopyWith<$Res> {
  factory _$ChangeEmailStep3DataCopyWith(_ChangeEmailStep3Data value, $Res Function(_ChangeEmailStep3Data) _then) = __$ChangeEmailStep3DataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'change_email_token') String changeEmailToken, String email,@JsonKey(name: 'otp_expiry_seconds') int otpExpirySeconds
});




}
/// @nodoc
class __$ChangeEmailStep3DataCopyWithImpl<$Res>
    implements _$ChangeEmailStep3DataCopyWith<$Res> {
  __$ChangeEmailStep3DataCopyWithImpl(this._self, this._then);

  final _ChangeEmailStep3Data _self;
  final $Res Function(_ChangeEmailStep3Data) _then;

/// Create a copy of ChangeEmailStep3Data
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? changeEmailToken = null,Object? email = null,Object? otpExpirySeconds = null,}) {
  return _then(_ChangeEmailStep3Data(
changeEmailToken: null == changeEmailToken ? _self.changeEmailToken : changeEmailToken // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ChangeEmailStep4Data {

@JsonKey(name: 'change_email_token') String get changeEmailToken;
/// Create a copy of ChangeEmailStep4Data
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeEmailStep4DataCopyWith<ChangeEmailStep4Data> get copyWith => _$ChangeEmailStep4DataCopyWithImpl<ChangeEmailStep4Data>(this as ChangeEmailStep4Data, _$identity);

  /// Serializes this ChangeEmailStep4Data to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeEmailStep4Data&&(identical(other.changeEmailToken, changeEmailToken) || other.changeEmailToken == changeEmailToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,changeEmailToken);

@override
String toString() {
  return 'ChangeEmailStep4Data(changeEmailToken: $changeEmailToken)';
}


}

/// @nodoc
abstract mixin class $ChangeEmailStep4DataCopyWith<$Res>  {
  factory $ChangeEmailStep4DataCopyWith(ChangeEmailStep4Data value, $Res Function(ChangeEmailStep4Data) _then) = _$ChangeEmailStep4DataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'change_email_token') String changeEmailToken
});




}
/// @nodoc
class _$ChangeEmailStep4DataCopyWithImpl<$Res>
    implements $ChangeEmailStep4DataCopyWith<$Res> {
  _$ChangeEmailStep4DataCopyWithImpl(this._self, this._then);

  final ChangeEmailStep4Data _self;
  final $Res Function(ChangeEmailStep4Data) _then;

/// Create a copy of ChangeEmailStep4Data
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? changeEmailToken = null,}) {
  return _then(_self.copyWith(
changeEmailToken: null == changeEmailToken ? _self.changeEmailToken : changeEmailToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangeEmailStep4Data].
extension ChangeEmailStep4DataPatterns on ChangeEmailStep4Data {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeEmailStep4Data value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeEmailStep4Data() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeEmailStep4Data value)  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailStep4Data():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeEmailStep4Data value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailStep4Data() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'change_email_token')  String changeEmailToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeEmailStep4Data() when $default != null:
return $default(_that.changeEmailToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'change_email_token')  String changeEmailToken)  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailStep4Data():
return $default(_that.changeEmailToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'change_email_token')  String changeEmailToken)?  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailStep4Data() when $default != null:
return $default(_that.changeEmailToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeEmailStep4Data implements ChangeEmailStep4Data {
  const _ChangeEmailStep4Data({@JsonKey(name: 'change_email_token') required this.changeEmailToken});
  factory _ChangeEmailStep4Data.fromJson(Map<String, dynamic> json) => _$ChangeEmailStep4DataFromJson(json);

@override@JsonKey(name: 'change_email_token') final  String changeEmailToken;

/// Create a copy of ChangeEmailStep4Data
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeEmailStep4DataCopyWith<_ChangeEmailStep4Data> get copyWith => __$ChangeEmailStep4DataCopyWithImpl<_ChangeEmailStep4Data>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeEmailStep4DataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeEmailStep4Data&&(identical(other.changeEmailToken, changeEmailToken) || other.changeEmailToken == changeEmailToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,changeEmailToken);

@override
String toString() {
  return 'ChangeEmailStep4Data(changeEmailToken: $changeEmailToken)';
}


}

/// @nodoc
abstract mixin class _$ChangeEmailStep4DataCopyWith<$Res> implements $ChangeEmailStep4DataCopyWith<$Res> {
  factory _$ChangeEmailStep4DataCopyWith(_ChangeEmailStep4Data value, $Res Function(_ChangeEmailStep4Data) _then) = __$ChangeEmailStep4DataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'change_email_token') String changeEmailToken
});




}
/// @nodoc
class __$ChangeEmailStep4DataCopyWithImpl<$Res>
    implements _$ChangeEmailStep4DataCopyWith<$Res> {
  __$ChangeEmailStep4DataCopyWithImpl(this._self, this._then);

  final _ChangeEmailStep4Data _self;
  final $Res Function(_ChangeEmailStep4Data) _then;

/// Create a copy of ChangeEmailStep4Data
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? changeEmailToken = null,}) {
  return _then(_ChangeEmailStep4Data(
changeEmailToken: null == changeEmailToken ? _self.changeEmailToken : changeEmailToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ChangeEmailStep5Data {

 String get email;
/// Create a copy of ChangeEmailStep5Data
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeEmailStep5DataCopyWith<ChangeEmailStep5Data> get copyWith => _$ChangeEmailStep5DataCopyWithImpl<ChangeEmailStep5Data>(this as ChangeEmailStep5Data, _$identity);

  /// Serializes this ChangeEmailStep5Data to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeEmailStep5Data&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'ChangeEmailStep5Data(email: $email)';
}


}

/// @nodoc
abstract mixin class $ChangeEmailStep5DataCopyWith<$Res>  {
  factory $ChangeEmailStep5DataCopyWith(ChangeEmailStep5Data value, $Res Function(ChangeEmailStep5Data) _then) = _$ChangeEmailStep5DataCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$ChangeEmailStep5DataCopyWithImpl<$Res>
    implements $ChangeEmailStep5DataCopyWith<$Res> {
  _$ChangeEmailStep5DataCopyWithImpl(this._self, this._then);

  final ChangeEmailStep5Data _self;
  final $Res Function(ChangeEmailStep5Data) _then;

/// Create a copy of ChangeEmailStep5Data
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangeEmailStep5Data].
extension ChangeEmailStep5DataPatterns on ChangeEmailStep5Data {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeEmailStep5Data value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeEmailStep5Data() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeEmailStep5Data value)  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailStep5Data():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeEmailStep5Data value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailStep5Data() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeEmailStep5Data() when $default != null:
return $default(_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email)  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailStep5Data():
return $default(_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email)?  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailStep5Data() when $default != null:
return $default(_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeEmailStep5Data implements ChangeEmailStep5Data {
  const _ChangeEmailStep5Data({required this.email});
  factory _ChangeEmailStep5Data.fromJson(Map<String, dynamic> json) => _$ChangeEmailStep5DataFromJson(json);

@override final  String email;

/// Create a copy of ChangeEmailStep5Data
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeEmailStep5DataCopyWith<_ChangeEmailStep5Data> get copyWith => __$ChangeEmailStep5DataCopyWithImpl<_ChangeEmailStep5Data>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeEmailStep5DataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeEmailStep5Data&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'ChangeEmailStep5Data(email: $email)';
}


}

/// @nodoc
abstract mixin class _$ChangeEmailStep5DataCopyWith<$Res> implements $ChangeEmailStep5DataCopyWith<$Res> {
  factory _$ChangeEmailStep5DataCopyWith(_ChangeEmailStep5Data value, $Res Function(_ChangeEmailStep5Data) _then) = __$ChangeEmailStep5DataCopyWithImpl;
@override @useResult
$Res call({
 String email
});




}
/// @nodoc
class __$ChangeEmailStep5DataCopyWithImpl<$Res>
    implements _$ChangeEmailStep5DataCopyWith<$Res> {
  __$ChangeEmailStep5DataCopyWithImpl(this._self, this._then);

  final _ChangeEmailStep5Data _self;
  final $Res Function(_ChangeEmailStep5Data) _then;

/// Create a copy of ChangeEmailStep5Data
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_ChangeEmailStep5Data(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
