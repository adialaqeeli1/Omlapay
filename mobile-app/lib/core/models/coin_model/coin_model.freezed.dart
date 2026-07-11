// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coin_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoinModel {

 String? get id; String get name; String get symbol; String get amount; String get valueInUsd; double get change24h; int get decimals; String? get network; String? get iconUrl; String? get networkIconUrl; String? get contractAddress; String? get minWithdrawal; String? get minDeposit; String? get withdrawalFee; String? get description; double? get price; String? get quoteSymbol; String? get quoteSymbolAr;@JsonKey(name: 'symbol_ar') String? get coinSymbolAr;@JsonKey(name: 'name_ar') String? get coinNameAr; String? get minSendAmount; String? get maxSendAmount; String? get swapMinAmount; String? get swapMaxAmount;
/// Create a copy of CoinModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoinModelCopyWith<CoinModel> get copyWith => _$CoinModelCopyWithImpl<CoinModel>(this as CoinModel, _$identity);

  /// Serializes this CoinModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoinModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.valueInUsd, valueInUsd) || other.valueInUsd == valueInUsd)&&(identical(other.change24h, change24h) || other.change24h == change24h)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.network, network) || other.network == network)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.networkIconUrl, networkIconUrl) || other.networkIconUrl == networkIconUrl)&&(identical(other.contractAddress, contractAddress) || other.contractAddress == contractAddress)&&(identical(other.minWithdrawal, minWithdrawal) || other.minWithdrawal == minWithdrawal)&&(identical(other.minDeposit, minDeposit) || other.minDeposit == minDeposit)&&(identical(other.withdrawalFee, withdrawalFee) || other.withdrawalFee == withdrawalFee)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.quoteSymbol, quoteSymbol) || other.quoteSymbol == quoteSymbol)&&(identical(other.quoteSymbolAr, quoteSymbolAr) || other.quoteSymbolAr == quoteSymbolAr)&&(identical(other.coinSymbolAr, coinSymbolAr) || other.coinSymbolAr == coinSymbolAr)&&(identical(other.coinNameAr, coinNameAr) || other.coinNameAr == coinNameAr)&&(identical(other.minSendAmount, minSendAmount) || other.minSendAmount == minSendAmount)&&(identical(other.maxSendAmount, maxSendAmount) || other.maxSendAmount == maxSendAmount)&&(identical(other.swapMinAmount, swapMinAmount) || other.swapMinAmount == swapMinAmount)&&(identical(other.swapMaxAmount, swapMaxAmount) || other.swapMaxAmount == swapMaxAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,symbol,amount,valueInUsd,change24h,decimals,network,iconUrl,networkIconUrl,contractAddress,minWithdrawal,minDeposit,withdrawalFee,description,price,quoteSymbol,quoteSymbolAr,coinSymbolAr,coinNameAr,minSendAmount,maxSendAmount,swapMinAmount,swapMaxAmount]);

@override
String toString() {
  return 'CoinModel(id: $id, name: $name, symbol: $symbol, amount: $amount, valueInUsd: $valueInUsd, change24h: $change24h, decimals: $decimals, network: $network, iconUrl: $iconUrl, networkIconUrl: $networkIconUrl, contractAddress: $contractAddress, minWithdrawal: $minWithdrawal, minDeposit: $minDeposit, withdrawalFee: $withdrawalFee, description: $description, price: $price, quoteSymbol: $quoteSymbol, quoteSymbolAr: $quoteSymbolAr, coinSymbolAr: $coinSymbolAr, coinNameAr: $coinNameAr, minSendAmount: $minSendAmount, maxSendAmount: $maxSendAmount, swapMinAmount: $swapMinAmount, swapMaxAmount: $swapMaxAmount)';
}


}

