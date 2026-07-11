// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'send_quote_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SendQuoteModel {

 String get coin; String get network; String get amount; String get amountUsd; String get fee; String get sentAmount; String get available; String get recipientType; String? get recipientName; bool get isRegistered;
/// Create a copy of SendQuoteModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendQuoteModelCopyWith<SendQuoteModel> get copyWith => _$SendQuoteModelCopyWithImpl<SendQuoteModel>(this as SendQuoteModel, _$identity);

  /// Serializes this SendQuoteModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendQuoteModel&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.network, network) || other.network == network)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountUsd, amountUsd) || other.amountUsd == amountUsd)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.sentAmount, sentAmount) || other.sentAmount == sentAmount)&&(identical(other.available, available) || other.available == available)&&(identical(other.recipientType, recipientType) || other.recipientType == recipientType)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.isRegistered, isRegistered) || other.isRegistered == isRegistered));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coin,network,amount,amountUsd,fee,sentAmount,available,recipientType,recipientName,isRegistered);

@override
String toString() {
  return 'SendQuoteModel(coin: $coin, network: $network, amount: $amount, amountUsd: $amountUsd, fee: $fee, sentAmount: $sentAmount, available: $available, recipientType: $recipientType, recipientName: $recipientName, isRegistered: $isRegistered)';
}


}

