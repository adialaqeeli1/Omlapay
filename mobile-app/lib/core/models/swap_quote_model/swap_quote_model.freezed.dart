// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swap_quote_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SwapQuoteModel {

 String get fromCoin; String get toCoin; String get fromAmount; String get fromAmountUsd; String get estimatedToAmount; String get estimatedToAmountUsd; String get exchangeRate; String get binanceFee; String get omlapayFee; String get totalFee; String get available; String get minFromAmount; String get maxFromAmount;
/// Create a copy of SwapQuoteModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwapQuoteModelCopyWith<SwapQuoteModel> get copyWith => _$SwapQuoteModelCopyWithImpl<SwapQuoteModel>(this as SwapQuoteModel, _$identity);

  /// Serializes this SwapQuoteModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwapQuoteModel&&(identical(other.fromCoin, fromCoin) || other.fromCoin == fromCoin)&&(identical(other.toCoin, toCoin) || other.toCoin == toCoin)&&(identical(other.fromAmount, fromAmount) || other.fromAmount == fromAmount)&&(identical(other.fromAmountUsd, fromAmountUsd) || other.fromAmountUsd == fromAmountUsd)&&(identical(other.estimatedToAmount, estimatedToAmount) || other.estimatedToAmount == estimatedToAmount)&&(identical(other.estimatedToAmountUsd, estimatedToAmountUsd) || other.estimatedToAmountUsd == estimatedToAmountUsd)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.binanceFee, binanceFee) || other.binanceFee == binanceFee)&&(identical(other.omlapayFee, omlapayFee) || other.omlapayFee == omlapayFee)&&(identical(other.totalFee, totalFee) || other.totalFee == totalFee)&&(identical(other.available, available) || other.available == available)&&(identical(other.minFromAmount, minFromAmount) || other.minFromAmount == minFromAmount)&&(identical(other.maxFromAmount, maxFromAmount) || other.maxFromAmount == maxFromAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromCoin,toCoin,fromAmount,fromAmountUsd,estimatedToAmount,estimatedToAmountUsd,exchangeRate,binanceFee,omlapayFee,totalFee,available,minFromAmount,maxFromAmount);

@override
String toString() {
  return 'SwapQuoteModel(fromCoin: $fromCoin, toCoin: $toCoin, fromAmount: $fromAmount, fromAmountUsd: $fromAmountUsd, estimatedToAmount: $estimatedToAmount, estimatedToAmountUsd: $estimatedToAmountUsd, exchangeRate: $exchangeRate, binanceFee: $binanceFee, omlapayFee: $omlapayFee, totalFee: $totalFee, available: $available, minFromAmount: $minFromAmount, maxFromAmount: $maxFromAmount)';
}


}

