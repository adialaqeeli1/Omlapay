// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swap_quote_stream_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SwapQuoteStreamModel {

 String get fromCoin; String get toCoin; String get exchangeRate; String get inverseRate; String get youPay; String get youPayCoin; String get youReceive; String get youReceiveCoin; String get available; String get minFromAmount; String get maxFromAmount; SwapQuoteStreamFees? get fees; SwapQuoteStreamPay? get pay; SwapQuoteStreamReceive? get receive;
/// Create a copy of SwapQuoteStreamModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwapQuoteStreamModelCopyWith<SwapQuoteStreamModel> get copyWith => _$SwapQuoteStreamModelCopyWithImpl<SwapQuoteStreamModel>(this as SwapQuoteStreamModel, _$identity);

  /// Serializes this SwapQuoteStreamModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwapQuoteStreamModel&&(identical(other.fromCoin, fromCoin) || other.fromCoin == fromCoin)&&(identical(other.toCoin, toCoin) || other.toCoin == toCoin)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.inverseRate, inverseRate) || other.inverseRate == inverseRate)&&(identical(other.youPay, youPay) || other.youPay == youPay)&&(identical(other.youPayCoin, youPayCoin) || other.youPayCoin == youPayCoin)&&(identical(other.youReceive, youReceive) || other.youReceive == youReceive)&&(identical(other.youReceiveCoin, youReceiveCoin) || other.youReceiveCoin == youReceiveCoin)&&(identical(other.available, available) || other.available == available)&&(identical(other.minFromAmount, minFromAmount) || other.minFromAmount == minFromAmount)&&(identical(other.maxFromAmount, maxFromAmount) || other.maxFromAmount == maxFromAmount)&&(identical(other.fees, fees) || other.fees == fees)&&(identical(other.pay, pay) || other.pay == pay)&&(identical(other.receive, receive) || other.receive == receive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromCoin,toCoin,exchangeRate,inverseRate,youPay,youPayCoin,youReceive,youReceiveCoin,available,minFromAmount,maxFromAmount,fees,pay,receive);

@override
String toString() {
  return 'SwapQuoteStreamModel(fromCoin: $fromCoin, toCoin: $toCoin, exchangeRate: $exchangeRate, inverseRate: $inverseRate, youPay: $youPay, youPayCoin: $youPayCoin, youReceive: $youReceive, youReceiveCoin: $youReceiveCoin, available: $available, minFromAmount: $minFromAmount, maxFromAmount: $maxFromAmount, fees: $fees, pay: $pay, receive: $receive)';
}


}

/// @nodoc
abstract mixin class $SwapQuoteStreamModelCopyWith<$Res>  {
  factory $SwapQuoteStreamModelCopyWith(SwapQuoteStreamModel value, $Res Function(SwapQuoteStreamModel) _then) = _$SwapQuoteStreamModelCopyWithImpl;
@useResult
$Res call({
 String fromCoin, String toCoin, String exchangeRate, String inverseRate, String youPay, String youPayCoin, String youReceive, String youReceiveCoin, String available, String minFromAmount, String maxFromAmount, SwapQuoteStreamFees? fees, SwapQuoteStreamPay? pay, SwapQuoteStreamReceive? receive
});


$SwapQuoteStreamFeesCopyWith<$Res>? get fees;$SwapQuoteStreamPayCopyWith<$Res>? get pay;$SwapQuoteStreamReceiveCopyWith<$Res>? get receive;

}
/// @nodoc
class _$SwapQuoteStreamModelCopyWithImpl<$Res>
    implements $SwapQuoteStreamModelCopyWith<$Res> {
  _$SwapQuoteStreamModelCopyWithImpl(this._self, this._then);

  final SwapQuoteStreamModel _self;
  final $Res Function(SwapQuoteStreamModel) _then;

/// Create a copy of SwapQuoteStreamModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromCoin = null,Object? toCoin = null,Object? exchangeRate = null,Object? inverseRate = null,Object? youPay = null,Object? youPayCoin = null,Object? youReceive = null,Object? youReceiveCoin = null,Object? available = null,Object? minFromAmount = null,Object? maxFromAmount = null,Object? fees = freezed,Object? pay = freezed,Object? receive = freezed,}) {
  return _then(_self.copyWith(
fromCoin: null == fromCoin ? _self.fromCoin : fromCoin // ignore: cast_nullable_to_non_nullable
as String,toCoin: null == toCoin ? _self.toCoin : toCoin // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as String,inverseRate: null == inverseRate ? _self.inverseRate : inverseRate // ignore: cast_nullable_to_non_nullable
as String,youPay: null == youPay ? _self.youPay : youPay // ignore: cast_nullable_to_non_nullable
as String,youPayCoin: null == youPayCoin ? _self.youPayCoin : youPayCoin // ignore: cast_nullable_to_non_nullable
as String,youReceive: null == youReceive ? _self.youReceive : youReceive // ignore: cast_nullable_to_non_nullable
as String,youReceiveCoin: null == youReceiveCoin ? _self.youReceiveCoin : youReceiveCoin // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as String,minFromAmount: null == minFromAmount ? _self.minFromAmount : minFromAmount // ignore: cast_nullable_to_non_nullable
as String,maxFromAmount: null == maxFromAmount ? _self.maxFromAmount : maxFromAmount // ignore: cast_nullable_to_non_nullable
as String,fees: freezed == fees ? _self.fees : fees // ignore: cast_nullable_to_non_nullable
as SwapQuoteStreamFees?,pay: freezed == pay ? _self.pay : pay // ignore: cast_nullable_to_non_nullable
as SwapQuoteStreamPay?,receive: freezed == receive ? _self.receive : receive // ignore: cast_nullable_to_non_nullable
as SwapQuoteStreamReceive?,
  ));
}
/// Create a copy of SwapQuoteStreamModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapQuoteStreamFeesCopyWith<$Res>? get fees {
    if (_self.fees == null) {
    return null;
  }

  return $SwapQuoteStreamFeesCopyWith<$Res>(_self.fees!, (value) {
    return _then(_self.copyWith(fees: value));
  });
}/// Create a copy of SwapQuoteStreamModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapQuoteStreamPayCopyWith<$Res>? get pay {
    if (_self.pay == null) {
    return null;
  }

  return $SwapQuoteStreamPayCopyWith<$Res>(_self.pay!, (value) {
    return _then(_self.copyWith(pay: value));
  });
}/// Create a copy of SwapQuoteStreamModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapQuoteStreamReceiveCopyWith<$Res>? get receive {
    if (_self.receive == null) {
    return null;
  }

  return $SwapQuoteStreamReceiveCopyWith<$Res>(_self.receive!, (value) {
    return _then(_self.copyWith(receive: value));
  });
}
}


