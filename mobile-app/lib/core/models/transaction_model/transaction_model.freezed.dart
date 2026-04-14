// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionModel {

 String get id;@JsonKey(name: 'coin_symbol') String get assetSymbol;@JsonKey(name: 'coinName') String? get assetName;@JsonKey(name: 'coinName_ar') String? get assetNameAr; String? get assetIconUrl; String get amount; String? get network; DateTime get createdAt; String? get txHash; String get status; String? get direction; String? get type;@JsonKey(name: 'networkIconUrl') String? get networkIconUrl;
/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionModelCopyWith<TransactionModel> get copyWith => _$TransactionModelCopyWithImpl<TransactionModel>(this as TransactionModel, _$identity);

  /// Serializes this TransactionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.assetSymbol, assetSymbol) || other.assetSymbol == assetSymbol)&&(identical(other.assetName, assetName) || other.assetName == assetName)&&(identical(other.assetNameAr, assetNameAr) || other.assetNameAr == assetNameAr)&&(identical(other.assetIconUrl, assetIconUrl) || other.assetIconUrl == assetIconUrl)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.network, network) || other.network == network)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.txHash, txHash) || other.txHash == txHash)&&(identical(other.status, status) || other.status == status)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.type, type) || other.type == type)&&(identical(other.networkIconUrl, networkIconUrl) || other.networkIconUrl == networkIconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,assetSymbol,assetName,assetNameAr,assetIconUrl,amount,network,createdAt,txHash,status,direction,type,networkIconUrl);

@override
String toString() {
  return 'TransactionModel(id: $id, assetSymbol: $assetSymbol, assetName: $assetName, assetNameAr: $assetNameAr, assetIconUrl: $assetIconUrl, amount: $amount, network: $network, createdAt: $createdAt, txHash: $txHash, status: $status, direction: $direction, type: $type, networkIconUrl: $networkIconUrl)';
}


}

/// @nodoc
abstract mixin class $TransactionModelCopyWith<$Res>  {
  factory $TransactionModelCopyWith(TransactionModel value, $Res Function(TransactionModel) _then) = _$TransactionModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'coin_symbol') String assetSymbol,@JsonKey(name: 'coinName') String? assetName,@JsonKey(name: 'coinName_ar') String? assetNameAr, String? assetIconUrl, String amount, String? network, DateTime createdAt, String? txHash, String status, String? direction, String? type,@JsonKey(name: 'networkIconUrl') String? networkIconUrl
});




}
/// @nodoc
class _$TransactionModelCopyWithImpl<$Res>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._self, this._then);

  final TransactionModel _self;
  final $Res Function(TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? assetSymbol = null,Object? assetName = freezed,Object? assetNameAr = freezed,Object? assetIconUrl = freezed,Object? amount = null,Object? network = freezed,Object? createdAt = null,Object? txHash = freezed,Object? status = null,Object? direction = freezed,Object? type = freezed,Object? networkIconUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetSymbol: null == assetSymbol ? _self.assetSymbol : assetSymbol // ignore: cast_nullable_to_non_nullable
as String,assetName: freezed == assetName ? _self.assetName : assetName // ignore: cast_nullable_to_non_nullable
as String?,assetNameAr: freezed == assetNameAr ? _self.assetNameAr : assetNameAr // ignore: cast_nullable_to_non_nullable
as String?,assetIconUrl: freezed == assetIconUrl ? _self.assetIconUrl : assetIconUrl // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,txHash: freezed == txHash ? _self.txHash : txHash // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,networkIconUrl: freezed == networkIconUrl ? _self.networkIconUrl : networkIconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionModel].
extension TransactionModelPatterns on TransactionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionModel value)  $default,){
final _that = this;
switch (_that) {
case _TransactionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'coin_symbol')  String assetSymbol, @JsonKey(name: 'coinName')  String? assetName, @JsonKey(name: 'coinName_ar')  String? assetNameAr,  String? assetIconUrl,  String amount,  String? network,  DateTime createdAt,  String? txHash,  String status,  String? direction,  String? type, @JsonKey(name: 'networkIconUrl')  String? networkIconUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.assetSymbol,_that.assetName,_that.assetNameAr,_that.assetIconUrl,_that.amount,_that.network,_that.createdAt,_that.txHash,_that.status,_that.direction,_that.type,_that.networkIconUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'coin_symbol')  String assetSymbol, @JsonKey(name: 'coinName')  String? assetName, @JsonKey(name: 'coinName_ar')  String? assetNameAr,  String? assetIconUrl,  String amount,  String? network,  DateTime createdAt,  String? txHash,  String status,  String? direction,  String? type, @JsonKey(name: 'networkIconUrl')  String? networkIconUrl)  $default,) {final _that = this;
switch (_that) {
case _TransactionModel():
return $default(_that.id,_that.assetSymbol,_that.assetName,_that.assetNameAr,_that.assetIconUrl,_that.amount,_that.network,_that.createdAt,_that.txHash,_that.status,_that.direction,_that.type,_that.networkIconUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'coin_symbol')  String assetSymbol, @JsonKey(name: 'coinName')  String? assetName, @JsonKey(name: 'coinName_ar')  String? assetNameAr,  String? assetIconUrl,  String amount,  String? network,  DateTime createdAt,  String? txHash,  String status,  String? direction,  String? type, @JsonKey(name: 'networkIconUrl')  String? networkIconUrl)?  $default,) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.assetSymbol,_that.assetName,_that.assetNameAr,_that.assetIconUrl,_that.amount,_that.network,_that.createdAt,_that.txHash,_that.status,_that.direction,_that.type,_that.networkIconUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionModel extends TransactionModel {
  const _TransactionModel({required this.id, @JsonKey(name: 'coin_symbol') required this.assetSymbol, @JsonKey(name: 'coinName') this.assetName, @JsonKey(name: 'coinName_ar') this.assetNameAr, this.assetIconUrl, required this.amount, this.network, required this.createdAt, this.txHash, required this.status, this.direction, this.type, @JsonKey(name: 'networkIconUrl') this.networkIconUrl}): super._();
  factory _TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'coin_symbol') final  String assetSymbol;
