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

 String get id; String get coinSymbol; String get coinName; String get amount; String get valueInCurrency; TransactionType get type; TransactionStatus get status; DateTime get date; String? get toAddress; String? get fromAddress; String? get transactionHash; double? get fee; String? get note;
/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionModelCopyWith<TransactionModel> get copyWith => _$TransactionModelCopyWithImpl<TransactionModel>(this as TransactionModel, _$identity);

  /// Serializes this TransactionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.coinSymbol, coinSymbol) || other.coinSymbol == coinSymbol)&&(identical(other.coinName, coinName) || other.coinName == coinName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.valueInCurrency, valueInCurrency) || other.valueInCurrency == valueInCurrency)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.date, date) || other.date == date)&&(identical(other.toAddress, toAddress) || other.toAddress == toAddress)&&(identical(other.fromAddress, fromAddress) || other.fromAddress == fromAddress)&&(identical(other.transactionHash, transactionHash) || other.transactionHash == transactionHash)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coinSymbol,coinName,amount,valueInCurrency,type,status,date,toAddress,fromAddress,transactionHash,fee,note);

@override
String toString() {
  return 'TransactionModel(id: $id, coinSymbol: $coinSymbol, coinName: $coinName, amount: $amount, valueInCurrency: $valueInCurrency, type: $type, status: $status, date: $date, toAddress: $toAddress, fromAddress: $fromAddress, transactionHash: $transactionHash, fee: $fee, note: $note)';
}


}

/// @nodoc
abstract mixin class $TransactionModelCopyWith<$Res>  {
  factory $TransactionModelCopyWith(TransactionModel value, $Res Function(TransactionModel) _then) = _$TransactionModelCopyWithImpl;
@useResult
$Res call({
 String id, String coinSymbol, String coinName, String amount, String valueInCurrency, TransactionType type, TransactionStatus status, DateTime date, String? toAddress, String? fromAddress, String? transactionHash, double? fee, String? note
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? coinSymbol = null,Object? coinName = null,Object? amount = null,Object? valueInCurrency = null,Object? type = null,Object? status = null,Object? date = null,Object? toAddress = freezed,Object? fromAddress = freezed,Object? transactionHash = freezed,Object? fee = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coinSymbol: null == coinSymbol ? _self.coinSymbol : coinSymbol // ignore: cast_nullable_to_non_nullable
as String,coinName: null == coinName ? _self.coinName : coinName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,valueInCurrency: null == valueInCurrency ? _self.valueInCurrency : valueInCurrency // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,toAddress: freezed == toAddress ? _self.toAddress : toAddress // ignore: cast_nullable_to_non_nullable
as String?,fromAddress: freezed == fromAddress ? _self.fromAddress : fromAddress // ignore: cast_nullable_to_non_nullable
as String?,transactionHash: freezed == transactionHash ? _self.transactionHash : transactionHash // ignore: cast_nullable_to_non_nullable
as String?,fee: freezed == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String coinSymbol,  String coinName,  String amount,  String valueInCurrency,  TransactionType type,  TransactionStatus status,  DateTime date,  String? toAddress,  String? fromAddress,  String? transactionHash,  double? fee,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.coinSymbol,_that.coinName,_that.amount,_that.valueInCurrency,_that.type,_that.status,_that.date,_that.toAddress,_that.fromAddress,_that.transactionHash,_that.fee,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String coinSymbol,  String coinName,  String amount,  String valueInCurrency,  TransactionType type,  TransactionStatus status,  DateTime date,  String? toAddress,  String? fromAddress,  String? transactionHash,  double? fee,  String? note)  $default,) {final _that = this;
switch (_that) {
case _TransactionModel():
return $default(_that.id,_that.coinSymbol,_that.coinName,_that.amount,_that.valueInCurrency,_that.type,_that.status,_that.date,_that.toAddress,_that.fromAddress,_that.transactionHash,_that.fee,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String coinSymbol,  String coinName,  String amount,  String valueInCurrency,  TransactionType type,  TransactionStatus status,  DateTime date,  String? toAddress,  String? fromAddress,  String? transactionHash,  double? fee,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.coinSymbol,_that.coinName,_that.amount,_that.valueInCurrency,_that.type,_that.status,_that.date,_that.toAddress,_that.fromAddress,_that.transactionHash,_that.fee,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionModel implements TransactionModel {
  const _TransactionModel({required this.id, required this.coinSymbol, required this.coinName, required this.amount, required this.valueInCurrency, required this.type, required this.status, required this.date, required this.toAddress, required this.fromAddress, required this.transactionHash, required this.fee, this.note});
  factory _TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);

@override final  String id;
@override final  String coinSymbol;
@override final  String coinName;
@override final  String amount;
@override final  String valueInCurrency;
@override final  TransactionType type;
@override final  TransactionStatus status;
@override final  DateTime date;
@override final  String? toAddress;
@override final  String? fromAddress;
@override final  String? transactionHash;
@override final  double? fee;
@override final  String? note;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.coinSymbol, coinSymbol) || other.coinSymbol == coinSymbol)&&(identical(other.coinName, coinName) || other.coinName == coinName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.valueInCurrency, valueInCurrency) || other.valueInCurrency == valueInCurrency)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.date, date) || other.date == date)&&(identical(other.toAddress, toAddress) || other.toAddress == toAddress)&&(identical(other.fromAddress, fromAddress) || other.fromAddress == fromAddress)&&(identical(other.transactionHash, transactionHash) || other.transactionHash == transactionHash)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coinSymbol,coinName,amount,valueInCurrency,type,status,date,toAddress,fromAddress,transactionHash,fee,note);

@override
String toString() {
  return 'TransactionModel(id: $id, coinSymbol: $coinSymbol, coinName: $coinName, amount: $amount, valueInCurrency: $valueInCurrency, type: $type, status: $status, date: $date, toAddress: $toAddress, fromAddress: $fromAddress, transactionHash: $transactionHash, fee: $fee, note: $note)';
}


}

/// @nodoc
abstract mixin class _$TransactionModelCopyWith<$Res> implements $TransactionModelCopyWith<$Res> {
  factory _$TransactionModelCopyWith(_TransactionModel value, $Res Function(_TransactionModel) _then) = __$TransactionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String coinSymbol, String coinName, String amount, String valueInCurrency, TransactionType type, TransactionStatus status, DateTime date, String? toAddress, String? fromAddress, String? transactionHash, double? fee, String? note
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? coinSymbol = null,Object? coinName = null,Object? amount = null,Object? valueInCurrency = null,Object? type = null,Object? status = null,Object? date = null,Object? toAddress = freezed,Object? fromAddress = freezed,Object? transactionHash = freezed,Object? fee = freezed,Object? note = freezed,}) {
  return _then(_TransactionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coinSymbol: null == coinSymbol ? _self.coinSymbol : coinSymbol // ignore: cast_nullable_to_non_nullable
as String,coinName: null == coinName ? _self.coinName : coinName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,valueInCurrency: null == valueInCurrency ? _self.valueInCurrency : valueInCurrency // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,toAddress: freezed == toAddress ? _self.toAddress : toAddress // ignore: cast_nullable_to_non_nullable
as String?,fromAddress: freezed == fromAddress ? _self.fromAddress : fromAddress // ignore: cast_nullable_to_non_nullable
as String?,transactionHash: freezed == transactionHash ? _self.transactionHash : transactionHash // ignore: cast_nullable_to_non_nullable
as String?,fee: freezed == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
