// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'send_confirm_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SendConfirmResponseModel {

 String get transactionId; String get amount; String get coin; String get status; String get estimatedCompletion;
/// Create a copy of SendConfirmResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendConfirmResponseModelCopyWith<SendConfirmResponseModel> get copyWith => _$SendConfirmResponseModelCopyWithImpl<SendConfirmResponseModel>(this as SendConfirmResponseModel, _$identity);

  /// Serializes this SendConfirmResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendConfirmResponseModel&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.status, status) || other.status == status)&&(identical(other.estimatedCompletion, estimatedCompletion) || other.estimatedCompletion == estimatedCompletion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transactionId,amount,coin,status,estimatedCompletion);

@override
String toString() {
  return 'SendConfirmResponseModel(transactionId: $transactionId, amount: $amount, coin: $coin, status: $status, estimatedCompletion: $estimatedCompletion)';
}


}

/// @nodoc
abstract mixin class $SendConfirmResponseModelCopyWith<$Res>  {
  factory $SendConfirmResponseModelCopyWith(SendConfirmResponseModel value, $Res Function(SendConfirmResponseModel) _then) = _$SendConfirmResponseModelCopyWithImpl;
@useResult
$Res call({
 String transactionId, String amount, String coin, String status, String estimatedCompletion
});




}
/// @nodoc
class _$SendConfirmResponseModelCopyWithImpl<$Res>
    implements $SendConfirmResponseModelCopyWith<$Res> {
  _$SendConfirmResponseModelCopyWithImpl(this._self, this._then);

  final SendConfirmResponseModel _self;
  final $Res Function(SendConfirmResponseModel) _then;

/// Create a copy of SendConfirmResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactionId = null,Object? amount = null,Object? coin = null,Object? status = null,Object? estimatedCompletion = null,}) {
  return _then(_self.copyWith(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,estimatedCompletion: null == estimatedCompletion ? _self.estimatedCompletion : estimatedCompletion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SendConfirmResponseModel].
extension SendConfirmResponseModelPatterns on SendConfirmResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SendConfirmResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendConfirmResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SendConfirmResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _SendConfirmResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SendConfirmResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _SendConfirmResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String transactionId,  String amount,  String coin,  String status,  String estimatedCompletion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendConfirmResponseModel() when $default != null:
return $default(_that.transactionId,_that.amount,_that.coin,_that.status,_that.estimatedCompletion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String transactionId,  String amount,  String coin,  String status,  String estimatedCompletion)  $default,) {final _that = this;
switch (_that) {
case _SendConfirmResponseModel():
return $default(_that.transactionId,_that.amount,_that.coin,_that.status,_that.estimatedCompletion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String transactionId,  String amount,  String coin,  String status,  String estimatedCompletion)?  $default,) {final _that = this;
switch (_that) {
case _SendConfirmResponseModel() when $default != null:
return $default(_that.transactionId,_that.amount,_that.coin,_that.status,_that.estimatedCompletion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SendConfirmResponseModel implements SendConfirmResponseModel {
  const _SendConfirmResponseModel({this.transactionId = '', this.amount = '', this.coin = '', this.status = '', this.estimatedCompletion = ''});
  factory _SendConfirmResponseModel.fromJson(Map<String, dynamic> json) => _$SendConfirmResponseModelFromJson(json);

@override@JsonKey() final  String transactionId;
@override@JsonKey() final  String amount;
@override@JsonKey() final  String coin;
@override@JsonKey() final  String status;
@override@JsonKey() final  String estimatedCompletion;

/// Create a copy of SendConfirmResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendConfirmResponseModelCopyWith<_SendConfirmResponseModel> get copyWith => __$SendConfirmResponseModelCopyWithImpl<_SendConfirmResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SendConfirmResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendConfirmResponseModel&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.status, status) || other.status == status)&&(identical(other.estimatedCompletion, estimatedCompletion) || other.estimatedCompletion == estimatedCompletion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transactionId,amount,coin,status,estimatedCompletion);

@override
String toString() {
  return 'SendConfirmResponseModel(transactionId: $transactionId, amount: $amount, coin: $coin, status: $status, estimatedCompletion: $estimatedCompletion)';
}


}

/// @nodoc
abstract mixin class _$SendConfirmResponseModelCopyWith<$Res> implements $SendConfirmResponseModelCopyWith<$Res> {
  factory _$SendConfirmResponseModelCopyWith(_SendConfirmResponseModel value, $Res Function(_SendConfirmResponseModel) _then) = __$SendConfirmResponseModelCopyWithImpl;
@override @useResult
$Res call({
 String transactionId, String amount, String coin, String status, String estimatedCompletion
});




}
/// @nodoc
class __$SendConfirmResponseModelCopyWithImpl<$Res>
    implements _$SendConfirmResponseModelCopyWith<$Res> {
  __$SendConfirmResponseModelCopyWithImpl(this._self, this._then);

  final _SendConfirmResponseModel _self;
  final $Res Function(_SendConfirmResponseModel) _then;

/// Create a copy of SendConfirmResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactionId = null,Object? amount = null,Object? coin = null,Object? status = null,Object? estimatedCompletion = null,}) {
  return _then(_SendConfirmResponseModel(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,estimatedCompletion: null == estimatedCompletion ? _self.estimatedCompletion : estimatedCompletion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
