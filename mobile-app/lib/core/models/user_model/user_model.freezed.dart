// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String? get id;@JsonKey(readValue: _readPhoneNumber) String? get fullMobileNumber; String? get status; String? get email; String get mobileNumber;@JsonKey(readValue: _readCountryCode) String get countryCode; String get password;// 6 digit numeric
 String get firstName; String get lastName; bool get isVerified; bool get twoFactorEnabled; List<WalletNetworkModel> get wallets; bool get walletsAvailable;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullMobileNumber, fullMobileNumber) || other.fullMobileNumber == fullMobileNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.password, password) || other.password == password)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.twoFactorEnabled, twoFactorEnabled) || other.twoFactorEnabled == twoFactorEnabled)&&const DeepCollectionEquality().equals(other.wallets, wallets)&&(identical(other.walletsAvailable, walletsAvailable) || other.walletsAvailable == walletsAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullMobileNumber,status,email,mobileNumber,countryCode,password,firstName,lastName,isVerified,twoFactorEnabled,const DeepCollectionEquality().hash(wallets),walletsAvailable);

@override
String toString() {
  return 'UserModel(id: $id, fullMobileNumber: $fullMobileNumber, status: $status, email: $email, mobileNumber: $mobileNumber, countryCode: $countryCode, password: $password, firstName: $firstName, lastName: $lastName, isVerified: $isVerified, twoFactorEnabled: $twoFactorEnabled, wallets: $wallets, walletsAvailable: $walletsAvailable)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(readValue: _readPhoneNumber) String? fullMobileNumber, String? status, String? email, String mobileNumber,@JsonKey(readValue: _readCountryCode) String countryCode, String password, String firstName, String lastName, bool isVerified, bool twoFactorEnabled, List<WalletNetworkModel> wallets, bool walletsAvailable
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? fullMobileNumber = freezed,Object? status = freezed,Object? email = freezed,Object? mobileNumber = null,Object? countryCode = null,Object? password = null,Object? firstName = null,Object? lastName = null,Object? isVerified = null,Object? twoFactorEnabled = null,Object? wallets = null,Object? walletsAvailable = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,fullMobileNumber: freezed == fullMobileNumber ? _self.fullMobileNumber : fullMobileNumber // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,twoFactorEnabled: null == twoFactorEnabled ? _self.twoFactorEnabled : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
as bool,wallets: null == wallets ? _self.wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<WalletNetworkModel>,walletsAvailable: null == walletsAvailable ? _self.walletsAvailable : walletsAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(readValue: _readPhoneNumber)  String? fullMobileNumber,  String? status,  String? email,  String mobileNumber, @JsonKey(readValue: _readCountryCode)  String countryCode,  String password,  String firstName,  String lastName,  bool isVerified,  bool twoFactorEnabled,  List<WalletNetworkModel> wallets,  bool walletsAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.fullMobileNumber,_that.status,_that.email,_that.mobileNumber,_that.countryCode,_that.password,_that.firstName,_that.lastName,_that.isVerified,_that.twoFactorEnabled,_that.wallets,_that.walletsAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(readValue: _readPhoneNumber)  String? fullMobileNumber,  String? status,  String? email,  String mobileNumber, @JsonKey(readValue: _readCountryCode)  String countryCode,  String password,  String firstName,  String lastName,  bool isVerified,  bool twoFactorEnabled,  List<WalletNetworkModel> wallets,  bool walletsAvailable)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.fullMobileNumber,_that.status,_that.email,_that.mobileNumber,_that.countryCode,_that.password,_that.firstName,_that.lastName,_that.isVerified,_that.twoFactorEnabled,_that.wallets,_that.walletsAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(readValue: _readPhoneNumber)  String? fullMobileNumber,  String? status,  String? email,  String mobileNumber, @JsonKey(readValue: _readCountryCode)  String countryCode,  String password,  String firstName,  String lastName,  bool isVerified,  bool twoFactorEnabled,  List<WalletNetworkModel> wallets,  bool walletsAvailable)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.fullMobileNumber,_that.status,_that.email,_that.mobileNumber,_that.countryCode,_that.password,_that.firstName,_that.lastName,_that.isVerified,_that.twoFactorEnabled,_that.wallets,_that.walletsAvailable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel extends UserModel {
  const _UserModel({this.id, @JsonKey(readValue: _readPhoneNumber) this.fullMobileNumber, this.status, this.email, this.mobileNumber = '', @JsonKey(readValue: _readCountryCode) this.countryCode = '', this.password = '', this.firstName = '', this.lastName = '', this.isVerified = false, this.twoFactorEnabled = false, final  List<WalletNetworkModel> wallets = const [], this.walletsAvailable = false}): _wallets = wallets,super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String? id;
@override@JsonKey(readValue: _readPhoneNumber) final  String? fullMobileNumber;
@override final  String? status;
@override final  String? email;
@override@JsonKey() final  String mobileNumber;
@override@JsonKey(readValue: _readCountryCode) final  String countryCode;
@override@JsonKey() final  String password;
// 6 digit numeric
@override@JsonKey() final  String firstName;
@override@JsonKey() final  String lastName;
@override@JsonKey() final  bool isVerified;
@override@JsonKey() final  bool twoFactorEnabled;
 final  List<WalletNetworkModel> _wallets;
@override@JsonKey() List<WalletNetworkModel> get wallets {
  if (_wallets is EqualUnmodifiableListView) return _wallets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wallets);
}

@override@JsonKey() final  bool walletsAvailable;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullMobileNumber, fullMobileNumber) || other.fullMobileNumber == fullMobileNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.password, password) || other.password == password)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.twoFactorEnabled, twoFactorEnabled) || other.twoFactorEnabled == twoFactorEnabled)&&const DeepCollectionEquality().equals(other._wallets, _wallets)&&(identical(other.walletsAvailable, walletsAvailable) || other.walletsAvailable == walletsAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullMobileNumber,status,email,mobileNumber,countryCode,password,firstName,lastName,isVerified,twoFactorEnabled,const DeepCollectionEquality().hash(_wallets),walletsAvailable);

@override
String toString() {
  return 'UserModel(id: $id, fullMobileNumber: $fullMobileNumber, status: $status, email: $email, mobileNumber: $mobileNumber, countryCode: $countryCode, password: $password, firstName: $firstName, lastName: $lastName, isVerified: $isVerified, twoFactorEnabled: $twoFactorEnabled, wallets: $wallets, walletsAvailable: $walletsAvailable)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(readValue: _readPhoneNumber) String? fullMobileNumber, String? status, String? email, String mobileNumber,@JsonKey(readValue: _readCountryCode) String countryCode, String password, String firstName, String lastName, bool isVerified, bool twoFactorEnabled, List<WalletNetworkModel> wallets, bool walletsAvailable
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? fullMobileNumber = freezed,Object? status = freezed,Object? email = freezed,Object? mobileNumber = null,Object? countryCode = null,Object? password = null,Object? firstName = null,Object? lastName = null,Object? isVerified = null,Object? twoFactorEnabled = null,Object? wallets = null,Object? walletsAvailable = null,}) {
  return _then(_UserModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,fullMobileNumber: freezed == fullMobileNumber ? _self.fullMobileNumber : fullMobileNumber // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,twoFactorEnabled: null == twoFactorEnabled ? _self.twoFactorEnabled : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
as bool,wallets: null == wallets ? _self._wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<WalletNetworkModel>,walletsAvailable: null == walletsAvailable ? _self.walletsAvailable : walletsAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
