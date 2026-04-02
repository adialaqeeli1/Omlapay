// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WalletNetworkModel {

@JsonKey(name: 'network') String get network;@JsonKey(name: 'networkDisplayName') String get networkDisplayName;@JsonKey(name: 'networkIconUrl') String get networkIconUrl; List<WalletCoinModel> get coins;
/// Create a copy of WalletNetworkModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletNetworkModelCopyWith<WalletNetworkModel> get copyWith => _$WalletNetworkModelCopyWithImpl<WalletNetworkModel>(this as WalletNetworkModel, _$identity);

  /// Serializes this WalletNetworkModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletNetworkModel&&(identical(other.network, network) || other.network == network)&&(identical(other.networkDisplayName, networkDisplayName) || other.networkDisplayName == networkDisplayName)&&(identical(other.networkIconUrl, networkIconUrl) || other.networkIconUrl == networkIconUrl)&&const DeepCollectionEquality().equals(other.coins, coins));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,network,networkDisplayName,networkIconUrl,const DeepCollectionEquality().hash(coins));

@override
String toString() {
  return 'WalletNetworkModel(network: $network, networkDisplayName: $networkDisplayName, networkIconUrl: $networkIconUrl, coins: $coins)';
}


}

/// @nodoc
abstract mixin class $WalletNetworkModelCopyWith<$Res>  {
  factory $WalletNetworkModelCopyWith(WalletNetworkModel value, $Res Function(WalletNetworkModel) _then) = _$WalletNetworkModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'network') String network,@JsonKey(name: 'networkDisplayName') String networkDisplayName,@JsonKey(name: 'networkIconUrl') String networkIconUrl, List<WalletCoinModel> coins
});




}
/// @nodoc
class _$WalletNetworkModelCopyWithImpl<$Res>
    implements $WalletNetworkModelCopyWith<$Res> {
  _$WalletNetworkModelCopyWithImpl(this._self, this._then);

  final WalletNetworkModel _self;
  final $Res Function(WalletNetworkModel) _then;

/// Create a copy of WalletNetworkModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? network = null,Object? networkDisplayName = null,Object? networkIconUrl = null,Object? coins = null,}) {
  return _then(_self.copyWith(
network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,networkDisplayName: null == networkDisplayName ? _self.networkDisplayName : networkDisplayName // ignore: cast_nullable_to_non_nullable
as String,networkIconUrl: null == networkIconUrl ? _self.networkIconUrl : networkIconUrl // ignore: cast_nullable_to_non_nullable
as String,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as List<WalletCoinModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletNetworkModel].
extension WalletNetworkModelPatterns on WalletNetworkModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletNetworkModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletNetworkModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletNetworkModel value)  $default,){
final _that = this;
switch (_that) {
case _WalletNetworkModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletNetworkModel value)?  $default,){
final _that = this;
switch (_that) {
case _WalletNetworkModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'network')  String network, @JsonKey(name: 'networkDisplayName')  String networkDisplayName, @JsonKey(name: 'networkIconUrl')  String networkIconUrl,  List<WalletCoinModel> coins)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletNetworkModel() when $default != null:
return $default(_that.network,_that.networkDisplayName,_that.networkIconUrl,_that.coins);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'network')  String network, @JsonKey(name: 'networkDisplayName')  String networkDisplayName, @JsonKey(name: 'networkIconUrl')  String networkIconUrl,  List<WalletCoinModel> coins)  $default,) {final _that = this;
switch (_that) {
case _WalletNetworkModel():
return $default(_that.network,_that.networkDisplayName,_that.networkIconUrl,_that.coins);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'network')  String network, @JsonKey(name: 'networkDisplayName')  String networkDisplayName, @JsonKey(name: 'networkIconUrl')  String networkIconUrl,  List<WalletCoinModel> coins)?  $default,) {final _that = this;
switch (_that) {
case _WalletNetworkModel() when $default != null:
return $default(_that.network,_that.networkDisplayName,_that.networkIconUrl,_that.coins);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletNetworkModel implements WalletNetworkModel {
  const _WalletNetworkModel({@JsonKey(name: 'network') this.network = '', @JsonKey(name: 'networkDisplayName') this.networkDisplayName = '', @JsonKey(name: 'networkIconUrl') this.networkIconUrl = '', final  List<WalletCoinModel> coins = const <WalletCoinModel>[]}): _coins = coins;
  factory _WalletNetworkModel.fromJson(Map<String, dynamic> json) => _$WalletNetworkModelFromJson(json);

@override@JsonKey(name: 'network') final  String network;
@override@JsonKey(name: 'networkDisplayName') final  String networkDisplayName;
@override@JsonKey(name: 'networkIconUrl') final  String networkIconUrl;
 final  List<WalletCoinModel> _coins;
@override@JsonKey() List<WalletCoinModel> get coins {
  if (_coins is EqualUnmodifiableListView) return _coins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_coins);
}


/// Create a copy of WalletNetworkModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletNetworkModelCopyWith<_WalletNetworkModel> get copyWith => __$WalletNetworkModelCopyWithImpl<_WalletNetworkModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletNetworkModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletNetworkModel&&(identical(other.network, network) || other.network == network)&&(identical(other.networkDisplayName, networkDisplayName) || other.networkDisplayName == networkDisplayName)&&(identical(other.networkIconUrl, networkIconUrl) || other.networkIconUrl == networkIconUrl)&&const DeepCollectionEquality().equals(other._coins, _coins));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,network,networkDisplayName,networkIconUrl,const DeepCollectionEquality().hash(_coins));

@override
String toString() {
  return 'WalletNetworkModel(network: $network, networkDisplayName: $networkDisplayName, networkIconUrl: $networkIconUrl, coins: $coins)';
}


}

/// @nodoc
abstract mixin class _$WalletNetworkModelCopyWith<$Res> implements $WalletNetworkModelCopyWith<$Res> {
  factory _$WalletNetworkModelCopyWith(_WalletNetworkModel value, $Res Function(_WalletNetworkModel) _then) = __$WalletNetworkModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'network') String network,@JsonKey(name: 'networkDisplayName') String networkDisplayName,@JsonKey(name: 'networkIconUrl') String networkIconUrl, List<WalletCoinModel> coins
});




}
/// @nodoc
class __$WalletNetworkModelCopyWithImpl<$Res>
    implements _$WalletNetworkModelCopyWith<$Res> {
  __$WalletNetworkModelCopyWithImpl(this._self, this._then);

  final _WalletNetworkModel _self;
  final $Res Function(_WalletNetworkModel) _then;

/// Create a copy of WalletNetworkModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? network = null,Object? networkDisplayName = null,Object? networkIconUrl = null,Object? coins = null,}) {
  return _then(_WalletNetworkModel(
network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,networkDisplayName: null == networkDisplayName ? _self.networkDisplayName : networkDisplayName // ignore: cast_nullable_to_non_nullable
as String,networkIconUrl: null == networkIconUrl ? _self.networkIconUrl : networkIconUrl // ignore: cast_nullable_to_non_nullable
as String,coins: null == coins ? _self._coins : coins // ignore: cast_nullable_to_non_nullable
as List<WalletCoinModel>,
  ));
}


}


