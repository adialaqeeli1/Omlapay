// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_swap_asset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionSwapAsset {

 String? get symbol; String? get name;@JsonKey(name: 'name_ar') String? get nameAr; String? get iconUrl; String? get amount; String? get amountDisplay;
/// Create a copy of TransactionSwapAsset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionSwapAssetCopyWith<TransactionSwapAsset> get copyWith => _$TransactionSwapAssetCopyWithImpl<TransactionSwapAsset>(this as TransactionSwapAsset, _$identity);

  /// Serializes this TransactionSwapAsset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionSwapAsset&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountDisplay, amountDisplay) || other.amountDisplay == amountDisplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,name,nameAr,iconUrl,amount,amountDisplay);

@override
String toString() {
  return 'TransactionSwapAsset(symbol: $symbol, name: $name, nameAr: $nameAr, iconUrl: $iconUrl, amount: $amount, amountDisplay: $amountDisplay)';
}


}

/// @nodoc
abstract mixin class $TransactionSwapAssetCopyWith<$Res>  {
  factory $TransactionSwapAssetCopyWith(TransactionSwapAsset value, $Res Function(TransactionSwapAsset) _then) = _$TransactionSwapAssetCopyWithImpl;
@useResult
$Res call({
 String? symbol, String? name,@JsonKey(name: 'name_ar') String? nameAr, String? iconUrl, String? amount, String? amountDisplay
});




}
/// @nodoc
class _$TransactionSwapAssetCopyWithImpl<$Res>
    implements $TransactionSwapAssetCopyWith<$Res> {
  _$TransactionSwapAssetCopyWithImpl(this._self, this._then);

  final TransactionSwapAsset _self;
  final $Res Function(TransactionSwapAsset) _then;

/// Create a copy of TransactionSwapAsset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? symbol = freezed,Object? name = freezed,Object? nameAr = freezed,Object? iconUrl = freezed,Object? amount = freezed,Object? amountDisplay = freezed,}) {
  return _then(_self.copyWith(
symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String?,amountDisplay: freezed == amountDisplay ? _self.amountDisplay : amountDisplay // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionSwapAsset].
extension TransactionSwapAssetPatterns on TransactionSwapAsset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionSwapAsset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionSwapAsset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionSwapAsset value)  $default,){
final _that = this;
switch (_that) {
case _TransactionSwapAsset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionSwapAsset value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionSwapAsset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? symbol,  String? name, @JsonKey(name: 'name_ar')  String? nameAr,  String? iconUrl,  String? amount,  String? amountDisplay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionSwapAsset() when $default != null:
return $default(_that.symbol,_that.name,_that.nameAr,_that.iconUrl,_that.amount,_that.amountDisplay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? symbol,  String? name, @JsonKey(name: 'name_ar')  String? nameAr,  String? iconUrl,  String? amount,  String? amountDisplay)  $default,) {final _that = this;
switch (_that) {
case _TransactionSwapAsset():
return $default(_that.symbol,_that.name,_that.nameAr,_that.iconUrl,_that.amount,_that.amountDisplay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? symbol,  String? name, @JsonKey(name: 'name_ar')  String? nameAr,  String? iconUrl,  String? amount,  String? amountDisplay)?  $default,) {final _that = this;
switch (_that) {
case _TransactionSwapAsset() when $default != null:
return $default(_that.symbol,_that.name,_that.nameAr,_that.iconUrl,_that.amount,_that.amountDisplay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionSwapAsset implements TransactionSwapAsset {
  const _TransactionSwapAsset({this.symbol, this.name, @JsonKey(name: 'name_ar') this.nameAr, this.iconUrl, this.amount, this.amountDisplay});
  factory _TransactionSwapAsset.fromJson(Map<String, dynamic> json) => _$TransactionSwapAssetFromJson(json);

@override final  String? symbol;
@override final  String? name;
@override@JsonKey(name: 'name_ar') final  String? nameAr;
@override final  String? iconUrl;
@override final  String? amount;
@override final  String? amountDisplay;

/// Create a copy of TransactionSwapAsset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionSwapAssetCopyWith<_TransactionSwapAsset> get copyWith => __$TransactionSwapAssetCopyWithImpl<_TransactionSwapAsset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionSwapAssetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionSwapAsset&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountDisplay, amountDisplay) || other.amountDisplay == amountDisplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,name,nameAr,iconUrl,amount,amountDisplay);

@override
String toString() {
  return 'TransactionSwapAsset(symbol: $symbol, name: $name, nameAr: $nameAr, iconUrl: $iconUrl, amount: $amount, amountDisplay: $amountDisplay)';
}


}

/// @nodoc
abstract mixin class _$TransactionSwapAssetCopyWith<$Res> implements $TransactionSwapAssetCopyWith<$Res> {
  factory _$TransactionSwapAssetCopyWith(_TransactionSwapAsset value, $Res Function(_TransactionSwapAsset) _then) = __$TransactionSwapAssetCopyWithImpl;
@override @useResult
$Res call({
 String? symbol, String? name,@JsonKey(name: 'name_ar') String? nameAr, String? iconUrl, String? amount, String? amountDisplay
});




}
/// @nodoc
class __$TransactionSwapAssetCopyWithImpl<$Res>
    implements _$TransactionSwapAssetCopyWith<$Res> {
  __$TransactionSwapAssetCopyWithImpl(this._self, this._then);

  final _TransactionSwapAsset _self;
  final $Res Function(_TransactionSwapAsset) _then;

/// Create a copy of TransactionSwapAsset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? symbol = freezed,Object? name = freezed,Object? nameAr = freezed,Object? iconUrl = freezed,Object? amount = freezed,Object? amountDisplay = freezed,}) {
  return _then(_TransactionSwapAsset(
symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String?,amountDisplay: freezed == amountDisplay ? _self.amountDisplay : amountDisplay // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
