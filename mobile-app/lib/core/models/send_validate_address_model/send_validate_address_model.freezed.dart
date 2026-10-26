// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'send_validate_address_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SendValidateAddressModel {

 String? get type; bool get isSelf; String? get network; List<String> get networks; String? get coin; String? get guessedCoin; String? get confidence; List<String> get candidates; String? get maskedPhone;
/// Create a copy of SendValidateAddressModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendValidateAddressModelCopyWith<SendValidateAddressModel> get copyWith => _$SendValidateAddressModelCopyWithImpl<SendValidateAddressModel>(this as SendValidateAddressModel, _$identity);

  /// Serializes this SendValidateAddressModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendValidateAddressModel&&(identical(other.type, type) || other.type == type)&&(identical(other.isSelf, isSelf) || other.isSelf == isSelf)&&(identical(other.network, network) || other.network == network)&&const DeepCollectionEquality().equals(other.networks, networks)&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.guessedCoin, guessedCoin) || other.guessedCoin == guessedCoin)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other.candidates, candidates)&&(identical(other.maskedPhone, maskedPhone) || other.maskedPhone == maskedPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,isSelf,network,const DeepCollectionEquality().hash(networks),coin,guessedCoin,confidence,const DeepCollectionEquality().hash(candidates),maskedPhone);

@override
String toString() {
  return 'SendValidateAddressModel(type: $type, isSelf: $isSelf, network: $network, networks: $networks, coin: $coin, guessedCoin: $guessedCoin, confidence: $confidence, candidates: $candidates, maskedPhone: $maskedPhone)';
}


}