/// @nodoc
mixin _$WalletCoinModel {

@JsonKey(name: 'name') String get name;@JsonKey(name: 'symbol') String get symbol;@JsonKey(name: 'address') String? get address;@JsonKey(name: 'addressTag') String? get addressTag; String get network; String get networkDisplayName; String get networkIconUrl;
/// Create a copy of WalletCoinModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletCoinModelCopyWith<WalletCoinModel> get copyWith => _$WalletCoinModelCopyWithImpl<WalletCoinModel>(this as WalletCoinModel, _$identity);

  /// Serializes this WalletCoinModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletCoinModel&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressTag, addressTag) || other.addressTag == addressTag)&&(identical(other.network, network) || other.network == network)&&(identical(other.networkDisplayName, networkDisplayName) || other.networkDisplayName == networkDisplayName)&&(identical(other.networkIconUrl, networkIconUrl) || other.networkIconUrl == networkIconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,symbol,address,addressTag,network,networkDisplayName,networkIconUrl);

@override
String toString() {
  return 'WalletCoinModel(name: $name, symbol: $symbol, address: $address, addressTag: $addressTag, network: $network, networkDisplayName: $networkDisplayName, networkIconUrl: $networkIconUrl)';
}


}

/// @nodoc
abstract mixin class $WalletCoinModelCopyWith<$Res>  {
  factory $WalletCoinModelCopyWith(WalletCoinModel value, $Res Function(WalletCoinModel) _then) = _$WalletCoinModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'name') String name,@JsonKey(name: 'symbol') String symbol,@JsonKey(name: 'address') String? address,@JsonKey(name: 'addressTag') String? addressTag, String network, String networkDisplayName, String networkIconUrl
});




}
/// @nodoc
class _$WalletCoinModelCopyWithImpl<$Res>
    implements $WalletCoinModelCopyWith<$Res> {
  _$WalletCoinModelCopyWithImpl(this._self, this._then);

  final WalletCoinModel _self;
  final $Res Function(WalletCoinModel) _then;

/// Create a copy of WalletCoinModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? symbol = null,Object? address = freezed,Object? addressTag = freezed,Object? network = null,Object? networkDisplayName = null,Object? networkIconUrl = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,addressTag: freezed == addressTag ? _self.addressTag : addressTag // ignore: cast_nullable_to_non_nullable
as String?,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,networkDisplayName: null == networkDisplayName ? _self.networkDisplayName : networkDisplayName // ignore: cast_nullable_to_non_nullable
as String,networkIconUrl: null == networkIconUrl ? _self.networkIconUrl : networkIconUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletCoinModel].
extension WalletCoinModelPatterns on WalletCoinModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletCoinModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletCoinModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletCoinModel value)  $default,){
final _that = this;
switch (_that) {
case _WalletCoinModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletCoinModel value)?  $default,){
final _that = this;
switch (_that) {
case _WalletCoinModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'name')  String name, @JsonKey(name: 'symbol')  String symbol, @JsonKey(name: 'address')  String? address, @JsonKey(name: 'addressTag')  String? addressTag,  String network,  String networkDisplayName,  String networkIconUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletCoinModel() when $default != null:
return $default(_that.name,_that.symbol,_that.address,_that.addressTag,_that.network,_that.networkDisplayName,_that.networkIconUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'name')  String name, @JsonKey(name: 'symbol')  String symbol, @JsonKey(name: 'address')  String? address, @JsonKey(name: 'addressTag')  String? addressTag,  String network,  String networkDisplayName,  String networkIconUrl)  $default,) {final _that = this;
switch (_that) {
case _WalletCoinModel():
return $default(_that.name,_that.symbol,_that.address,_that.addressTag,_that.network,_that.networkDisplayName,_that.networkIconUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'name')  String name, @JsonKey(name: 'symbol')  String symbol, @JsonKey(name: 'address')  String? address, @JsonKey(name: 'addressTag')  String? addressTag,  String network,  String networkDisplayName,  String networkIconUrl)?  $default,) {final _that = this;
switch (_that) {
case _WalletCoinModel() when $default != null:
return $default(_that.name,_that.symbol,_that.address,_that.addressTag,_that.network,_that.networkDisplayName,_that.networkIconUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletCoinModel implements WalletCoinModel {
  const _WalletCoinModel({@JsonKey(name: 'name') this.name = '', @JsonKey(name: 'symbol') this.symbol = '', @JsonKey(name: 'address') this.address, @JsonKey(name: 'addressTag') this.addressTag, this.network = '', this.networkDisplayName = '', this.networkIconUrl = ''});
  factory _WalletCoinModel.fromJson(Map<String, dynamic> json) => _$WalletCoinModelFromJson(json);

@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'symbol') final  String symbol;
@override@JsonKey(name: 'address') final  String? address;
@override@JsonKey(name: 'addressTag') final  String? addressTag;
@override@JsonKey() final  String network;
@override@JsonKey() final  String networkDisplayName;
@override@JsonKey() final  String networkIconUrl;

/// Create a copy of WalletCoinModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletCoinModelCopyWith<_WalletCoinModel> get copyWith => __$WalletCoinModelCopyWithImpl<_WalletCoinModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletCoinModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletCoinModel&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressTag, addressTag) || other.addressTag == addressTag)&&(identical(other.network, network) || other.network == network)&&(identical(other.networkDisplayName, networkDisplayName) || other.networkDisplayName == networkDisplayName)&&(identical(other.networkIconUrl, networkIconUrl) || other.networkIconUrl == networkIconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,symbol,address,addressTag,network,networkDisplayName,networkIconUrl);

@override
String toString() {
  return 'WalletCoinModel(name: $name, symbol: $symbol, address: $address, addressTag: $addressTag, network: $network, networkDisplayName: $networkDisplayName, networkIconUrl: $networkIconUrl)';
}


}

/// @nodoc
abstract mixin class _$WalletCoinModelCopyWith<$Res> implements $WalletCoinModelCopyWith<$Res> {
  factory _$WalletCoinModelCopyWith(_WalletCoinModel value, $Res Function(_WalletCoinModel) _then) = __$WalletCoinModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'name') String name,@JsonKey(name: 'symbol') String symbol,@JsonKey(name: 'address') String? address,@JsonKey(name: 'addressTag') String? addressTag, String network, String networkDisplayName, String networkIconUrl
});




}
/// @nodoc
class __$WalletCoinModelCopyWithImpl<$Res>
    implements _$WalletCoinModelCopyWith<$Res> {
  __$WalletCoinModelCopyWithImpl(this._self, this._then);

  final _WalletCoinModel _self;
  final $Res Function(_WalletCoinModel) _then;

/// Create a copy of WalletCoinModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? symbol = null,Object? address = freezed,Object? addressTag = freezed,Object? network = null,Object? networkDisplayName = null,Object? networkIconUrl = null,}) {
  return _then(_WalletCoinModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,addressTag: freezed == addressTag ? _self.addressTag : addressTag // ignore: cast_nullable_to_non_nullable
as String?,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,networkDisplayName: null == networkDisplayName ? _self.networkDisplayName : networkDisplayName // ignore: cast_nullable_to_non_nullable
as String,networkIconUrl: null == networkIconUrl ? _self.networkIconUrl : networkIconUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