/// Adds pattern-matching-related methods to [SwapQuoteStreamModel].
extension SwapQuoteStreamModelPatterns on SwapQuoteStreamModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwapQuoteStreamModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwapQuoteStreamModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwapQuoteStreamModel value)  $default,){
final _that = this;
switch (_that) {
case _SwapQuoteStreamModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwapQuoteStreamModel value)?  $default,){
final _that = this;
switch (_that) {
case _SwapQuoteStreamModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fromCoin,  String toCoin,  String exchangeRate,  String inverseRate,  String youPay,  String youPayCoin,  String youReceive,  String youReceiveCoin,  String available,  String minFromAmount,  String maxFromAmount,  SwapQuoteStreamFees? fees,  SwapQuoteStreamPay? pay,  SwapQuoteStreamReceive? receive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwapQuoteStreamModel() when $default != null:
return $default(_that.fromCoin,_that.toCoin,_that.exchangeRate,_that.inverseRate,_that.youPay,_that.youPayCoin,_that.youReceive,_that.youReceiveCoin,_that.available,_that.minFromAmount,_that.maxFromAmount,_that.fees,_that.pay,_that.receive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fromCoin,  String toCoin,  String exchangeRate,  String inverseRate,  String youPay,  String youPayCoin,  String youReceive,  String youReceiveCoin,  String available,  String minFromAmount,  String maxFromAmount,  SwapQuoteStreamFees? fees,  SwapQuoteStreamPay? pay,  SwapQuoteStreamReceive? receive)  $default,) {final _that = this;
switch (_that) {
case _SwapQuoteStreamModel():
return $default(_that.fromCoin,_that.toCoin,_that.exchangeRate,_that.inverseRate,_that.youPay,_that.youPayCoin,_that.youReceive,_that.youReceiveCoin,_that.available,_that.minFromAmount,_that.maxFromAmount,_that.fees,_that.pay,_that.receive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fromCoin,  String toCoin,  String exchangeRate,  String inverseRate,  String youPay,  String youPayCoin,  String youReceive,  String youReceiveCoin,  String available,  String minFromAmount,  String maxFromAmount,  SwapQuoteStreamFees? fees,  SwapQuoteStreamPay? pay,  SwapQuoteStreamReceive? receive)?  $default,) {final _that = this;
switch (_that) {
case _SwapQuoteStreamModel() when $default != null:
return $default(_that.fromCoin,_that.toCoin,_that.exchangeRate,_that.inverseRate,_that.youPay,_that.youPayCoin,_that.youReceive,_that.youReceiveCoin,_that.available,_that.minFromAmount,_that.maxFromAmount,_that.fees,_that.pay,_that.receive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwapQuoteStreamModel implements SwapQuoteStreamModel {
  const _SwapQuoteStreamModel({this.fromCoin = '', this.toCoin = '', this.exchangeRate = '', this.inverseRate = '', this.youPay = '', this.youPayCoin = '', this.youReceive = '', this.youReceiveCoin = '', this.available = '', this.minFromAmount = '', this.maxFromAmount = '', this.fees, this.pay, this.receive});
  factory _SwapQuoteStreamModel.fromJson(Map<String, dynamic> json) => _$SwapQuoteStreamModelFromJson(json);

@override@JsonKey() final  String fromCoin;
@override@JsonKey() final  String toCoin;
@override@JsonKey() final  String exchangeRate;
@override@JsonKey() final  String inverseRate;
@override@JsonKey() final  String youPay;
@override@JsonKey() final  String youPayCoin;
@override@JsonKey() final  String youReceive;
@override@JsonKey() final  String youReceiveCoin;
@override@JsonKey() final  String available;
@override@JsonKey() final  String minFromAmount;
@override@JsonKey() final  String maxFromAmount;
@override final  SwapQuoteStreamFees? fees;
@override final  SwapQuoteStreamPay? pay;
@override final  SwapQuoteStreamReceive? receive;

/// Create a copy of SwapQuoteStreamModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwapQuoteStreamModelCopyWith<_SwapQuoteStreamModel> get copyWith => __$SwapQuoteStreamModelCopyWithImpl<_SwapQuoteStreamModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwapQuoteStreamModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwapQuoteStreamModel&&(identical(other.fromCoin, fromCoin) || other.fromCoin == fromCoin)&&(identical(other.toCoin, toCoin) || other.toCoin == toCoin)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.inverseRate, inverseRate) || other.inverseRate == inverseRate)&&(identical(other.youPay, youPay) || other.youPay == youPay)&&(identical(other.youPayCoin, youPayCoin) || other.youPayCoin == youPayCoin)&&(identical(other.youReceive, youReceive) || other.youReceive == youReceive)&&(identical(other.youReceiveCoin, youReceiveCoin) || other.youReceiveCoin == youReceiveCoin)&&(identical(other.available, available) || other.available == available)&&(identical(other.minFromAmount, minFromAmount) || other.minFromAmount == minFromAmount)&&(identical(other.maxFromAmount, maxFromAmount) || other.maxFromAmount == maxFromAmount)&&(identical(other.fees, fees) || other.fees == fees)&&(identical(other.pay, pay) || other.pay == pay)&&(identical(other.receive, receive) || other.receive == receive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromCoin,toCoin,exchangeRate,inverseRate,youPay,youPayCoin,youReceive,youReceiveCoin,available,minFromAmount,maxFromAmount,fees,pay,receive);

@override
String toString() {
  return 'SwapQuoteStreamModel(fromCoin: $fromCoin, toCoin: $toCoin, exchangeRate: $exchangeRate, inverseRate: $inverseRate, youPay: $youPay, youPayCoin: $youPayCoin, youReceive: $youReceive, youReceiveCoin: $youReceiveCoin, available: $available, minFromAmount: $minFromAmount, maxFromAmount: $maxFromAmount, fees: $fees, pay: $pay, receive: $receive)';
}


}

/// @nodoc
abstract mixin class _$SwapQuoteStreamModelCopyWith<$Res> implements $SwapQuoteStreamModelCopyWith<$Res> {
  factory _$SwapQuoteStreamModelCopyWith(_SwapQuoteStreamModel value, $Res Function(_SwapQuoteStreamModel) _then) = __$SwapQuoteStreamModelCopyWithImpl;
@override @useResult
$Res call({
 String fromCoin, String toCoin, String exchangeRate, String inverseRate, String youPay, String youPayCoin, String youReceive, String youReceiveCoin, String available, String minFromAmount, String maxFromAmount, SwapQuoteStreamFees? fees, SwapQuoteStreamPay? pay, SwapQuoteStreamReceive? receive
});


@override $SwapQuoteStreamFeesCopyWith<$Res>? get fees;@override $SwapQuoteStreamPayCopyWith<$Res>? get pay;@override $SwapQuoteStreamReceiveCopyWith<$Res>? get receive;

}
/// @nodoc
class __$SwapQuoteStreamModelCopyWithImpl<$Res>
    implements _$SwapQuoteStreamModelCopyWith<$Res> {
  __$SwapQuoteStreamModelCopyWithImpl(this._self, this._then);

  final _SwapQuoteStreamModel _self;
  final $Res Function(_SwapQuoteStreamModel) _then;

/// Create a copy of SwapQuoteStreamModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromCoin = null,Object? toCoin = null,Object? exchangeRate = null,Object? inverseRate = null,Object? youPay = null,Object? youPayCoin = null,Object? youReceive = null,Object? youReceiveCoin = null,Object? available = null,Object? minFromAmount = null,Object? maxFromAmount = null,Object? fees = freezed,Object? pay = freezed,Object? receive = freezed,}) {
  return _then(_SwapQuoteStreamModel(
fromCoin: null == fromCoin ? _self.fromCoin : fromCoin // ignore: cast_nullable_to_non_nullable
as String,toCoin: null == toCoin ? _self.toCoin : toCoin // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as String,inverseRate: null == inverseRate ? _self.inverseRate : inverseRate // ignore: cast_nullable_to_non_nullable
as String,youPay: null == youPay ? _self.youPay : youPay // ignore: cast_nullable_to_non_nullable
as String,youPayCoin: null == youPayCoin ? _self.youPayCoin : youPayCoin // ignore: cast_nullable_to_non_nullable
as String,youReceive: null == youReceive ? _self.youReceive : youReceive // ignore: cast_nullable_to_non_nullable
as String,youReceiveCoin: null == youReceiveCoin ? _self.youReceiveCoin : youReceiveCoin // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as String,minFromAmount: null == minFromAmount ? _self.minFromAmount : minFromAmount // ignore: cast_nullable_to_non_nullable
as String,maxFromAmount: null == maxFromAmount ? _self.maxFromAmount : maxFromAmount // ignore: cast_nullable_to_non_nullable
as String,fees: freezed == fees ? _self.fees : fees // ignore: cast_nullable_to_non_nullable
as SwapQuoteStreamFees?,pay: freezed == pay ? _self.pay : pay // ignore: cast_nullable_to_non_nullable
as SwapQuoteStreamPay?,receive: freezed == receive ? _self.receive : receive // ignore: cast_nullable_to_non_nullable
as SwapQuoteStreamReceive?,
  ));
}

/// Create a copy of SwapQuoteStreamModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapQuoteStreamFeesCopyWith<$Res>? get fees {
    if (_self.fees == null) {
    return null;
  }

  return $SwapQuoteStreamFeesCopyWith<$Res>(_self.fees!, (value) {
    return _then(_self.copyWith(fees: value));
  });
}/// Create a copy of SwapQuoteStreamModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapQuoteStreamPayCopyWith<$Res>? get pay {
    if (_self.pay == null) {
    return null;
  }

  return $SwapQuoteStreamPayCopyWith<$Res>(_self.pay!, (value) {
    return _then(_self.copyWith(pay: value));
  });
}/// Create a copy of SwapQuoteStreamModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapQuoteStreamReceiveCopyWith<$Res>? get receive {
    if (_self.receive == null) {
    return null;
  }

  return $SwapQuoteStreamReceiveCopyWith<$Res>(_self.receive!, (value) {
    return _then(_self.copyWith(receive: value));
  });
}
}


/// @nodoc
mixin _$SwapQuoteStreamFees {

 SwapQuoteFeeEntry? get omlapay; SwapQuoteFeeEntry? get binance; SwapQuoteFeeEntry? get total;
/// Create a copy of SwapQuoteStreamFees
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwapQuoteStreamFeesCopyWith<SwapQuoteStreamFees> get copyWith => _$SwapQuoteStreamFeesCopyWithImpl<SwapQuoteStreamFees>(this as SwapQuoteStreamFees, _$identity);

  /// Serializes this SwapQuoteStreamFees to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwapQuoteStreamFees&&(identical(other.omlapay, omlapay) || other.omlapay == omlapay)&&(identical(other.binance, binance) || other.binance == binance)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,omlapay,binance,total);

@override
String toString() {
  return 'SwapQuoteStreamFees(omlapay: $omlapay, binance: $binance, total: $total)';
}


}

/// @nodoc
abstract mixin class $SwapQuoteStreamFeesCopyWith<$Res>  {
  factory $SwapQuoteStreamFeesCopyWith(SwapQuoteStreamFees value, $Res Function(SwapQuoteStreamFees) _then) = _$SwapQuoteStreamFeesCopyWithImpl;
@useResult
$Res call({
 SwapQuoteFeeEntry? omlapay, SwapQuoteFeeEntry? binance, SwapQuoteFeeEntry? total
});


$SwapQuoteFeeEntryCopyWith<$Res>? get omlapay;$SwapQuoteFeeEntryCopyWith<$Res>? get binance;$SwapQuoteFeeEntryCopyWith<$Res>? get total;

}
/// @nodoc
class _$SwapQuoteStreamFeesCopyWithImpl<$Res>
    implements $SwapQuoteStreamFeesCopyWith<$Res> {
  _$SwapQuoteStreamFeesCopyWithImpl(this._self, this._then);

  final SwapQuoteStreamFees _self;
  final $Res Function(SwapQuoteStreamFees) _then;

/// Create a copy of SwapQuoteStreamFees
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? omlapay = freezed,Object? binance = freezed,Object? total = freezed,}) {
  return _then(_self.copyWith(
omlapay: freezed == omlapay ? _self.omlapay : omlapay // ignore: cast_nullable_to_non_nullable
as SwapQuoteFeeEntry?,binance: freezed == binance ? _self.binance : binance // ignore: cast_nullable_to_non_nullable
as SwapQuoteFeeEntry?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as SwapQuoteFeeEntry?,
  ));
}
/// Create a copy of SwapQuoteStreamFees
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapQuoteFeeEntryCopyWith<$Res>? get omlapay {
    if (_self.omlapay == null) {
    return null;
  }

  return $SwapQuoteFeeEntryCopyWith<$Res>(_self.omlapay!, (value) {
    return _then(_self.copyWith(omlapay: value));
  });
}/// Create a copy of SwapQuoteStreamFees
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapQuoteFeeEntryCopyWith<$Res>? get binance {
    if (_self.binance == null) {
    return null;
  }

  return $SwapQuoteFeeEntryCopyWith<$Res>(_self.binance!, (value) {
    return _then(_self.copyWith(binance: value));
  });
}/// Create a copy of SwapQuoteStreamFees
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapQuoteFeeEntryCopyWith<$Res>? get total {
    if (_self.total == null) {
    return null;
  }

  return $SwapQuoteFeeEntryCopyWith<$Res>(_self.total!, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}


/// Adds pattern-matching-related methods to [SwapQuoteStreamFees].
extension SwapQuoteStreamFeesPatterns on SwapQuoteStreamFees {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwapQuoteStreamFees value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwapQuoteStreamFees() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwapQuoteStreamFees value)  $default,){
final _that = this;
switch (_that) {
case _SwapQuoteStreamFees():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwapQuoteStreamFees value)?  $default,){
final _that = this;
switch (_that) {
case _SwapQuoteStreamFees() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SwapQuoteFeeEntry? omlapay,  SwapQuoteFeeEntry? binance,  SwapQuoteFeeEntry? total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwapQuoteStreamFees() when $default != null:
return $default(_that.omlapay,_that.binance,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SwapQuoteFeeEntry? omlapay,  SwapQuoteFeeEntry? binance,  SwapQuoteFeeEntry? total)  $default,) {final _that = this;
switch (_that) {
case _SwapQuoteStreamFees():
return $default(_that.omlapay,_that.binance,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SwapQuoteFeeEntry? omlapay,  SwapQuoteFeeEntry? binance,  SwapQuoteFeeEntry? total)?  $default,) {final _that = this;
switch (_that) {
case _SwapQuoteStreamFees() when $default != null:
return $default(_that.omlapay,_that.binance,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwapQuoteStreamFees implements SwapQuoteStreamFees {
  const _SwapQuoteStreamFees({this.omlapay, this.binance, this.total});
  factory _SwapQuoteStreamFees.fromJson(Map<String, dynamic> json) => _$SwapQuoteStreamFeesFromJson(json);

@override final  SwapQuoteFeeEntry? omlapay;
@override final  SwapQuoteFeeEntry? binance;
@override final  SwapQuoteFeeEntry? total;

/// Create a copy of SwapQuoteStreamFees
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwapQuoteStreamFeesCopyWith<_SwapQuoteStreamFees> get copyWith => __$SwapQuoteStreamFeesCopyWithImpl<_SwapQuoteStreamFees>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwapQuoteStreamFeesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwapQuoteStreamFees&&(identical(other.omlapay, omlapay) || other.omlapay == omlapay)&&(identical(other.binance, binance) || other.binance == binance)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,omlapay,binance,total);

@override
String toString() {
  return 'SwapQuoteStreamFees(omlapay: $omlapay, binance: $binance, total: $total)';
}


}

/// @nodoc
abstract mixin class _$SwapQuoteStreamFeesCopyWith<$Res> implements $SwapQuoteStreamFeesCopyWith<$Res> {
  factory _$SwapQuoteStreamFeesCopyWith(_SwapQuoteStreamFees value, $Res Function(_SwapQuoteStreamFees) _then) = __$SwapQuoteStreamFeesCopyWithImpl;
@override @useResult
$Res call({
 SwapQuoteFeeEntry? omlapay, SwapQuoteFeeEntry? binance, SwapQuoteFeeEntry? total
});


@override $SwapQuoteFeeEntryCopyWith<$Res>? get omlapay;@override $SwapQuoteFeeEntryCopyWith<$Res>? get binance;@override $SwapQuoteFeeEntryCopyWith<$Res>? get total;

}
/// @nodoc
class __$SwapQuoteStreamFeesCopyWithImpl<$Res>
    implements _$SwapQuoteStreamFeesCopyWith<$Res> {
  __$SwapQuoteStreamFeesCopyWithImpl(this._self, this._then);

  final _SwapQuoteStreamFees _self;
  final $Res Function(_SwapQuoteStreamFees) _then;

/// Create a copy of SwapQuoteStreamFees
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? omlapay = freezed,Object? binance = freezed,Object? total = freezed,}) {
  return _then(_SwapQuoteStreamFees(
omlapay: freezed == omlapay ? _self.omlapay : omlapay // ignore: cast_nullable_to_non_nullable
as SwapQuoteFeeEntry?,binance: freezed == binance ? _self.binance : binance // ignore: cast_nullable_to_non_nullable
as SwapQuoteFeeEntry?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as SwapQuoteFeeEntry?,
  ));
}

/// Create a copy of SwapQuoteStreamFees
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapQuoteFeeEntryCopyWith<$Res>? get omlapay {
    if (_self.omlapay == null) {
    return null;
  }

  return $SwapQuoteFeeEntryCopyWith<$Res>(_self.omlapay!, (value) {
    return _then(_self.copyWith(omlapay: value));
  });
}/// Create a copy of SwapQuoteStreamFees
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapQuoteFeeEntryCopyWith<$Res>? get binance {
    if (_self.binance == null) {
    return null;
  }

  return $SwapQuoteFeeEntryCopyWith<$Res>(_self.binance!, (value) {
    return _then(_self.copyWith(binance: value));
  });
}/// Create a copy of SwapQuoteStreamFees
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapQuoteFeeEntryCopyWith<$Res>? get total {
    if (_self.total == null) {
    return null;
  }

  return $SwapQuoteFeeEntryCopyWith<$Res>(_self.total!, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}


/// @nodoc
mixin _$SwapQuoteFeeEntry {

 String get percent; String get fromCoinAmount; String get toCoinAmount; String get usd;
/// Create a copy of SwapQuoteFeeEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwapQuoteFeeEntryCopyWith<SwapQuoteFeeEntry> get copyWith => _$SwapQuoteFeeEntryCopyWithImpl<SwapQuoteFeeEntry>(this as SwapQuoteFeeEntry, _$identity);

  /// Serializes this SwapQuoteFeeEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwapQuoteFeeEntry&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.fromCoinAmount, fromCoinAmount) || other.fromCoinAmount == fromCoinAmount)&&(identical(other.toCoinAmount, toCoinAmount) || other.toCoinAmount == toCoinAmount)&&(identical(other.usd, usd) || other.usd == usd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,percent,fromCoinAmount,toCoinAmount,usd);

@override
String toString() {
  return 'SwapQuoteFeeEntry(percent: $percent, fromCoinAmount: $fromCoinAmount, toCoinAmount: $toCoinAmount, usd: $usd)';
}


}

/// @nodoc
abstract mixin class $SwapQuoteFeeEntryCopyWith<$Res>  {
  factory $SwapQuoteFeeEntryCopyWith(SwapQuoteFeeEntry value, $Res Function(SwapQuoteFeeEntry) _then) = _$SwapQuoteFeeEntryCopyWithImpl;
@useResult
$Res call({
 String percent, String fromCoinAmount, String toCoinAmount, String usd
});




}
/// @nodoc
class _$SwapQuoteFeeEntryCopyWithImpl<$Res>
    implements $SwapQuoteFeeEntryCopyWith<$Res> {
  _$SwapQuoteFeeEntryCopyWithImpl(this._self, this._then);

  final SwapQuoteFeeEntry _self;
  final $Res Function(SwapQuoteFeeEntry) _then;

/// Create a copy of SwapQuoteFeeEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? percent = null,Object? fromCoinAmount = null,Object? toCoinAmount = null,Object? usd = null,}) {
  return _then(_self.copyWith(
percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as String,fromCoinAmount: null == fromCoinAmount ? _self.fromCoinAmount : fromCoinAmount // ignore: cast_nullable_to_non_nullable
as String,toCoinAmount: null == toCoinAmount ? _self.toCoinAmount : toCoinAmount // ignore: cast_nullable_to_non_nullable
as String,usd: null == usd ? _self.usd : usd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SwapQuoteFeeEntry].
extension SwapQuoteFeeEntryPatterns on SwapQuoteFeeEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwapQuoteFeeEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwapQuoteFeeEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwapQuoteFeeEntry value)  $default,){
final _that = this;
switch (_that) {
case _SwapQuoteFeeEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwapQuoteFeeEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SwapQuoteFeeEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String percent,  String fromCoinAmount,  String toCoinAmount,  String usd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwapQuoteFeeEntry() when $default != null:
return $default(_that.percent,_that.fromCoinAmount,_that.toCoinAmount,_that.usd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String percent,  String fromCoinAmount,  String toCoinAmount,  String usd)  $default,) {final _that = this;
switch (_that) {
case _SwapQuoteFeeEntry():
return $default(_that.percent,_that.fromCoinAmount,_that.toCoinAmount,_that.usd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String percent,  String fromCoinAmount,  String toCoinAmount,  String usd)?  $default,) {final _that = this;
switch (_that) {
case _SwapQuoteFeeEntry() when $default != null:
return $default(_that.percent,_that.fromCoinAmount,_that.toCoinAmount,_that.usd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwapQuoteFeeEntry implements SwapQuoteFeeEntry {
  const _SwapQuoteFeeEntry({this.percent = '', this.fromCoinAmount = '', this.toCoinAmount = '', this.usd = ''});
  factory _SwapQuoteFeeEntry.fromJson(Map<String, dynamic> json) => _$SwapQuoteFeeEntryFromJson(json);

@override@JsonKey() final  String percent;
@override@JsonKey() final  String fromCoinAmount;
@override@JsonKey() final  String toCoinAmount;
@override@JsonKey() final  String usd;

/// Create a copy of SwapQuoteFeeEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwapQuoteFeeEntryCopyWith<_SwapQuoteFeeEntry> get copyWith => __$SwapQuoteFeeEntryCopyWithImpl<_SwapQuoteFeeEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwapQuoteFeeEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwapQuoteFeeEntry&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.fromCoinAmount, fromCoinAmount) || other.fromCoinAmount == fromCoinAmount)&&(identical(other.toCoinAmount, toCoinAmount) || other.toCoinAmount == toCoinAmount)&&(identical(other.usd, usd) || other.usd == usd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,percent,fromCoinAmount,toCoinAmount,usd);

@override
String toString() {
  return 'SwapQuoteFeeEntry(percent: $percent, fromCoinAmount: $fromCoinAmount, toCoinAmount: $toCoinAmount, usd: $usd)';
}


}

/// @nodoc
abstract mixin class _$SwapQuoteFeeEntryCopyWith<$Res> implements $SwapQuoteFeeEntryCopyWith<$Res> {
  factory _$SwapQuoteFeeEntryCopyWith(_SwapQuoteFeeEntry value, $Res Function(_SwapQuoteFeeEntry) _then) = __$SwapQuoteFeeEntryCopyWithImpl;
@override @useResult
$Res call({
 String percent, String fromCoinAmount, String toCoinAmount, String usd
});




}
/// @nodoc
class __$SwapQuoteFeeEntryCopyWithImpl<$Res>
    implements _$SwapQuoteFeeEntryCopyWith<$Res> {
  __$SwapQuoteFeeEntryCopyWithImpl(this._self, this._then);

  final _SwapQuoteFeeEntry _self;
  final $Res Function(_SwapQuoteFeeEntry) _then;

/// Create a copy of SwapQuoteFeeEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? percent = null,Object? fromCoinAmount = null,Object? toCoinAmount = null,Object? usd = null,}) {
  return _then(_SwapQuoteFeeEntry(
percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as String,fromCoinAmount: null == fromCoinAmount ? _self.fromCoinAmount : fromCoinAmount // ignore: cast_nullable_to_non_nullable
as String,toCoinAmount: null == toCoinAmount ? _self.toCoinAmount : toCoinAmount // ignore: cast_nullable_to_non_nullable
as String,usd: null == usd ? _self.usd : usd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SwapQuoteStreamPay {

 String get coin; String get amount; String get amountUsd;
/// Create a copy of SwapQuoteStreamPay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwapQuoteStreamPayCopyWith<SwapQuoteStreamPay> get copyWith => _$SwapQuoteStreamPayCopyWithImpl<SwapQuoteStreamPay>(this as SwapQuoteStreamPay, _$identity);

  /// Serializes this SwapQuoteStreamPay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwapQuoteStreamPay&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountUsd, amountUsd) || other.amountUsd == amountUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coin,amount,amountUsd);

@override
String toString() {
  return 'SwapQuoteStreamPay(coin: $coin, amount: $amount, amountUsd: $amountUsd)';
}


}

/// @nodoc
abstract mixin class $SwapQuoteStreamPayCopyWith<$Res>  {
  factory $SwapQuoteStreamPayCopyWith(SwapQuoteStreamPay value, $Res Function(SwapQuoteStreamPay) _then) = _$SwapQuoteStreamPayCopyWithImpl;
@useResult
$Res call({
 String coin, String amount, String amountUsd
});




}
/// @nodoc
class _$SwapQuoteStreamPayCopyWithImpl<$Res>
    implements $SwapQuoteStreamPayCopyWith<$Res> {
  _$SwapQuoteStreamPayCopyWithImpl(this._self, this._then);

  final SwapQuoteStreamPay _self;
  final $Res Function(SwapQuoteStreamPay) _then;

/// Create a copy of SwapQuoteStreamPay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coin = null,Object? amount = null,Object? amountUsd = null,}) {
  return _then(_self.copyWith(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,amountUsd: null == amountUsd ? _self.amountUsd : amountUsd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SwapQuoteStreamPay].
extension SwapQuoteStreamPayPatterns on SwapQuoteStreamPay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwapQuoteStreamPay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwapQuoteStreamPay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwapQuoteStreamPay value)  $default,){
final _that = this;
switch (_that) {
case _SwapQuoteStreamPay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwapQuoteStreamPay value)?  $default,){
final _that = this;
switch (_that) {
case _SwapQuoteStreamPay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String coin,  String amount,  String amountUsd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwapQuoteStreamPay() when $default != null:
return $default(_that.coin,_that.amount,_that.amountUsd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String coin,  String amount,  String amountUsd)  $default,) {final _that = this;
switch (_that) {
case _SwapQuoteStreamPay():
return $default(_that.coin,_that.amount,_that.amountUsd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String coin,  String amount,  String amountUsd)?  $default,) {final _that = this;
switch (_that) {
case _SwapQuoteStreamPay() when $default != null:
return $default(_that.coin,_that.amount,_that.amountUsd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwapQuoteStreamPay implements SwapQuoteStreamPay {
  const _SwapQuoteStreamPay({this.coin = '', this.amount = '', this.amountUsd = ''});
  factory _SwapQuoteStreamPay.fromJson(Map<String, dynamic> json) => _$SwapQuoteStreamPayFromJson(json);

@override@JsonKey() final  String coin;
@override@JsonKey() final  String amount;
@override@JsonKey() final  String amountUsd;

/// Create a copy of SwapQuoteStreamPay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwapQuoteStreamPayCopyWith<_SwapQuoteStreamPay> get copyWith => __$SwapQuoteStreamPayCopyWithImpl<_SwapQuoteStreamPay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwapQuoteStreamPayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwapQuoteStreamPay&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountUsd, amountUsd) || other.amountUsd == amountUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coin,amount,amountUsd);

@override
String toString() {
  return 'SwapQuoteStreamPay(coin: $coin, amount: $amount, amountUsd: $amountUsd)';
}


}

/// @nodoc
abstract mixin class _$SwapQuoteStreamPayCopyWith<$Res> implements $SwapQuoteStreamPayCopyWith<$Res> {
  factory _$SwapQuoteStreamPayCopyWith(_SwapQuoteStreamPay value, $Res Function(_SwapQuoteStreamPay) _then) = __$SwapQuoteStreamPayCopyWithImpl;
@override @useResult
$Res call({
 String coin, String amount, String amountUsd
});




}
/// @nodoc
class __$SwapQuoteStreamPayCopyWithImpl<$Res>
    implements _$SwapQuoteStreamPayCopyWith<$Res> {
  __$SwapQuoteStreamPayCopyWithImpl(this._self, this._then);

  final _SwapQuoteStreamPay _self;
  final $Res Function(_SwapQuoteStreamPay) _then;

/// Create a copy of SwapQuoteStreamPay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coin = null,Object? amount = null,Object? amountUsd = null,}) {
  return _then(_SwapQuoteStreamPay(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,amountUsd: null == amountUsd ? _self.amountUsd : amountUsd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SwapQuoteStreamReceive {

 String get coin; String get grossAmount; String get grossAmountUsd; String get netAmount; String get netAmountUsd;
/// Create a copy of SwapQuoteStreamReceive
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwapQuoteStreamReceiveCopyWith<SwapQuoteStreamReceive> get copyWith => _$SwapQuoteStreamReceiveCopyWithImpl<SwapQuoteStreamReceive>(this as SwapQuoteStreamReceive, _$identity);

  /// Serializes this SwapQuoteStreamReceive to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwapQuoteStreamReceive&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.grossAmount, grossAmount) || other.grossAmount == grossAmount)&&(identical(other.grossAmountUsd, grossAmountUsd) || other.grossAmountUsd == grossAmountUsd)&&(identical(other.netAmount, netAmount) || other.netAmount == netAmount)&&(identical(other.netAmountUsd, netAmountUsd) || other.netAmountUsd == netAmountUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coin,grossAmount,grossAmountUsd,netAmount,netAmountUsd);

@override
String toString() {
  return 'SwapQuoteStreamReceive(coin: $coin, grossAmount: $grossAmount, grossAmountUsd: $grossAmountUsd, netAmount: $netAmount, netAmountUsd: $netAmountUsd)';
}


}

/// @nodoc
abstract mixin class $SwapQuoteStreamReceiveCopyWith<$Res>  {
  factory $SwapQuoteStreamReceiveCopyWith(SwapQuoteStreamReceive value, $Res Function(SwapQuoteStreamReceive) _then) = _$SwapQuoteStreamReceiveCopyWithImpl;
@useResult
$Res call({
 String coin, String grossAmount, String grossAmountUsd, String netAmount, String netAmountUsd
});




}
/// @nodoc
class _$SwapQuoteStreamReceiveCopyWithImpl<$Res>
    implements $SwapQuoteStreamReceiveCopyWith<$Res> {
  _$SwapQuoteStreamReceiveCopyWithImpl(this._self, this._then);

  final SwapQuoteStreamReceive _self;
  final $Res Function(SwapQuoteStreamReceive) _then;

/// Create a copy of SwapQuoteStreamReceive
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coin = null,Object? grossAmount = null,Object? grossAmountUsd = null,Object? netAmount = null,Object? netAmountUsd = null,}) {
  return _then(_self.copyWith(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,grossAmount: null == grossAmount ? _self.grossAmount : grossAmount // ignore: cast_nullable_to_non_nullable
as String,grossAmountUsd: null == grossAmountUsd ? _self.grossAmountUsd : grossAmountUsd // ignore: cast_nullable_to_non_nullable
as String,netAmount: null == netAmount ? _self.netAmount : netAmount // ignore: cast_nullable_to_non_nullable
as String,netAmountUsd: null == netAmountUsd ? _self.netAmountUsd : netAmountUsd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SwapQuoteStreamReceive].
extension SwapQuoteStreamReceivePatterns on SwapQuoteStreamReceive {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwapQuoteStreamReceive value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwapQuoteStreamReceive() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwapQuoteStreamReceive value)  $default,){
final _that = this;
switch (_that) {
case _SwapQuoteStreamReceive():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwapQuoteStreamReceive value)?  $default,){
final _that = this;
switch (_that) {
case _SwapQuoteStreamReceive() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String coin,  String grossAmount,  String grossAmountUsd,  String netAmount,  String netAmountUsd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwapQuoteStreamReceive() when $default != null:
return $default(_that.coin,_that.grossAmount,_that.grossAmountUsd,_that.netAmount,_that.netAmountUsd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String coin,  String grossAmount,  String grossAmountUsd,  String netAmount,  String netAmountUsd)  $default,) {final _that = this;
switch (_that) {
case _SwapQuoteStreamReceive():
return $default(_that.coin,_that.grossAmount,_that.grossAmountUsd,_that.netAmount,_that.netAmountUsd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String coin,  String grossAmount,  String grossAmountUsd,  String netAmount,  String netAmountUsd)?  $default,) {final _that = this;
switch (_that) {
case _SwapQuoteStreamReceive() when $default != null:
return $default(_that.coin,_that.grossAmount,_that.grossAmountUsd,_that.netAmount,_that.netAmountUsd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwapQuoteStreamReceive implements SwapQuoteStreamReceive {
  const _SwapQuoteStreamReceive({this.coin = '', this.grossAmount = '', this.grossAmountUsd = '', this.netAmount = '', this.netAmountUsd = ''});
  factory _SwapQuoteStreamReceive.fromJson(Map<String, dynamic> json) => _$SwapQuoteStreamReceiveFromJson(json);

@override@JsonKey() final  String coin;
@override@JsonKey() final  String grossAmount;
@override@JsonKey() final  String grossAmountUsd;
@override@JsonKey() final  String netAmount;
@override@JsonKey() final  String netAmountUsd;

/// Create a copy of SwapQuoteStreamReceive
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwapQuoteStreamReceiveCopyWith<_SwapQuoteStreamReceive> get copyWith => __$SwapQuoteStreamReceiveCopyWithImpl<_SwapQuoteStreamReceive>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwapQuoteStreamReceiveToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwapQuoteStreamReceive&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.grossAmount, grossAmount) || other.grossAmount == grossAmount)&&(identical(other.grossAmountUsd, grossAmountUsd) || other.grossAmountUsd == grossAmountUsd)&&(identical(other.netAmount, netAmount) || other.netAmount == netAmount)&&(identical(other.netAmountUsd, netAmountUsd) || other.netAmountUsd == netAmountUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coin,grossAmount,grossAmountUsd,netAmount,netAmountUsd);

@override
String toString() {
  return 'SwapQuoteStreamReceive(coin: $coin, grossAmount: $grossAmount, grossAmountUsd: $grossAmountUsd, netAmount: $netAmount, netAmountUsd: $netAmountUsd)';
}


}

/// @nodoc
abstract mixin class _$SwapQuoteStreamReceiveCopyWith<$Res> implements $SwapQuoteStreamReceiveCopyWith<$Res> {
  factory _$SwapQuoteStreamReceiveCopyWith(_SwapQuoteStreamReceive value, $Res Function(_SwapQuoteStreamReceive) _then) = __$SwapQuoteStreamReceiveCopyWithImpl;
@override @useResult
$Res call({
 String coin, String grossAmount, String grossAmountUsd, String netAmount, String netAmountUsd
});




}
/// @nodoc
class __$SwapQuoteStreamReceiveCopyWithImpl<$Res>
    implements _$SwapQuoteStreamReceiveCopyWith<$Res> {
  __$SwapQuoteStreamReceiveCopyWithImpl(this._self, this._then);

  final _SwapQuoteStreamReceive _self;
  final $Res Function(_SwapQuoteStreamReceive) _then;

/// Create a copy of SwapQuoteStreamReceive
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coin = null,Object? grossAmount = null,Object? grossAmountUsd = null,Object? netAmount = null,Object? netAmountUsd = null,}) {
  return _then(_SwapQuoteStreamReceive(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,grossAmount: null == grossAmount ? _self.grossAmount : grossAmount // ignore: cast_nullable_to_non_nullable
as String,grossAmountUsd: null == grossAmountUsd ? _self.grossAmountUsd : grossAmountUsd // ignore: cast_nullable_to_non_nullable
as String,netAmount: null == netAmount ? _self.netAmount : netAmount // ignore: cast_nullable_to_non_nullable
as String,netAmountUsd: null == netAmountUsd ? _self.netAmountUsd : netAmountUsd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
