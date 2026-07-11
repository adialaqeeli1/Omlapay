// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scanned_qr_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScannedQrPayload {

 String? get address; String get symbol; String get network; double? get amount;
/// Create a copy of ScannedQrPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScannedQrPayloadCopyWith<ScannedQrPayload> get copyWith => _$ScannedQrPayloadCopyWithImpl<ScannedQrPayload>(this as ScannedQrPayload, _$identity);

  /// Serializes this ScannedQrPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScannedQrPayload&&(identical(other.address, address) || other.address == address)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.network, network) || other.network == network)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,symbol,network,amount);

@override
String toString() {
  return 'ScannedQrPayload(address: $address, symbol: $symbol, network: $network, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $ScannedQrPayloadCopyWith<$Res>  {
  factory $ScannedQrPayloadCopyWith(ScannedQrPayload value, $Res Function(ScannedQrPayload) _then) = _$ScannedQrPayloadCopyWithImpl;
@useResult
$Res call({
 String? address, String symbol, String network, double? amount
});




}
/// @nodoc
class _$ScannedQrPayloadCopyWithImpl<$Res>
    implements $ScannedQrPayloadCopyWith<$Res> {
  _$ScannedQrPayloadCopyWithImpl(this._self, this._then);

  final ScannedQrPayload _self;
  final $Res Function(ScannedQrPayload) _then;

/// Create a copy of ScannedQrPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = freezed,Object? symbol = null,Object? network = null,Object? amount = freezed,}) {
  return _then(_self.copyWith(
address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScannedQrPayload].
extension ScannedQrPayloadPatterns on ScannedQrPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScannedQrPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScannedQrPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScannedQrPayload value)  $default,){
final _that = this;
switch (_that) {
case _ScannedQrPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScannedQrPayload value)?  $default,){
final _that = this;
switch (_that) {
case _ScannedQrPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? address,  String symbol,  String network,  double? amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScannedQrPayload() when $default != null:
return $default(_that.address,_that.symbol,_that.network,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? address,  String symbol,  String network,  double? amount)  $default,) {final _that = this;
switch (_that) {
case _ScannedQrPayload():
return $default(_that.address,_that.symbol,_that.network,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? address,  String symbol,  String network,  double? amount)?  $default,) {final _that = this;
switch (_that) {
case _ScannedQrPayload() when $default != null:
return $default(_that.address,_that.symbol,_that.network,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScannedQrPayload implements ScannedQrPayload {
  const _ScannedQrPayload({this.address, this.symbol = '', this.network = '', this.amount});
  factory _ScannedQrPayload.fromJson(Map<String, dynamic> json) => _$ScannedQrPayloadFromJson(json);

@override final  String? address;
@override@JsonKey() final  String symbol;
@override@JsonKey() final  String network;
@override final  double? amount;

/// Create a copy of ScannedQrPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScannedQrPayloadCopyWith<_ScannedQrPayload> get copyWith => __$ScannedQrPayloadCopyWithImpl<_ScannedQrPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScannedQrPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScannedQrPayload&&(identical(other.address, address) || other.address == address)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.network, network) || other.network == network)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,symbol,network,amount);

@override
String toString() {
  return 'ScannedQrPayload(address: $address, symbol: $symbol, network: $network, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$ScannedQrPayloadCopyWith<$Res> implements $ScannedQrPayloadCopyWith<$Res> {
  factory _$ScannedQrPayloadCopyWith(_ScannedQrPayload value, $Res Function(_ScannedQrPayload) _then) = __$ScannedQrPayloadCopyWithImpl;
@override @useResult
$Res call({
 String? address, String symbol, String network, double? amount
});




}
/// @nodoc
class __$ScannedQrPayloadCopyWithImpl<$Res>
    implements _$ScannedQrPayloadCopyWith<$Res> {
  __$ScannedQrPayloadCopyWithImpl(this._self, this._then);

  final _ScannedQrPayload _self;
  final $Res Function(_ScannedQrPayload) _then;

/// Create a copy of ScannedQrPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = freezed,Object? symbol = null,Object? network = null,Object? amount = freezed,}) {
  return _then(_ScannedQrPayload(
address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