/// @nodoc
abstract mixin class $SwapQuoteModelCopyWith<$Res>  {
  factory $SwapQuoteModelCopyWith(SwapQuoteModel value, $Res Function(SwapQuoteModel) _then) = _$SwapQuoteModelCopyWithImpl;
@useResult
$Res call({
 String fromCoin, String toCoin, String fromAmount, String fromAmountUsd, String estimatedToAmount, String estimatedToAmountUsd, String exchangeRate, String binanceFee, String omlapayFee, String totalFee, String available, String minFromAmount, String maxFromAmount
});




}
/// @nodoc
class _$SwapQuoteModelCopyWithImpl<$Res>
    implements $SwapQuoteModelCopyWith<$Res> {
  _$SwapQuoteModelCopyWithImpl(this._self, this._then);

  final SwapQuoteModel _self;
  final $Res Function(SwapQuoteModel) _then;

/// Create a copy of SwapQuoteModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromCoin = null,Object? toCoin = null,Object? fromAmount = null,Object? fromAmountUsd = null,Object? estimatedToAmount = null,Object? estimatedToAmountUsd = null,Object? exchangeRate = null,Object? binanceFee = null,Object? omlapayFee = null,Object? totalFee = null,Object? available = null,Object? minFromAmount = null,Object? maxFromAmount = null,}) {
  return _then(_self.copyWith(
fromCoin: null == fromCoin ? _self.fromCoin : fromCoin // ignore: cast_nullable_to_non_nullable
as String,toCoin: null == toCoin ? _self.toCoin : toCoin // ignore: cast_nullable_to_non_nullable
as String,fromAmount: null == fromAmount ? _self.fromAmount : fromAmount // ignore: cast_nullable_to_non_nullable
as String,fromAmountUsd: null == fromAmountUsd ? _self.fromAmountUsd : fromAmountUsd // ignore: cast_nullable_to_non_nullable
as String,estimatedToAmount: null == estimatedToAmount ? _self.estimatedToAmount : estimatedToAmount // ignore: cast_nullable_to_non_nullable
as String,estimatedToAmountUsd: null == estimatedToAmountUsd ? _self.estimatedToAmountUsd : estimatedToAmountUsd // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as String,binanceFee: null == binanceFee ? _self.binanceFee : binanceFee // ignore: cast_nullable_to_non_nullable
as String,omlapayFee: null == omlapayFee ? _self.omlapayFee : omlapayFee // ignore: cast_nullable_to_non_nullable
as String,totalFee: null == totalFee ? _self.totalFee : totalFee // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as String,minFromAmount: null == minFromAmount ? _self.minFromAmount : minFromAmount // ignore: cast_nullable_to_non_nullable
as String,maxFromAmount: null == maxFromAmount ? _self.maxFromAmount : maxFromAmount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SwapQuoteModel].
extension SwapQuoteModelPatterns on SwapQuoteModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwapQuoteModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwapQuoteModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwapQuoteModel value)  $default,){
final _that = this;
switch (_that) {
case _SwapQuoteModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwapQuoteModel value)?  $default,){
final _that = this;
switch (_that) {
case _SwapQuoteModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fromCoin,  String toCoin,  String fromAmount,  String fromAmountUsd,  String estimatedToAmount,  String estimatedToAmountUsd,  String exchangeRate,  String binanceFee,  String omlapayFee,  String totalFee,  String available,  String minFromAmount,  String maxFromAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwapQuoteModel() when $default != null:
return $default(_that.fromCoin,_that.toCoin,_that.fromAmount,_that.fromAmountUsd,_that.estimatedToAmount,_that.estimatedToAmountUsd,_that.exchangeRate,_that.binanceFee,_that.omlapayFee,_that.totalFee,_that.available,_that.minFromAmount,_that.maxFromAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fromCoin,  String toCoin,  String fromAmount,  String fromAmountUsd,  String estimatedToAmount,  String estimatedToAmountUsd,  String exchangeRate,  String binanceFee,  String omlapayFee,  String totalFee,  String available,  String minFromAmount,  String maxFromAmount)  $default,) {final _that = this;
switch (_that) {
case _SwapQuoteModel():
return $default(_that.fromCoin,_that.toCoin,_that.fromAmount,_that.fromAmountUsd,_that.estimatedToAmount,_that.estimatedToAmountUsd,_that.exchangeRate,_that.binanceFee,_that.omlapayFee,_that.totalFee,_that.available,_that.minFromAmount,_that.maxFromAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fromCoin,  String toCoin,  String fromAmount,  String fromAmountUsd,  String estimatedToAmount,  String estimatedToAmountUsd,  String exchangeRate,  String binanceFee,  String omlapayFee,  String totalFee,  String available,  String minFromAmount,  String maxFromAmount)?  $default,) {final _that = this;
switch (_that) {
case _SwapQuoteModel() when $default != null:
return $default(_that.fromCoin,_that.toCoin,_that.fromAmount,_that.fromAmountUsd,_that.estimatedToAmount,_that.estimatedToAmountUsd,_that.exchangeRate,_that.binanceFee,_that.omlapayFee,_that.totalFee,_that.available,_that.minFromAmount,_that.maxFromAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwapQuoteModel implements SwapQuoteModel {
  const _SwapQuoteModel({this.fromCoin = '', this.toCoin = '', this.fromAmount = '', this.fromAmountUsd = '', this.estimatedToAmount = '', this.estimatedToAmountUsd = '', this.exchangeRate = '', this.binanceFee = '', this.omlapayFee = '', this.totalFee = '', this.available = '', this.minFromAmount = '', this.maxFromAmount = ''});
  factory _SwapQuoteModel.fromJson(Map<String, dynamic> json) => _$SwapQuoteModelFromJson(json);

@override@JsonKey() final  String fromCoin;
@override@JsonKey() final  String toCoin;
@override@JsonKey() final  String fromAmount;
@override@JsonKey() final  String fromAmountUsd;
@override@JsonKey() final  String estimatedToAmount;
@override@JsonKey() final  String estimatedToAmountUsd;
@override@JsonKey() final  String exchangeRate;
@override@JsonKey() final  String binanceFee;
@override@JsonKey() final  String omlapayFee;
@override@JsonKey() final  String totalFee;
@override@JsonKey() final  String available;
@override@JsonKey() final  String minFromAmount;
@override@JsonKey() final  String maxFromAmount;

/// Create a copy of SwapQuoteModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwapQuoteModelCopyWith<_SwapQuoteModel> get copyWith => __$SwapQuoteModelCopyWithImpl<_SwapQuoteModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwapQuoteModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwapQuoteModel&&(identical(other.fromCoin, fromCoin) || other.fromCoin == fromCoin)&&(identical(other.toCoin, toCoin) || other.toCoin == toCoin)&&(identical(other.fromAmount, fromAmount) || other.fromAmount == fromAmount)&&(identical(other.fromAmountUsd, fromAmountUsd) || other.fromAmountUsd == fromAmountUsd)&&(identical(other.estimatedToAmount, estimatedToAmount) || other.estimatedToAmount == estimatedToAmount)&&(identical(other.estimatedToAmountUsd, estimatedToAmountUsd) || other.estimatedToAmountUsd == estimatedToAmountUsd)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.binanceFee, binanceFee) || other.binanceFee == binanceFee)&&(identical(other.omlapayFee, omlapayFee) || other.omlapayFee == omlapayFee)&&(identical(other.totalFee, totalFee) || other.totalFee == totalFee)&&(identical(other.available, available) || other.available == available)&&(identical(other.minFromAmount, minFromAmount) || other.minFromAmount == minFromAmount)&&(identical(other.maxFromAmount, maxFromAmount) || other.maxFromAmount == maxFromAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromCoin,toCoin,fromAmount,fromAmountUsd,estimatedToAmount,estimatedToAmountUsd,exchangeRate,binanceFee,omlapayFee,totalFee,available,minFromAmount,maxFromAmount);

@override
String toString() {
  return 'SwapQuoteModel(fromCoin: $fromCoin, toCoin: $toCoin, fromAmount: $fromAmount, fromAmountUsd: $fromAmountUsd, estimatedToAmount: $estimatedToAmount, estimatedToAmountUsd: $estimatedToAmountUsd, exchangeRate: $exchangeRate, binanceFee: $binanceFee, omlapayFee: $omlapayFee, totalFee: $totalFee, available: $available, minFromAmount: $minFromAmount, maxFromAmount: $maxFromAmount)';
}


}

/// @nodoc
abstract mixin class _$SwapQuoteModelCopyWith<$Res> implements $SwapQuoteModelCopyWith<$Res> {
  factory _$SwapQuoteModelCopyWith(_SwapQuoteModel value, $Res Function(_SwapQuoteModel) _then) = __$SwapQuoteModelCopyWithImpl;
@override @useResult
$Res call({
 String fromCoin, String toCoin, String fromAmount, String fromAmountUsd, String estimatedToAmount, String estimatedToAmountUsd, String exchangeRate, String binanceFee, String omlapayFee, String totalFee, String available, String minFromAmount, String maxFromAmount
});




}
/// @nodoc
class __$SwapQuoteModelCopyWithImpl<$Res>
    implements _$SwapQuoteModelCopyWith<$Res> {
  __$SwapQuoteModelCopyWithImpl(this._self, this._then);

  final _SwapQuoteModel _self;
  final $Res Function(_SwapQuoteModel) _then;

/// Create a copy of SwapQuoteModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromCoin = null,Object? toCoin = null,Object? fromAmount = null,Object? fromAmountUsd = null,Object? estimatedToAmount = null,Object? estimatedToAmountUsd = null,Object? exchangeRate = null,Object? binanceFee = null,Object? omlapayFee = null,Object? totalFee = null,Object? available = null,Object? minFromAmount = null,Object? maxFromAmount = null,}) {
  return _then(_SwapQuoteModel(
fromCoin: null == fromCoin ? _self.fromCoin : fromCoin // ignore: cast_nullable_to_non_nullable
as String,toCoin: null == toCoin ? _self.toCoin : toCoin // ignore: cast_nullable_to_non_nullable
as String,fromAmount: null == fromAmount ? _self.fromAmount : fromAmount // ignore: cast_nullable_to_non_nullable
as String,fromAmountUsd: null == fromAmountUsd ? _self.fromAmountUsd : fromAmountUsd // ignore: cast_nullable_to_non_nullable
as String,estimatedToAmount: null == estimatedToAmount ? _self.estimatedToAmount : estimatedToAmount // ignore: cast_nullable_to_non_nullable
as String,estimatedToAmountUsd: null == estimatedToAmountUsd ? _self.estimatedToAmountUsd : estimatedToAmountUsd // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as String,binanceFee: null == binanceFee ? _self.binanceFee : binanceFee // ignore: cast_nullable_to_non_nullable
as String,omlapayFee: null == omlapayFee ? _self.omlapayFee : omlapayFee // ignore: cast_nullable_to_non_nullable
as String,totalFee: null == totalFee ? _self.totalFee : totalFee // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as String,minFromAmount: null == minFromAmount ? _self.minFromAmount : minFromAmount // ignore: cast_nullable_to_non_nullable
as String,maxFromAmount: null == maxFromAmount ? _self.maxFromAmount : maxFromAmount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