/// @nodoc
abstract mixin class $SendQuoteModelCopyWith<$Res>  {
  factory $SendQuoteModelCopyWith(SendQuoteModel value, $Res Function(SendQuoteModel) _then) = _$SendQuoteModelCopyWithImpl;
@useResult
$Res call({
 String coin, String network, String amount, String amountUsd, String fee, String sentAmount, String available, String recipientType, String? recipientName, bool isRegistered
});




}
/// @nodoc
class _$SendQuoteModelCopyWithImpl<$Res>
    implements $SendQuoteModelCopyWith<$Res> {
  _$SendQuoteModelCopyWithImpl(this._self, this._then);

  final SendQuoteModel _self;
  final $Res Function(SendQuoteModel) _then;

/// Create a copy of SendQuoteModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coin = null,Object? network = null,Object? amount = null,Object? amountUsd = null,Object? fee = null,Object? sentAmount = null,Object? available = null,Object? recipientType = null,Object? recipientName = freezed,Object? isRegistered = null,}) {
  return _then(_self.copyWith(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,amountUsd: null == amountUsd ? _self.amountUsd : amountUsd // ignore: cast_nullable_to_non_nullable
as String,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as String,sentAmount: null == sentAmount ? _self.sentAmount : sentAmount // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as String,recipientType: null == recipientType ? _self.recipientType : recipientType // ignore: cast_nullable_to_non_nullable
as String,recipientName: freezed == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String?,isRegistered: null == isRegistered ? _self.isRegistered : isRegistered // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SendQuoteModel].
extension SendQuoteModelPatterns on SendQuoteModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SendQuoteModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendQuoteModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SendQuoteModel value)  $default,){
final _that = this;
switch (_that) {
case _SendQuoteModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SendQuoteModel value)?  $default,){
final _that = this;
switch (_that) {
case _SendQuoteModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String coin,  String network,  String amount,  String amountUsd,  String fee,  String sentAmount,  String available,  String recipientType,  String? recipientName,  bool isRegistered)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendQuoteModel() when $default != null:
return $default(_that.coin,_that.network,_that.amount,_that.amountUsd,_that.fee,_that.sentAmount,_that.available,_that.recipientType,_that.recipientName,_that.isRegistered);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String coin,  String network,  String amount,  String amountUsd,  String fee,  String sentAmount,  String available,  String recipientType,  String? recipientName,  bool isRegistered)  $default,) {final _that = this;
switch (_that) {
case _SendQuoteModel():
return $default(_that.coin,_that.network,_that.amount,_that.amountUsd,_that.fee,_that.sentAmount,_that.available,_that.recipientType,_that.recipientName,_that.isRegistered);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String coin,  String network,  String amount,  String amountUsd,  String fee,  String sentAmount,  String available,  String recipientType,  String? recipientName,  bool isRegistered)?  $default,) {final _that = this;
switch (_that) {
case _SendQuoteModel() when $default != null:
return $default(_that.coin,_that.network,_that.amount,_that.amountUsd,_that.fee,_that.sentAmount,_that.available,_that.recipientType,_that.recipientName,_that.isRegistered);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SendQuoteModel implements SendQuoteModel {
  const _SendQuoteModel({this.coin = '', this.network = '', this.amount = '', this.amountUsd = '', this.fee = '', this.sentAmount = '', this.available = '', this.recipientType = '', this.recipientName, this.isRegistered = false});
  factory _SendQuoteModel.fromJson(Map<String, dynamic> json) => _$SendQuoteModelFromJson(json);

@override@JsonKey() final  String coin;
@override@JsonKey() final  String network;
@override@JsonKey() final  String amount;
@override@JsonKey() final  String amountUsd;
@override@JsonKey() final  String fee;
@override@JsonKey() final  String sentAmount;
@override@JsonKey() final  String available;
@override@JsonKey() final  String recipientType;
@override final  String? recipientName;
@override@JsonKey() final  bool isRegistered;

/// Create a copy of SendQuoteModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendQuoteModelCopyWith<_SendQuoteModel> get copyWith => __$SendQuoteModelCopyWithImpl<_SendQuoteModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SendQuoteModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendQuoteModel&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.network, network) || other.network == network)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountUsd, amountUsd) || other.amountUsd == amountUsd)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.sentAmount, sentAmount) || other.sentAmount == sentAmount)&&(identical(other.available, available) || other.available == available)&&(identical(other.recipientType, recipientType) || other.recipientType == recipientType)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.isRegistered, isRegistered) || other.isRegistered == isRegistered));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coin,network,amount,amountUsd,fee,sentAmount,available,recipientType,recipientName,isRegistered);

@override
String toString() {
  return 'SendQuoteModel(coin: $coin, network: $network, amount: $amount, amountUsd: $amountUsd, fee: $fee, sentAmount: $sentAmount, available: $available, recipientType: $recipientType, recipientName: $recipientName, isRegistered: $isRegistered)';
}


}

/// @nodoc
abstract mixin class _$SendQuoteModelCopyWith<$Res> implements $SendQuoteModelCopyWith<$Res> {
  factory _$SendQuoteModelCopyWith(_SendQuoteModel value, $Res Function(_SendQuoteModel) _then) = __$SendQuoteModelCopyWithImpl;
@override @useResult
$Res call({
 String coin, String network, String amount, String amountUsd, String fee, String sentAmount, String available, String recipientType, String? recipientName, bool isRegistered
});




}
/// @nodoc
class __$SendQuoteModelCopyWithImpl<$Res>
    implements _$SendQuoteModelCopyWith<$Res> {
  __$SendQuoteModelCopyWithImpl(this._self, this._then);

  final _SendQuoteModel _self;
  final $Res Function(_SendQuoteModel) _then;

/// Create a copy of SendQuoteModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coin = null,Object? network = null,Object? amount = null,Object? amountUsd = null,Object? fee = null,Object? sentAmount = null,Object? available = null,Object? recipientType = null,Object? recipientName = freezed,Object? isRegistered = null,}) {
  return _then(_SendQuoteModel(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,amountUsd: null == amountUsd ? _self.amountUsd : amountUsd // ignore: cast_nullable_to_non_nullable
as String,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as String,sentAmount: null == sentAmount ? _self.sentAmount : sentAmount // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as String,recipientType: null == recipientType ? _self.recipientType : recipientType // ignore: cast_nullable_to_non_nullable
as String,recipientName: freezed == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String?,isRegistered: null == isRegistered ? _self.isRegistered : isRegistered // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