/// @nodoc
abstract mixin class $SendValidateAddressModelCopyWith<$Res>  {
  factory $SendValidateAddressModelCopyWith(SendValidateAddressModel value, $Res Function(SendValidateAddressModel) _then) = _$SendValidateAddressModelCopyWithImpl;
@useResult
$Res call({
 String? type, bool isSelf, String? network, List<String> networks, String? coin, String? guessedCoin, String? confidence, List<String> candidates, String? maskedPhone
});




}
/// @nodoc
class _$SendValidateAddressModelCopyWithImpl<$Res>
    implements $SendValidateAddressModelCopyWith<$Res> {
  _$SendValidateAddressModelCopyWithImpl(this._self, this._then);

  final SendValidateAddressModel _self;
  final $Res Function(SendValidateAddressModel) _then;

/// Create a copy of SendValidateAddressModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? isSelf = null,Object? network = freezed,Object? networks = null,Object? coin = freezed,Object? guessedCoin = freezed,Object? confidence = freezed,Object? candidates = null,Object? maskedPhone = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,isSelf: null == isSelf ? _self.isSelf : isSelf // ignore: cast_nullable_to_non_nullable
as bool,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,networks: null == networks ? _self.networks : networks // ignore: cast_nullable_to_non_nullable
as List<String>,coin: freezed == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String?,guessedCoin: freezed == guessedCoin ? _self.guessedCoin : guessedCoin // ignore: cast_nullable_to_non_nullable
as String?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as String?,candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<String>,maskedPhone: freezed == maskedPhone ? _self.maskedPhone : maskedPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SendValidateAddressModel].
extension SendValidateAddressModelPatterns on SendValidateAddressModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SendValidateAddressModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendValidateAddressModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SendValidateAddressModel value)  $default,){
final _that = this;
switch (_that) {
case _SendValidateAddressModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SendValidateAddressModel value)?  $default,){
final _that = this;
switch (_that) {
case _SendValidateAddressModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? type,  bool isSelf,  String? network,  List<String> networks,  String? coin,  String? guessedCoin,  String? confidence,  List<String> candidates,  String? maskedPhone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendValidateAddressModel() when $default != null:
return $default(_that.type,_that.isSelf,_that.network,_that.networks,_that.coin,_that.guessedCoin,_that.confidence,_that.candidates,_that.maskedPhone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? type,  bool isSelf,  String? network,  List<String> networks,  String? coin,  String? guessedCoin,  String? confidence,  List<String> candidates,  String? maskedPhone)  $default,) {final _that = this;
switch (_that) {
case _SendValidateAddressModel():
return $default(_that.type,_that.isSelf,_that.network,_that.networks,_that.coin,_that.guessedCoin,_that.confidence,_that.candidates,_that.maskedPhone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? type,  bool isSelf,  String? network,  List<String> networks,  String? coin,  String? guessedCoin,  String? confidence,  List<String> candidates,  String? maskedPhone)?  $default,) {final _that = this;
switch (_that) {
case _SendValidateAddressModel() when $default != null:
return $default(_that.type,_that.isSelf,_that.network,_that.networks,_that.coin,_that.guessedCoin,_that.confidence,_that.candidates,_that.maskedPhone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SendValidateAddressModel implements SendValidateAddressModel {
  const _SendValidateAddressModel({this.type, this.isSelf = false, this.network, final  List<String> networks = const <String>[], this.coin, this.guessedCoin, this.confidence, final  List<String> candidates = const <String>[], this.maskedPhone}): _networks = networks,_candidates = candidates;
  factory _SendValidateAddressModel.fromJson(Map<String, dynamic> json) => _$SendValidateAddressModelFromJson(json);

@override final  String? type;
@override@JsonKey() final  bool isSelf;
@override final  String? network;
 final  List<String> _networks;
@override@JsonKey() List<String> get networks {
  if (_networks is EqualUnmodifiableListView) return _networks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_networks);
}

@override final  String? coin;
@override final  String? guessedCoin;
@override final  String? confidence;
 final  List<String> _candidates;
@override@JsonKey() List<String> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}

@override final  String? maskedPhone;

/// Create a copy of SendValidateAddressModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendValidateAddressModelCopyWith<_SendValidateAddressModel> get copyWith => __$SendValidateAddressModelCopyWithImpl<_SendValidateAddressModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SendValidateAddressModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendValidateAddressModel&&(identical(other.type, type) || other.type == type)&&(identical(other.isSelf, isSelf) || other.isSelf == isSelf)&&(identical(other.network, network) || other.network == network)&&const DeepCollectionEquality().equals(other._networks, _networks)&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.guessedCoin, guessedCoin) || other.guessedCoin == guessedCoin)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other._candidates, _candidates)&&(identical(other.maskedPhone, maskedPhone) || other.maskedPhone == maskedPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,isSelf,network,const DeepCollectionEquality().hash(_networks),coin,guessedCoin,confidence,const DeepCollectionEquality().hash(_candidates),maskedPhone);

@override
String toString() {
  return 'SendValidateAddressModel(type: $type, isSelf: $isSelf, network: $network, networks: $networks, coin: $coin, guessedCoin: $guessedCoin, confidence: $confidence, candidates: $candidates, maskedPhone: $maskedPhone)';
}


}

/// @nodoc
abstract mixin class _$SendValidateAddressModelCopyWith<$Res> implements $SendValidateAddressModelCopyWith<$Res> {
  factory _$SendValidateAddressModelCopyWith(_SendValidateAddressModel value, $Res Function(_SendValidateAddressModel) _then) = __$SendValidateAddressModelCopyWithImpl;
@override @useResult
$Res call({
 String? type, bool isSelf, String? network, List<String> networks, String? coin, String? guessedCoin, String? confidence, List<String> candidates, String? maskedPhone
});




}
/// @nodoc
class __$SendValidateAddressModelCopyWithImpl<$Res>
    implements _$SendValidateAddressModelCopyWith<$Res> {
  __$SendValidateAddressModelCopyWithImpl(this._self, this._then);

  final _SendValidateAddressModel _self;
  final $Res Function(_SendValidateAddressModel) _then;

/// Create a copy of SendValidateAddressModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? isSelf = null,Object? network = freezed,Object? networks = null,Object? coin = freezed,Object? guessedCoin = freezed,Object? confidence = freezed,Object? candidates = null,Object? maskedPhone = freezed,}) {
  return _then(_SendValidateAddressModel(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,isSelf: null == isSelf ? _self.isSelf : isSelf // ignore: cast_nullable_to_non_nullable
as bool,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,networks: null == networks ? _self._networks : networks // ignore: cast_nullable_to_non_nullable
as List<String>,coin: freezed == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String?,guessedCoin: freezed == guessedCoin ? _self.guessedCoin : guessedCoin // ignore: cast_nullable_to_non_nullable
as String?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as String?,candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<String>,maskedPhone: freezed == maskedPhone ? _self.maskedPhone : maskedPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
