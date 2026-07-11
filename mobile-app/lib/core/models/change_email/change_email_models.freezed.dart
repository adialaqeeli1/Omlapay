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

@JsonKey(name: 'otp_expiry_seconds') int get otpExpirySeconds;@JsonKey(name: 'masked_phone') String? get maskedPhone;@JsonKey(name: 'masked_email') String? get maskedEmail;
/// Create a copy of ChangeEmailStep1Data
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeEmailStep1DataCopyWith<ChangeEmailStep1Data> get copyWith => _$ChangeEmailStep1DataCopyWithImpl<ChangeEmailStep1Data>(this as ChangeEmailStep1Data, _$identity);

  /// Serializes this ChangeEmailStep1Data to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeEmailStep1Data&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds)&&(identical(other.maskedPhone, maskedPhone) || other.maskedPhone == maskedPhone)&&(identical(other.maskedEmail, maskedEmail) || other.maskedEmail == maskedEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,otpExpirySeconds,maskedPhone,maskedEmail);

@override
String toString() {
  return 'ChangeEmailStep1Data(otpExpirySeconds: $otpExpirySeconds, maskedPhone: $maskedPhone, maskedEmail: $maskedEmail)';
}


}

/// @nodoc
abstract mixin class $ChangeEmailStep1DataCopyWith<$Res>  {
  factory $ChangeEmailStep1DataCopyWith(ChangeEmailStep1Data value, $Res Function(ChangeEmailStep1Data) _then) = _$ChangeEmailStep1DataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'otp_expiry_seconds') int otpExpirySeconds,@JsonKey(name: 'masked_phone') String? maskedPhone,@JsonKey(name: 'masked_email') String? maskedEmail
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
@pragma('vm:prefer-inline') @override $Res call({Object? otpExpirySeconds = null,Object? maskedPhone = freezed,Object? maskedEmail = freezed,}) {
  return _then(_self.copyWith(
otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,maskedPhone: freezed == maskedPhone ? _self.maskedPhone : maskedPhone // ignore: cast_nullable_to_non_nullable
as String?,maskedEmail: freezed == maskedEmail ? _self.maskedEmail : maskedEmail // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds, @JsonKey(name: 'masked_phone')  String? maskedPhone, @JsonKey(name: 'masked_email')  String? maskedEmail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeEmailStep1Data() when $default != null:
return $default(_that.otpExpirySeconds,_that.maskedPhone,_that.maskedEmail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds, @JsonKey(name: 'masked_phone')  String? maskedPhone, @JsonKey(name: 'masked_email')  String? maskedEmail)  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailStep1Data():
return $default(_that.otpExpirySeconds,_that.maskedPhone,_that.maskedEmail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds, @JsonKey(name: 'masked_phone')  String? maskedPhone, @JsonKey(name: 'masked_email')  String? maskedEmail)?  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailStep1Data() when $default != null:
return $default(_that.otpExpirySeconds,_that.maskedPhone,_that.maskedEmail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeEmailStep1Data implements ChangeEmailStep1Data {
  const _ChangeEmailStep1Data({@JsonKey(name: 'otp_expiry_seconds') required this.otpExpirySeconds, @JsonKey(name: 'masked_phone') this.maskedPhone, @JsonKey(name: 'masked_email') this.maskedEmail});
  factory _ChangeEmailStep1Data.fromJson(Map<String, dynamic> json) => _$ChangeEmailStep1DataFromJson(json);

@override@JsonKey(name: 'otp_expiry_seconds') final  int otpExpirySeconds;
@override@JsonKey(name: 'masked_phone') final  String? maskedPhone;
@override@JsonKey(name: 'masked_email') final  String? maskedEmail;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeEmailStep1Data&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds)&&(identical(other.maskedPhone, maskedPhone) || other.maskedPhone == maskedPhone)&&(identical(other.maskedEmail, maskedEmail) || other.maskedEmail == maskedEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,otpExpirySeconds,maskedPhone,maskedEmail);

@override
String toString() {
  return 'ChangeEmailStep1Data(otpExpirySeconds: $otpExpirySeconds, maskedPhone: $maskedPhone, maskedEmail: $maskedEmail)';
}


}

/// @nodoc
abstract mixin class _$ChangeEmailStep1DataCopyWith<$Res> implements $ChangeEmailStep1DataCopyWith<$Res> {
  factory _$ChangeEmailStep1DataCopyWith(_ChangeEmailStep1Data value, $Res Function(_ChangeEmailStep1Data) _then) = __$ChangeEmailStep1DataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'otp_expiry_seconds') int otpExpirySeconds,@JsonKey(name: 'masked_phone') String? maskedPhone,@JsonKey(name: 'masked_email') String? maskedEmail
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
@override @pragma('vm:prefer-inline') $Res call({Object? otpExpirySeconds = null,Object? maskedPhone = freezed,Object? maskedEmail = freezed,}) {
  return _then(_ChangeEmailStep1Data(
otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,maskedPhone: freezed == maskedPhone ? _self.maskedPhone : maskedPhone // ignore: cast_nullable_to_non_nullable
as String?,maskedEmail: freezed == maskedEmail ? _self.maskedEmail : maskedEmail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChangeEmailTokenData {

@JsonKey(name: 'change_email_token') String get changeEmailToken;
/// Create a copy of ChangeEmailTokenData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeEmailTokenDataCopyWith<ChangeEmailTokenData> get copyWith => _$ChangeEmailTokenDataCopyWithImpl<ChangeEmailTokenData>(this as ChangeEmailTokenData, _$identity);

  /// Serializes this ChangeEmailTokenData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeEmailTokenData&&(identical(other.changeEmailToken, changeEmailToken) || other.changeEmailToken == changeEmailToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,changeEmailToken);

@override
String toString() {
  return 'ChangeEmailTokenData(changeEmailToken: $changeEmailToken)';
}


}

/// @nodoc
abstract mixin class $ChangeEmailTokenDataCopyWith<$Res>  {
  factory $ChangeEmailTokenDataCopyWith(ChangeEmailTokenData value, $Res Function(ChangeEmailTokenData) _then) = _$ChangeEmailTokenDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'change_email_token') String changeEmailToken
});




}
/// @nodoc
class _$ChangeEmailTokenDataCopyWithImpl<$Res>
    implements $ChangeEmailTokenDataCopyWith<$Res> {
  _$ChangeEmailTokenDataCopyWithImpl(this._self, this._then);

  final ChangeEmailTokenData _self;
  final $Res Function(ChangeEmailTokenData) _then;

/// Create a copy of ChangeEmailTokenData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? changeEmailToken = null,}) {
  return _then(_self.copyWith(
changeEmailToken: null == changeEmailToken ? _self.changeEmailToken : changeEmailToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangeEmailTokenData].
extension ChangeEmailTokenDataPatterns on ChangeEmailTokenData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeEmailTokenData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeEmailTokenData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeEmailTokenData value)  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailTokenData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeEmailTokenData value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailTokenData() when $default != null:
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
case _ChangeEmailTokenData() when $default != null:
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
case _ChangeEmailTokenData():
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
case _ChangeEmailTokenData() when $default != null:
return $default(_that.changeEmailToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeEmailTokenData implements ChangeEmailTokenData {
  const _ChangeEmailTokenData({@JsonKey(name: 'change_email_token') required this.changeEmailToken});
  factory _ChangeEmailTokenData.fromJson(Map<String, dynamic> json) => _$ChangeEmailTokenDataFromJson(json);

@override@JsonKey(name: 'change_email_token') final  String changeEmailToken;

/// Create a copy of ChangeEmailTokenData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeEmailTokenDataCopyWith<_ChangeEmailTokenData> get copyWith => __$ChangeEmailTokenDataCopyWithImpl<_ChangeEmailTokenData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeEmailTokenDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeEmailTokenData&&(identical(other.changeEmailToken, changeEmailToken) || other.changeEmailToken == changeEmailToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,changeEmailToken);

@override
String toString() {
  return 'ChangeEmailTokenData(changeEmailToken: $changeEmailToken)';
}


}

/// @nodoc
abstract mixin class _$ChangeEmailTokenDataCopyWith<$Res> implements $ChangeEmailTokenDataCopyWith<$Res> {
  factory _$ChangeEmailTokenDataCopyWith(_ChangeEmailTokenData value, $Res Function(_ChangeEmailTokenData) _then) = __$ChangeEmailTokenDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'change_email_token') String changeEmailToken
});




}
/// @nodoc
class __$ChangeEmailTokenDataCopyWithImpl<$Res>
    implements _$ChangeEmailTokenDataCopyWith<$Res> {
  __$ChangeEmailTokenDataCopyWithImpl(this._self, this._then);

  final _ChangeEmailTokenData _self;
  final $Res Function(_ChangeEmailTokenData) _then;

/// Create a copy of ChangeEmailTokenData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? changeEmailToken = null,}) {
  return _then(_ChangeEmailTokenData(
changeEmailToken: null == changeEmailToken ? _self.changeEmailToken : changeEmailToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ChangeEmailRequestNewEmailData {

@JsonKey(name: 'otp_expiry_seconds') int get otpExpirySeconds;@JsonKey(name: 'change_email_token') String? get changeEmailToken; String? get email;
/// Create a copy of ChangeEmailRequestNewEmailData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeEmailRequestNewEmailDataCopyWith<ChangeEmailRequestNewEmailData> get copyWith => _$ChangeEmailRequestNewEmailDataCopyWithImpl<ChangeEmailRequestNewEmailData>(this as ChangeEmailRequestNewEmailData, _$identity);

  /// Serializes this ChangeEmailRequestNewEmailData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeEmailRequestNewEmailData&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds)&&(identical(other.changeEmailToken, changeEmailToken) || other.changeEmailToken == changeEmailToken)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,otpExpirySeconds,changeEmailToken,email);

@override
String toString() {
  return 'ChangeEmailRequestNewEmailData(otpExpirySeconds: $otpExpirySeconds, changeEmailToken: $changeEmailToken, email: $email)';
}


}

/// @nodoc
abstract mixin class $ChangeEmailRequestNewEmailDataCopyWith<$Res>  {
  factory $ChangeEmailRequestNewEmailDataCopyWith(ChangeEmailRequestNewEmailData value, $Res Function(ChangeEmailRequestNewEmailData) _then) = _$ChangeEmailRequestNewEmailDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'otp_expiry_seconds') int otpExpirySeconds,@JsonKey(name: 'change_email_token') String? changeEmailToken, String? email
});




}
/// @nodoc
class _$ChangeEmailRequestNewEmailDataCopyWithImpl<$Res>
    implements $ChangeEmailRequestNewEmailDataCopyWith<$Res> {
  _$ChangeEmailRequestNewEmailDataCopyWithImpl(this._self, this._then);

  final ChangeEmailRequestNewEmailData _self;
  final $Res Function(ChangeEmailRequestNewEmailData) _then;

/// Create a copy of ChangeEmailRequestNewEmailData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? otpExpirySeconds = null,Object? changeEmailToken = freezed,Object? email = freezed,}) {
  return _then(_self.copyWith(
otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,changeEmailToken: freezed == changeEmailToken ? _self.changeEmailToken : changeEmailToken // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangeEmailRequestNewEmailData].
extension ChangeEmailRequestNewEmailDataPatterns on ChangeEmailRequestNewEmailData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeEmailRequestNewEmailData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeEmailRequestNewEmailData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeEmailRequestNewEmailData value)  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailRequestNewEmailData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeEmailRequestNewEmailData value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailRequestNewEmailData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds, @JsonKey(name: 'change_email_token')  String? changeEmailToken,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeEmailRequestNewEmailData() when $default != null:
return $default(_that.otpExpirySeconds,_that.changeEmailToken,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds, @JsonKey(name: 'change_email_token')  String? changeEmailToken,  String? email)  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailRequestNewEmailData():
return $default(_that.otpExpirySeconds,_that.changeEmailToken,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'otp_expiry_seconds')  int otpExpirySeconds, @JsonKey(name: 'change_email_token')  String? changeEmailToken,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailRequestNewEmailData() when $default != null:
return $default(_that.otpExpirySeconds,_that.changeEmailToken,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeEmailRequestNewEmailData implements ChangeEmailRequestNewEmailData {
  const _ChangeEmailRequestNewEmailData({@JsonKey(name: 'otp_expiry_seconds') required this.otpExpirySeconds, @JsonKey(name: 'change_email_token') this.changeEmailToken, this.email});
  factory _ChangeEmailRequestNewEmailData.fromJson(Map<String, dynamic> json) => _$ChangeEmailRequestNewEmailDataFromJson(json);

@override@JsonKey(name: 'otp_expiry_seconds') final  int otpExpirySeconds;
@override@JsonKey(name: 'change_email_token') final  String? changeEmailToken;
@override final  String? email;

/// Create a copy of ChangeEmailRequestNewEmailData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeEmailRequestNewEmailDataCopyWith<_ChangeEmailRequestNewEmailData> get copyWith => __$ChangeEmailRequestNewEmailDataCopyWithImpl<_ChangeEmailRequestNewEmailData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeEmailRequestNewEmailDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeEmailRequestNewEmailData&&(identical(other.otpExpirySeconds, otpExpirySeconds) || other.otpExpirySeconds == otpExpirySeconds)&&(identical(other.changeEmailToken, changeEmailToken) || other.changeEmailToken == changeEmailToken)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,otpExpirySeconds,changeEmailToken,email);

@override
String toString() {
  return 'ChangeEmailRequestNewEmailData(otpExpirySeconds: $otpExpirySeconds, changeEmailToken: $changeEmailToken, email: $email)';
}


}

/// @nodoc
abstract mixin class _$ChangeEmailRequestNewEmailDataCopyWith<$Res> implements $ChangeEmailRequestNewEmailDataCopyWith<$Res> {
  factory _$ChangeEmailRequestNewEmailDataCopyWith(_ChangeEmailRequestNewEmailData value, $Res Function(_ChangeEmailRequestNewEmailData) _then) = __$ChangeEmailRequestNewEmailDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'otp_expiry_seconds') int otpExpirySeconds,@JsonKey(name: 'change_email_token') String? changeEmailToken, String? email
});




}
/// @nodoc
class __$ChangeEmailRequestNewEmailDataCopyWithImpl<$Res>
    implements _$ChangeEmailRequestNewEmailDataCopyWith<$Res> {
  __$ChangeEmailRequestNewEmailDataCopyWithImpl(this._self, this._then);

  final _ChangeEmailRequestNewEmailData _self;
  final $Res Function(_ChangeEmailRequestNewEmailData) _then;

/// Create a copy of ChangeEmailRequestNewEmailData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? otpExpirySeconds = null,Object? changeEmailToken = freezed,Object? email = freezed,}) {
  return _then(_ChangeEmailRequestNewEmailData(
otpExpirySeconds: null == otpExpirySeconds ? _self.otpExpirySeconds : otpExpirySeconds // ignore: cast_nullable_to_non_nullable
as int,changeEmailToken: freezed == changeEmailToken ? _self.changeEmailToken : changeEmailToken // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChangeEmailVerifyNewEmailData {

 String? get email;
/// Create a copy of ChangeEmailVerifyNewEmailData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeEmailVerifyNewEmailDataCopyWith<ChangeEmailVerifyNewEmailData> get copyWith => _$ChangeEmailVerifyNewEmailDataCopyWithImpl<ChangeEmailVerifyNewEmailData>(this as ChangeEmailVerifyNewEmailData, _$identity);

  /// Serializes this ChangeEmailVerifyNewEmailData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeEmailVerifyNewEmailData&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'ChangeEmailVerifyNewEmailData(email: $email)';
}


}

/// @nodoc
abstract mixin class $ChangeEmailVerifyNewEmailDataCopyWith<$Res>  {
  factory $ChangeEmailVerifyNewEmailDataCopyWith(ChangeEmailVerifyNewEmailData value, $Res Function(ChangeEmailVerifyNewEmailData) _then) = _$ChangeEmailVerifyNewEmailDataCopyWithImpl;
@useResult
$Res call({
 String? email
});




}
/// @nodoc
class _$ChangeEmailVerifyNewEmailDataCopyWithImpl<$Res>
    implements $ChangeEmailVerifyNewEmailDataCopyWith<$Res> {
  _$ChangeEmailVerifyNewEmailDataCopyWithImpl(this._self, this._then);

  final ChangeEmailVerifyNewEmailData _self;
  final $Res Function(ChangeEmailVerifyNewEmailData) _then;

/// Create a copy of ChangeEmailVerifyNewEmailData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = freezed,}) {
  return _then(_self.copyWith(
email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangeEmailVerifyNewEmailData].
extension ChangeEmailVerifyNewEmailDataPatterns on ChangeEmailVerifyNewEmailData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeEmailVerifyNewEmailData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeEmailVerifyNewEmailData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeEmailVerifyNewEmailData value)  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailVerifyNewEmailData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeEmailVerifyNewEmailData value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeEmailVerifyNewEmailData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeEmailVerifyNewEmailData() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? email)  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailVerifyNewEmailData():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? email)?  $default,) {final _that = this;
switch (_that) {
case _ChangeEmailVerifyNewEmailData() when $default != null:
return $default(_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeEmailVerifyNewEmailData implements ChangeEmailVerifyNewEmailData {
  const _ChangeEmailVerifyNewEmailData({this.email});
  factory _ChangeEmailVerifyNewEmailData.fromJson(Map<String, dynamic> json) => _$ChangeEmailVerifyNewEmailDataFromJson(json);

@override final  String? email;

/// Create a copy of ChangeEmailVerifyNewEmailData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeEmailVerifyNewEmailDataCopyWith<_ChangeEmailVerifyNewEmailData> get copyWith => __$ChangeEmailVerifyNewEmailDataCopyWithImpl<_ChangeEmailVerifyNewEmailData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeEmailVerifyNewEmailDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeEmailVerifyNewEmailData&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'ChangeEmailVerifyNewEmailData(email: $email)';
}


}

/// @nodoc
abstract mixin class _$ChangeEmailVerifyNewEmailDataCopyWith<$Res> implements $ChangeEmailVerifyNewEmailDataCopyWith<$Res> {
  factory _$ChangeEmailVerifyNewEmailDataCopyWith(_ChangeEmailVerifyNewEmailData value, $Res Function(_ChangeEmailVerifyNewEmailData) _then) = __$ChangeEmailVerifyNewEmailDataCopyWithImpl;
@override @useResult
$Res call({
 String? email
});




}
/// @nodoc
class __$ChangeEmailVerifyNewEmailDataCopyWithImpl<$Res>
    implements _$ChangeEmailVerifyNewEmailDataCopyWith<$Res> {
  __$ChangeEmailVerifyNewEmailDataCopyWithImpl(this._self, this._then);

  final _ChangeEmailVerifyNewEmailData _self;
  final $Res Function(_ChangeEmailVerifyNewEmailData) _then;

/// Create a copy of ChangeEmailVerifyNewEmailData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = freezed,}) {
  return _then(_ChangeEmailVerifyNewEmailData(
email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