/// @nodoc
abstract mixin class $CoinModelCopyWith<$Res>  {
  factory $CoinModelCopyWith(CoinModel value, $Res Function(CoinModel) _then) = _$CoinModelCopyWithImpl;
@useResult
$Res call({
 String? id, String name, String symbol, String amount, String valueInUsd, double change24h, int decimals, String? network, String? iconUrl, String? networkIconUrl, String? contractAddress, String? minWithdrawal, String? minDeposit, String? withdrawalFee, String? description, double? price, String? quoteSymbol, String? quoteSymbolAr,@JsonKey(name: 'symbol_ar') String? coinSymbolAr,@JsonKey(name: 'name_ar') String? coinNameAr, String? minSendAmount, String? maxSendAmount, String? swapMinAmount, String? swapMaxAmount
});




}
/// @nodoc
class _$CoinModelCopyWithImpl<$Res>
    implements $CoinModelCopyWith<$Res> {
  _$CoinModelCopyWithImpl(this._self, this._then);

  final CoinModel _self;
  final $Res Function(CoinModel) _then;

/// Create a copy of CoinModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? symbol = null,Object? amount = null,Object? valueInUsd = null,Object? change24h = null,Object? decimals = null,Object? network = freezed,Object? iconUrl = freezed,Object? networkIconUrl = freezed,Object? contractAddress = freezed,Object? minWithdrawal = freezed,Object? minDeposit = freezed,Object? withdrawalFee = freezed,Object? description = freezed,Object? price = freezed,Object? quoteSymbol = freezed,Object? quoteSymbolAr = freezed,Object? coinSymbolAr = freezed,Object? coinNameAr = freezed,Object? minSendAmount = freezed,Object? maxSendAmount = freezed,Object? swapMinAmount = freezed,Object? swapMaxAmount = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,valueInUsd: null == valueInUsd ? _self.valueInUsd : valueInUsd // ignore: cast_nullable_to_non_nullable
as String,change24h: null == change24h ? _self.change24h : change24h // ignore: cast_nullable_to_non_nullable
as double,decimals: null == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as int,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,networkIconUrl: freezed == networkIconUrl ? _self.networkIconUrl : networkIconUrl // ignore: cast_nullable_to_non_nullable
as String?,contractAddress: freezed == contractAddress ? _self.contractAddress : contractAddress // ignore: cast_nullable_to_non_nullable
as String?,minWithdrawal: freezed == minWithdrawal ? _self.minWithdrawal : minWithdrawal // ignore: cast_nullable_to_non_nullable
as String?,minDeposit: freezed == minDeposit ? _self.minDeposit : minDeposit // ignore: cast_nullable_to_non_nullable
as String?,withdrawalFee: freezed == withdrawalFee ? _self.withdrawalFee : withdrawalFee // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,quoteSymbol: freezed == quoteSymbol ? _self.quoteSymbol : quoteSymbol // ignore: cast_nullable_to_non_nullable
as String?,quoteSymbolAr: freezed == quoteSymbolAr ? _self.quoteSymbolAr : quoteSymbolAr // ignore: cast_nullable_to_non_nullable
as String?,coinSymbolAr: freezed == coinSymbolAr ? _self.coinSymbolAr : coinSymbolAr // ignore: cast_nullable_to_non_nullable
as String?,coinNameAr: freezed == coinNameAr ? _self.coinNameAr : coinNameAr // ignore: cast_nullable_to_non_nullable
as String?,minSendAmount: freezed == minSendAmount ? _self.minSendAmount : minSendAmount // ignore: cast_nullable_to_non_nullable
as String?,maxSendAmount: freezed == maxSendAmount ? _self.maxSendAmount : maxSendAmount // ignore: cast_nullable_to_non_nullable
as String?,swapMinAmount: freezed == swapMinAmount ? _self.swapMinAmount : swapMinAmount // ignore: cast_nullable_to_non_nullable
as String?,swapMaxAmount: freezed == swapMaxAmount ? _self.swapMaxAmount : swapMaxAmount // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoinModel].
extension CoinModelPatterns on CoinModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoinModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoinModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoinModel value)  $default,){
final _that = this;
switch (_that) {
case _CoinModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoinModel value)?  $default,){
final _that = this;
switch (_that) {
case _CoinModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name,  String symbol,  String amount,  String valueInUsd,  double change24h,  int decimals,  String? network,  String? iconUrl,  String? networkIconUrl,  String? contractAddress,  String? minWithdrawal,  String? minDeposit,  String? withdrawalFee,  String? description,  double? price,  String? quoteSymbol,  String? quoteSymbolAr, @JsonKey(name: 'symbol_ar')  String? coinSymbolAr, @JsonKey(name: 'name_ar')  String? coinNameAr,  String? minSendAmount,  String? maxSendAmount,  String? swapMinAmount,  String? swapMaxAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoinModel() when $default != null:
return $default(_that.id,_that.name,_that.symbol,_that.amount,_that.valueInUsd,_that.change24h,_that.decimals,_that.network,_that.iconUrl,_that.networkIconUrl,_that.contractAddress,_that.minWithdrawal,_that.minDeposit,_that.withdrawalFee,_that.description,_that.price,_that.quoteSymbol,_that.quoteSymbolAr,_that.coinSymbolAr,_that.coinNameAr,_that.minSendAmount,_that.maxSendAmount,_that.swapMinAmount,_that.swapMaxAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name,  String symbol,  String amount,  String valueInUsd,  double change24h,  int decimals,  String? network,  String? iconUrl,  String? networkIconUrl,  String? contractAddress,  String? minWithdrawal,  String? minDeposit,  String? withdrawalFee,  String? description,  double? price,  String? quoteSymbol,  String? quoteSymbolAr, @JsonKey(name: 'symbol_ar')  String? coinSymbolAr, @JsonKey(name: 'name_ar')  String? coinNameAr,  String? minSendAmount,  String? maxSendAmount,  String? swapMinAmount,  String? swapMaxAmount)  $default,) {final _that = this;
switch (_that) {
case _CoinModel():
return $default(_that.id,_that.name,_that.symbol,_that.amount,_that.valueInUsd,_that.change24h,_that.decimals,_that.network,_that.iconUrl,_that.networkIconUrl,_that.contractAddress,_that.minWithdrawal,_that.minDeposit,_that.withdrawalFee,_that.description,_that.price,_that.quoteSymbol,_that.quoteSymbolAr,_that.coinSymbolAr,_that.coinNameAr,_that.minSendAmount,_that.maxSendAmount,_that.swapMinAmount,_that.swapMaxAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name,  String symbol,  String amount,  String valueInUsd,  double change24h,  int decimals,  String? network,  String? iconUrl,  String? networkIconUrl,  String? contractAddress,  String? minWithdrawal,  String? minDeposit,  String? withdrawalFee,  String? description,  double? price,  String? quoteSymbol,  String? quoteSymbolAr, @JsonKey(name: 'symbol_ar')  String? coinSymbolAr, @JsonKey(name: 'name_ar')  String? coinNameAr,  String? minSendAmount,  String? maxSendAmount,  String? swapMinAmount,  String? swapMaxAmount)?  $default,) {final _that = this;
switch (_that) {
case _CoinModel() when $default != null:
return $default(_that.id,_that.name,_that.symbol,_that.amount,_that.valueInUsd,_that.change24h,_that.decimals,_that.network,_that.iconUrl,_that.networkIconUrl,_that.contractAddress,_that.minWithdrawal,_that.minDeposit,_that.withdrawalFee,_that.description,_that.price,_that.quoteSymbol,_that.quoteSymbolAr,_that.coinSymbolAr,_that.coinNameAr,_that.minSendAmount,_that.maxSendAmount,_that.swapMinAmount,_that.swapMaxAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoinModel implements CoinModel {
  const _CoinModel({this.id, required this.name, required this.symbol, required this.amount, required this.valueInUsd, this.change24h = 0, this.decimals = 0, this.network, this.iconUrl, this.networkIconUrl, this.contractAddress, this.minWithdrawal, this.minDeposit, this.withdrawalFee, this.description, this.price, this.quoteSymbol, this.quoteSymbolAr, @JsonKey(name: 'symbol_ar') this.coinSymbolAr, @JsonKey(name: 'name_ar') this.coinNameAr, this.minSendAmount, this.maxSendAmount, this.swapMinAmount, this.swapMaxAmount});
  factory _CoinModel.fromJson(Map<String, dynamic> json) => _$CoinModelFromJson(json);

@override final  String? id;
@override final  String name;
@override final  String symbol;
@override final  String amount;
@override final  String valueInUsd;
@override@JsonKey() final  double change24h;
@override@JsonKey() final  int decimals;
@override final  String? network;
@override final  String? iconUrl;
@override final  String? networkIconUrl;
@override final  String? contractAddress;
@override final  String? minWithdrawal;
@override final  String? minDeposit;
@override final  String? withdrawalFee;
@override final  String? description;
@override final  double? price;
@override final  String? quoteSymbol;
@override final  String? quoteSymbolAr;
@override@JsonKey(name: 'symbol_ar') final  String? coinSymbolAr;
@override@JsonKey(name: 'name_ar') final  String? coinNameAr;
@override final  String? minSendAmount;
@override final  String? maxSendAmount;
@override final  String? swapMinAmount;
@override final  String? swapMaxAmount;

/// Create a copy of CoinModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoinModelCopyWith<_CoinModel> get copyWith => __$CoinModelCopyWithImpl<_CoinModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoinModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoinModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.valueInUsd, valueInUsd) || other.valueInUsd == valueInUsd)&&(identical(other.change24h, change24h) || other.change24h == change24h)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.network, network) || other.network == network)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.networkIconUrl, networkIconUrl) || other.networkIconUrl == networkIconUrl)&&(identical(other.contractAddress, contractAddress) || other.contractAddress == contractAddress)&&(identical(other.minWithdrawal, minWithdrawal) || other.minWithdrawal == minWithdrawal)&&(identical(other.minDeposit, minDeposit) || other.minDeposit == minDeposit)&&(identical(other.withdrawalFee, withdrawalFee) || other.withdrawalFee == withdrawalFee)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.quoteSymbol, quoteSymbol) || other.quoteSymbol == quoteSymbol)&&(identical(other.quoteSymbolAr, quoteSymbolAr) || other.quoteSymbolAr == quoteSymbolAr)&&(identical(other.coinSymbolAr, coinSymbolAr) || other.coinSymbolAr == coinSymbolAr)&&(identical(other.coinNameAr, coinNameAr) || other.coinNameAr == coinNameAr)&&(identical(other.minSendAmount, minSendAmount) || other.minSendAmount == minSendAmount)&&(identical(other.maxSendAmount, maxSendAmount) || other.maxSendAmount == maxSendAmount)&&(identical(other.swapMinAmount, swapMinAmount) || other.swapMinAmount == swapMinAmount)&&(identical(other.swapMaxAmount, swapMaxAmount) || other.swapMaxAmount == swapMaxAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,symbol,amount,valueInUsd,change24h,decimals,network,iconUrl,networkIconUrl,contractAddress,minWithdrawal,minDeposit,withdrawalFee,description,price,quoteSymbol,quoteSymbolAr,coinSymbolAr,coinNameAr,minSendAmount,maxSendAmount,swapMinAmount,swapMaxAmount]);

@override
String toString() {
  return 'CoinModel(id: $id, name: $name, symbol: $symbol, amount: $amount, valueInUsd: $valueInUsd, change24h: $change24h, decimals: $decimals, network: $network, iconUrl: $iconUrl, networkIconUrl: $networkIconUrl, contractAddress: $contractAddress, minWithdrawal: $minWithdrawal, minDeposit: $minDeposit, withdrawalFee: $withdrawalFee, description: $description, price: $price, quoteSymbol: $quoteSymbol, quoteSymbolAr: $quoteSymbolAr, coinSymbolAr: $coinSymbolAr, coinNameAr: $coinNameAr, minSendAmount: $minSendAmount, maxSendAmount: $maxSendAmount, swapMinAmount: $swapMinAmount, swapMaxAmount: $swapMaxAmount)';
}


}

/// @nodoc
abstract mixin class _$CoinModelCopyWith<$Res> implements $CoinModelCopyWith<$Res> {
  factory _$CoinModelCopyWith(_CoinModel value, $Res Function(_CoinModel) _then) = __$CoinModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name, String symbol, String amount, String valueInUsd, double change24h, int decimals, String? network, String? iconUrl, String? networkIconUrl, String? contractAddress, String? minWithdrawal, String? minDeposit, String? withdrawalFee, String? description, double? price, String? quoteSymbol, String? quoteSymbolAr,@JsonKey(name: 'symbol_ar') String? coinSymbolAr,@JsonKey(name: 'name_ar') String? coinNameAr, String? minSendAmount, String? maxSendAmount, String? swapMinAmount, String? swapMaxAmount
});




}
/// @nodoc
class __$CoinModelCopyWithImpl<$Res>
    implements _$CoinModelCopyWith<$Res> {
  __$CoinModelCopyWithImpl(this._self, this._then);

  final _CoinModel _self;
  final $Res Function(_CoinModel) _then;

/// Create a copy of CoinModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? symbol = null,Object? amount = null,Object? valueInUsd = null,Object? change24h = null,Object? decimals = null,Object? network = freezed,Object? iconUrl = freezed,Object? networkIconUrl = freezed,Object? contractAddress = freezed,Object? minWithdrawal = freezed,Object? minDeposit = freezed,Object? withdrawalFee = freezed,Object? description = freezed,Object? price = freezed,Object? quoteSymbol = freezed,Object? quoteSymbolAr = freezed,Object? coinSymbolAr = freezed,Object? coinNameAr = freezed,Object? minSendAmount = freezed,Object? maxSendAmount = freezed,Object? swapMinAmount = freezed,Object? swapMaxAmount = freezed,}) {
  return _then(_CoinModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,valueInUsd: null == valueInUsd ? _self.valueInUsd : valueInUsd // ignore: cast_nullable_to_non_nullable
as String,change24h: null == change24h ? _self.change24h : change24h // ignore: cast_nullable_to_non_nullable
as double,decimals: null == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as int,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,networkIconUrl: freezed == networkIconUrl ? _self.networkIconUrl : networkIconUrl // ignore: cast_nullable_to_non_nullable
as String?,contractAddress: freezed == contractAddress ? _self.contractAddress : contractAddress // ignore: cast_nullable_to_non_nullable
as String?,minWithdrawal: freezed == minWithdrawal ? _self.minWithdrawal : minWithdrawal // ignore: cast_nullable_to_non_nullable
as String?,minDeposit: freezed == minDeposit ? _self.minDeposit : minDeposit // ignore: cast_nullable_to_non_nullable
as String?,withdrawalFee: freezed == withdrawalFee ? _self.withdrawalFee : withdrawalFee // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,quoteSymbol: freezed == quoteSymbol ? _self.quoteSymbol : quoteSymbol // ignore: cast_nullable_to_non_nullable
as String?,quoteSymbolAr: freezed == quoteSymbolAr ? _self.quoteSymbolAr : quoteSymbolAr // ignore: cast_nullable_to_non_nullable
as String?,coinSymbolAr: freezed == coinSymbolAr ? _self.coinSymbolAr : coinSymbolAr // ignore: cast_nullable_to_non_nullable
as String?,coinNameAr: freezed == coinNameAr ? _self.coinNameAr : coinNameAr // ignore: cast_nullable_to_non_nullable
as String?,minSendAmount: freezed == minSendAmount ? _self.minSendAmount : minSendAmount // ignore: cast_nullable_to_non_nullable
as String?,maxSendAmount: freezed == maxSendAmount ? _self.maxSendAmount : maxSendAmount // ignore: cast_nullable_to_non_nullable
as String?,swapMinAmount: freezed == swapMinAmount ? _self.swapMinAmount : swapMinAmount // ignore: cast_nullable_to_non_nullable
as String?,swapMaxAmount: freezed == swapMaxAmount ? _self.swapMaxAmount : swapMaxAmount // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