@override@JsonKey(name: 'coinName') final  String? assetName;
@override@JsonKey(name: 'coinName_ar') final  String? assetNameAr;
@override final  String? assetIconUrl;
@override final  String amount;
@override final  String? network;
@override final  DateTime createdAt;
@override final  String? txHash;
@override final  String status;
@override final  String? direction;
@override final  String? type;
@override@JsonKey(name: 'networkIconUrl') final  String? networkIconUrl;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionModelCopyWith<_TransactionModel> get copyWith => __$TransactionModelCopyWithImpl<_TransactionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.assetSymbol, assetSymbol) || other.assetSymbol == assetSymbol)&&(identical(other.assetName, assetName) || other.assetName == assetName)&&(identical(other.assetNameAr, assetNameAr) || other.assetNameAr == assetNameAr)&&(identical(other.assetIconUrl, assetIconUrl) || other.assetIconUrl == assetIconUrl)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.network, network) || other.network == network)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.txHash, txHash) || other.txHash == txHash)&&(identical(other.status, status) || other.status == status)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.type, type) || other.type == type)&&(identical(other.networkIconUrl, networkIconUrl) || other.networkIconUrl == networkIconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,assetSymbol,assetName,assetNameAr,assetIconUrl,amount,network,createdAt,txHash,status,direction,type,networkIconUrl);

@override
String toString() {
  return 'TransactionModel(id: $id, assetSymbol: $assetSymbol, assetName: $assetName, assetNameAr: $assetNameAr, assetIconUrl: $assetIconUrl, amount: $amount, network: $network, createdAt: $createdAt, txHash: $txHash, status: $status, direction: $direction, type: $type, networkIconUrl: $networkIconUrl)';
}


}

/// @nodoc
abstract mixin class _$TransactionModelCopyWith<$Res> implements $TransactionModelCopyWith<$Res> {
  factory _$TransactionModelCopyWith(_TransactionModel value, $Res Function(_TransactionModel) _then) = __$TransactionModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'coin_symbol') String assetSymbol,@JsonKey(name: 'coinName') String? assetName,@JsonKey(name: 'coinName_ar') String? assetNameAr, String? assetIconUrl, String amount, String? network, DateTime createdAt, String? txHash, String status, String? direction, String? type,@JsonKey(name: 'networkIconUrl') String? networkIconUrl
});




}
/// @nodoc
class __$TransactionModelCopyWithImpl<$Res>
    implements _$TransactionModelCopyWith<$Res> {
  __$TransactionModelCopyWithImpl(this._self, this._then);

  final _TransactionModel _self;
  final $Res Function(_TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetSymbol = null,Object? assetName = freezed,Object? assetNameAr = freezed,Object? assetIconUrl = freezed,Object? amount = null,Object? network = freezed,Object? createdAt = null,Object? txHash = freezed,Object? status = null,Object? direction = freezed,Object? type = freezed,Object? networkIconUrl = freezed,}) {
  return _then(_TransactionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetSymbol: null == assetSymbol ? _self.assetSymbol : assetSymbol // ignore: cast_nullable_to_non_nullable
as String,assetName: freezed == assetName ? _self.assetName : assetName // ignore: cast_nullable_to_non_nullable
as String?,assetNameAr: freezed == assetNameAr ? _self.assetNameAr : assetNameAr // ignore: cast_nullable_to_non_nullable
as String?,assetIconUrl: freezed == assetIconUrl ? _self.assetIconUrl : assetIconUrl // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,txHash: freezed == txHash ? _self.txHash : txHash // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,networkIconUrl: freezed == networkIconUrl ? _self.networkIconUrl : networkIconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
