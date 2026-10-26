// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kyc_status_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KycStatusResponse {

 SumsubStatus? get sumsub; BinanceStatus? get binance;
/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycStatusResponseCopyWith<KycStatusResponse> get copyWith => _$KycStatusResponseCopyWithImpl<KycStatusResponse>(this as KycStatusResponse, _$identity);

  /// Serializes this KycStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycStatusResponse&&(identical(other.sumsub, sumsub) || other.sumsub == sumsub)&&(identical(other.binance, binance) || other.binance == binance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sumsub,binance);

@override
String toString() {
  return 'KycStatusResponse(sumsub: $sumsub, binance: $binance)';
}


}

/// @nodoc
abstract mixin class $KycStatusResponseCopyWith<$Res>  {
  factory $KycStatusResponseCopyWith(KycStatusResponse value, $Res Function(KycStatusResponse) _then) = _$KycStatusResponseCopyWithImpl;
@useResult
$Res call({
 SumsubStatus? sumsub, BinanceStatus? binance
});


$SumsubStatusCopyWith<$Res>? get sumsub;$BinanceStatusCopyWith<$Res>? get binance;

}
/// @nodoc
class _$KycStatusResponseCopyWithImpl<$Res>
    implements $KycStatusResponseCopyWith<$Res> {
  _$KycStatusResponseCopyWithImpl(this._self, this._then);

  final KycStatusResponse _self;
  final $Res Function(KycStatusResponse) _then;

/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sumsub = freezed,Object? binance = freezed,}) {
  return _then(_self.copyWith(
sumsub: freezed == sumsub ? _self.sumsub : sumsub // ignore: cast_nullable_to_non_nullable
as SumsubStatus?,binance: freezed == binance ? _self.binance : binance // ignore: cast_nullable_to_non_nullable
as BinanceStatus?,
  ));
}
/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SumsubStatusCopyWith<$Res>? get sumsub {
    if (_self.sumsub == null) {
    return null;
  }

  return $SumsubStatusCopyWith<$Res>(_self.sumsub!, (value) {
    return _then(_self.copyWith(sumsub: value));
  });
}/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BinanceStatusCopyWith<$Res>? get binance {
    if (_self.binance == null) {
    return null;
  }

  return $BinanceStatusCopyWith<$Res>(_self.binance!, (value) {
    return _then(_self.copyWith(binance: value));
  });
}
}


/// Adds pattern-matching-related methods to [KycStatusResponse].
extension KycStatusResponsePatterns on KycStatusResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KycStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KycStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _KycStatusResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KycStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SumsubStatus? sumsub,  BinanceStatus? binance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
return $default(_that.sumsub,_that.binance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SumsubStatus? sumsub,  BinanceStatus? binance)  $default,) {final _that = this;
switch (_that) {
case _KycStatusResponse():
return $default(_that.sumsub,_that.binance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SumsubStatus? sumsub,  BinanceStatus? binance)?  $default,) {final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
return $default(_that.sumsub,_that.binance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycStatusResponse implements KycStatusResponse {
  const _KycStatusResponse({this.sumsub, this.binance});
  factory _KycStatusResponse.fromJson(Map<String, dynamic> json) => _$KycStatusResponseFromJson(json);

@override final  SumsubStatus? sumsub;
@override final  BinanceStatus? binance;

/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KycStatusResponseCopyWith<_KycStatusResponse> get copyWith => __$KycStatusResponseCopyWithImpl<_KycStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KycStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycStatusResponse&&(identical(other.sumsub, sumsub) || other.sumsub == sumsub)&&(identical(other.binance, binance) || other.binance == binance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sumsub,binance);

@override
String toString() {
  return 'KycStatusResponse(sumsub: $sumsub, binance: $binance)';
}


}

/// @nodoc
abstract mixin class _$KycStatusResponseCopyWith<$Res> implements $KycStatusResponseCopyWith<$Res> {
  factory _$KycStatusResponseCopyWith(_KycStatusResponse value, $Res Function(_KycStatusResponse) _then) = __$KycStatusResponseCopyWithImpl;
@override @useResult
$Res call({
 SumsubStatus? sumsub, BinanceStatus? binance
});


@override $SumsubStatusCopyWith<$Res>? get sumsub;@override $BinanceStatusCopyWith<$Res>? get binance;

}
/// @nodoc
class __$KycStatusResponseCopyWithImpl<$Res>
    implements _$KycStatusResponseCopyWith<$Res> {
  __$KycStatusResponseCopyWithImpl(this._self, this._then);

  final _KycStatusResponse _self;
  final $Res Function(_KycStatusResponse) _then;

/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sumsub = freezed,Object? binance = freezed,}) {
  return _then(_KycStatusResponse(
sumsub: freezed == sumsub ? _self.sumsub : sumsub // ignore: cast_nullable_to_non_nullable
as SumsubStatus?,binance: freezed == binance ? _self.binance : binance // ignore: cast_nullable_to_non_nullable
as BinanceStatus?,
  ));
}

/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SumsubStatusCopyWith<$Res>? get sumsub {
    if (_self.sumsub == null) {
    return null;
  }

  return $SumsubStatusCopyWith<$Res>(_self.sumsub!, (value) {
    return _then(_self.copyWith(sumsub: value));
  });
}/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BinanceStatusCopyWith<$Res>? get binance {
    if (_self.binance == null) {
    return null;
  }

  return $BinanceStatusCopyWith<$Res>(_self.binance!, (value) {
    return _then(_self.copyWith(binance: value));
  });
}
}


/// @nodoc
mixin _$SumsubStatus {

 String? get status; String? get referenceId; String? get verifiedAt; String? get rejectionReason;@JsonKey(name: 'rejectionReason_ar') String? get rejectionReasonAr; String? get rejectType; String? get reviewAnswer; String? get updatedAt;
/// Create a copy of SumsubStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SumsubStatusCopyWith<SumsubStatus> get copyWith => _$SumsubStatusCopyWithImpl<SumsubStatus>(this as SumsubStatus, _$identity);

  /// Serializes this SumsubStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SumsubStatus&&(identical(other.status, status) || other.status == status)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.rejectionReasonAr, rejectionReasonAr) || other.rejectionReasonAr == rejectionReasonAr)&&(identical(other.rejectType, rejectType) || other.rejectType == rejectType)&&(identical(other.reviewAnswer, reviewAnswer) || other.reviewAnswer == reviewAnswer)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,referenceId,verifiedAt,rejectionReason,rejectionReasonAr,rejectType,reviewAnswer,updatedAt);

@override
String toString() {
  return 'SumsubStatus(status: $status, referenceId: $referenceId, verifiedAt: $verifiedAt, rejectionReason: $rejectionReason, rejectionReasonAr: $rejectionReasonAr, rejectType: $rejectType, reviewAnswer: $reviewAnswer, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SumsubStatusCopyWith<$Res>  {
  factory $SumsubStatusCopyWith(SumsubStatus value, $Res Function(SumsubStatus) _then) = _$SumsubStatusCopyWithImpl;
@useResult
$Res call({
 String? status, String? referenceId, String? verifiedAt, String? rejectionReason,@JsonKey(name: 'rejectionReason_ar') String? rejectionReasonAr, String? rejectType, String? reviewAnswer, String? updatedAt
});




}
/// @nodoc
class _$SumsubStatusCopyWithImpl<$Res>
    implements $SumsubStatusCopyWith<$Res> {
  _$SumsubStatusCopyWithImpl(this._self, this._then);

  final SumsubStatus _self;
  final $Res Function(SumsubStatus) _then;

/// Create a copy of SumsubStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? referenceId = freezed,Object? verifiedAt = freezed,Object? rejectionReason = freezed,Object? rejectionReasonAr = freezed,Object? rejectType = freezed,Object? reviewAnswer = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,rejectionReasonAr: freezed == rejectionReasonAr ? _self.rejectionReasonAr : rejectionReasonAr // ignore: cast_nullable_to_non_nullable
as String?,rejectType: freezed == rejectType ? _self.rejectType : rejectType // ignore: cast_nullable_to_non_nullable
as String?,reviewAnswer: freezed == reviewAnswer ? _self.reviewAnswer : reviewAnswer // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SumsubStatus].
extension SumsubStatusPatterns on SumsubStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SumsubStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SumsubStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SumsubStatus value)  $default,){
final _that = this;
switch (_that) {
case _SumsubStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SumsubStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SumsubStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? status,  String? referenceId,  String? verifiedAt,  String? rejectionReason, @JsonKey(name: 'rejectionReason_ar')  String? rejectionReasonAr,  String? rejectType,  String? reviewAnswer,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SumsubStatus() when $default != null:
return $default(_that.status,_that.referenceId,_that.verifiedAt,_that.rejectionReason,_that.rejectionReasonAr,_that.rejectType,_that.reviewAnswer,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? status,  String? referenceId,  String? verifiedAt,  String? rejectionReason, @JsonKey(name: 'rejectionReason_ar')  String? rejectionReasonAr,  String? rejectType,  String? reviewAnswer,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SumsubStatus():
return $default(_that.status,_that.referenceId,_that.verifiedAt,_that.rejectionReason,_that.rejectionReasonAr,_that.rejectType,_that.reviewAnswer,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? status,  String? referenceId,  String? verifiedAt,  String? rejectionReason, @JsonKey(name: 'rejectionReason_ar')  String? rejectionReasonAr,  String? rejectType,  String? reviewAnswer,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SumsubStatus() when $default != null:
return $default(_that.status,_that.referenceId,_that.verifiedAt,_that.rejectionReason,_that.rejectionReasonAr,_that.rejectType,_that.reviewAnswer,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SumsubStatus implements SumsubStatus {
  const _SumsubStatus({this.status, this.referenceId, this.verifiedAt, this.rejectionReason, @JsonKey(name: 'rejectionReason_ar') this.rejectionReasonAr, this.rejectType, this.reviewAnswer, this.updatedAt});
  factory _SumsubStatus.fromJson(Map<String, dynamic> json) => _$SumsubStatusFromJson(json);

@override final  String? status;
@override final  String? referenceId;
@override final  String? verifiedAt;
@override final  String? rejectionReason;
@override@JsonKey(name: 'rejectionReason_ar') final  String? rejectionReasonAr;
@override final  String? rejectType;
@override final  String? reviewAnswer;
@override final  String? updatedAt;

/// Create a copy of SumsubStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SumsubStatusCopyWith<_SumsubStatus> get copyWith => __$SumsubStatusCopyWithImpl<_SumsubStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SumsubStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SumsubStatus&&(identical(other.status, status) || other.status == status)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.rejectionReasonAr, rejectionReasonAr) || other.rejectionReasonAr == rejectionReasonAr)&&(identical(other.rejectType, rejectType) || other.rejectType == rejectType)&&(identical(other.reviewAnswer, reviewAnswer) || other.reviewAnswer == reviewAnswer)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,referenceId,verifiedAt,rejectionReason,rejectionReasonAr,rejectType,reviewAnswer,updatedAt);

@override
String toString() {
  return 'SumsubStatus(status: $status, referenceId: $referenceId, verifiedAt: $verifiedAt, rejectionReason: $rejectionReason, rejectionReasonAr: $rejectionReasonAr, rejectType: $rejectType, reviewAnswer: $reviewAnswer, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SumsubStatusCopyWith<$Res> implements $SumsubStatusCopyWith<$Res> {
  factory _$SumsubStatusCopyWith(_SumsubStatus value, $Res Function(_SumsubStatus) _then) = __$SumsubStatusCopyWithImpl;
@override @useResult
$Res call({
 String? status, String? referenceId, String? verifiedAt, String? rejectionReason,@JsonKey(name: 'rejectionReason_ar') String? rejectionReasonAr, String? rejectType, String? reviewAnswer, String? updatedAt
});




}
/// @nodoc
class __$SumsubStatusCopyWithImpl<$Res>
    implements _$SumsubStatusCopyWith<$Res> {
  __$SumsubStatusCopyWithImpl(this._self, this._then);

  final _SumsubStatus _self;
  final $Res Function(_SumsubStatus) _then;

/// Create a copy of SumsubStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? referenceId = freezed,Object? verifiedAt = freezed,Object? rejectionReason = freezed,Object? rejectionReasonAr = freezed,Object? rejectType = freezed,Object? reviewAnswer = freezed,Object? updatedAt = freezed,}) {
  return _then(_SumsubStatus(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,rejectionReasonAr: freezed == rejectionReasonAr ? _self.rejectionReasonAr : rejectionReasonAr // ignore: cast_nullable_to_non_nullable
as String?,rejectType: freezed == rejectType ? _self.rejectType : rejectType // ignore: cast_nullable_to_non_nullable
as String?,reviewAnswer: freezed == reviewAnswer ? _self.reviewAnswer : reviewAnswer // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BinanceStatus {

 String? get status; String? get referenceId; String? get verifiedAt; String? get rejectionReason;@JsonKey(name: 'rejectionReason_ar') String? get rejectionReasonAr; bool get canStart; bool get canCreateApiKeys; bool get hasApiKeys; String? get updatedAt;
/// Create a copy of BinanceStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BinanceStatusCopyWith<BinanceStatus> get copyWith => _$BinanceStatusCopyWithImpl<BinanceStatus>(this as BinanceStatus, _$identity);

  /// Serializes this BinanceStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BinanceStatus&&(identical(other.status, status) || other.status == status)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.rejectionReasonAr, rejectionReasonAr) || other.rejectionReasonAr == rejectionReasonAr)&&(identical(other.canStart, canStart) || other.canStart == canStart)&&(identical(other.canCreateApiKeys, canCreateApiKeys) || other.canCreateApiKeys == canCreateApiKeys)&&(identical(other.hasApiKeys, hasApiKeys) || other.hasApiKeys == hasApiKeys)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,referenceId,verifiedAt,rejectionReason,rejectionReasonAr,canStart,canCreateApiKeys,hasApiKeys,updatedAt);

@override
String toString() {
  return 'BinanceStatus(status: $status, referenceId: $referenceId, verifiedAt: $verifiedAt, rejectionReason: $rejectionReason, rejectionReasonAr: $rejectionReasonAr, canStart: $canStart, canCreateApiKeys: $canCreateApiKeys, hasApiKeys: $hasApiKeys, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BinanceStatusCopyWith<$Res>  {
  factory $BinanceStatusCopyWith(BinanceStatus value, $Res Function(BinanceStatus) _then) = _$BinanceStatusCopyWithImpl;
@useResult
$Res call({
 String? status, String? referenceId, String? verifiedAt, String? rejectionReason,@JsonKey(name: 'rejectionReason_ar') String? rejectionReasonAr, bool canStart, bool canCreateApiKeys, bool hasApiKeys, String? updatedAt
});




}
/// @nodoc
class _$BinanceStatusCopyWithImpl<$Res>
    implements $BinanceStatusCopyWith<$Res> {
  _$BinanceStatusCopyWithImpl(this._self, this._then);

  final BinanceStatus _self;
  final $Res Function(BinanceStatus) _then;

/// Create a copy of BinanceStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? referenceId = freezed,Object? verifiedAt = freezed,Object? rejectionReason = freezed,Object? rejectionReasonAr = freezed,Object? canStart = null,Object? canCreateApiKeys = null,Object? hasApiKeys = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,rejectionReasonAr: freezed == rejectionReasonAr ? _self.rejectionReasonAr : rejectionReasonAr // ignore: cast_nullable_to_non_nullable
as String?,canStart: null == canStart ? _self.canStart : canStart // ignore: cast_nullable_to_non_nullable
as bool,canCreateApiKeys: null == canCreateApiKeys ? _self.canCreateApiKeys : canCreateApiKeys // ignore: cast_nullable_to_non_nullable
as bool,hasApiKeys: null == hasApiKeys ? _self.hasApiKeys : hasApiKeys // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BinanceStatus].
extension BinanceStatusPatterns on BinanceStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BinanceStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BinanceStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BinanceStatus value)  $default,){
final _that = this;
switch (_that) {
case _BinanceStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BinanceStatus value)?  $default,){
final _that = this;
switch (_that) {
case _BinanceStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? status,  String? referenceId,  String? verifiedAt,  String? rejectionReason, @JsonKey(name: 'rejectionReason_ar')  String? rejectionReasonAr,  bool canStart,  bool canCreateApiKeys,  bool hasApiKeys,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BinanceStatus() when $default != null:
return $default(_that.status,_that.referenceId,_that.verifiedAt,_that.rejectionReason,_that.rejectionReasonAr,_that.canStart,_that.canCreateApiKeys,_that.hasApiKeys,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? status,  String? referenceId,  String? verifiedAt,  String? rejectionReason, @JsonKey(name: 'rejectionReason_ar')  String? rejectionReasonAr,  bool canStart,  bool canCreateApiKeys,  bool hasApiKeys,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BinanceStatus():
return $default(_that.status,_that.referenceId,_that.verifiedAt,_that.rejectionReason,_that.rejectionReasonAr,_that.canStart,_that.canCreateApiKeys,_that.hasApiKeys,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? status,  String? referenceId,  String? verifiedAt,  String? rejectionReason, @JsonKey(name: 'rejectionReason_ar')  String? rejectionReasonAr,  bool canStart,  bool canCreateApiKeys,  bool hasApiKeys,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BinanceStatus() when $default != null:
return $default(_that.status,_that.referenceId,_that.verifiedAt,_that.rejectionReason,_that.rejectionReasonAr,_that.canStart,_that.canCreateApiKeys,_that.hasApiKeys,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BinanceStatus implements BinanceStatus {
  const _BinanceStatus({this.status, this.referenceId, this.verifiedAt, this.rejectionReason, @JsonKey(name: 'rejectionReason_ar') this.rejectionReasonAr, this.canStart = false, this.canCreateApiKeys = false, this.hasApiKeys = false, this.updatedAt});
  factory _BinanceStatus.fromJson(Map<String, dynamic> json) => _$BinanceStatusFromJson(json);

@override final  String? status;
@override final  String? referenceId;
@override final  String? verifiedAt;
@override final  String? rejectionReason;
@override@JsonKey(name: 'rejectionReason_ar') final  String? rejectionReasonAr;
@override@JsonKey() final  bool canStart;
@override@JsonKey() final  bool canCreateApiKeys;
@override@JsonKey() final  bool hasApiKeys;
@override final  String? updatedAt;

/// Create a copy of BinanceStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BinanceStatusCopyWith<_BinanceStatus> get copyWith => __$BinanceStatusCopyWithImpl<_BinanceStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BinanceStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BinanceStatus&&(identical(other.status, status) || other.status == status)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.rejectionReasonAr, rejectionReasonAr) || other.rejectionReasonAr == rejectionReasonAr)&&(identical(other.canStart, canStart) || other.canStart == canStart)&&(identical(other.canCreateApiKeys, canCreateApiKeys) || other.canCreateApiKeys == canCreateApiKeys)&&(identical(other.hasApiKeys, hasApiKeys) || other.hasApiKeys == hasApiKeys)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,referenceId,verifiedAt,rejectionReason,rejectionReasonAr,canStart,canCreateApiKeys,hasApiKeys,updatedAt);

@override
String toString() {
  return 'BinanceStatus(status: $status, referenceId: $referenceId, verifiedAt: $verifiedAt, rejectionReason: $rejectionReason, rejectionReasonAr: $rejectionReasonAr, canStart: $canStart, canCreateApiKeys: $canCreateApiKeys, hasApiKeys: $hasApiKeys, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BinanceStatusCopyWith<$Res> implements $BinanceStatusCopyWith<$Res> {
  factory _$BinanceStatusCopyWith(_BinanceStatus value, $Res Function(_BinanceStatus) _then) = __$BinanceStatusCopyWithImpl;
@override @useResult
$Res call({
 String? status, String? referenceId, String? verifiedAt, String? rejectionReason,@JsonKey(name: 'rejectionReason_ar') String? rejectionReasonAr, bool canStart, bool canCreateApiKeys, bool hasApiKeys, String? updatedAt
});




}
/// @nodoc
class __$BinanceStatusCopyWithImpl<$Res>
    implements _$BinanceStatusCopyWith<$Res> {
  __$BinanceStatusCopyWithImpl(this._self, this._then);

  final _BinanceStatus _self;
  final $Res Function(_BinanceStatus) _then;

/// Create a copy of BinanceStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? referenceId = freezed,Object? verifiedAt = freezed,Object? rejectionReason = freezed,Object? rejectionReasonAr = freezed,Object? canStart = null,Object? canCreateApiKeys = null,Object? hasApiKeys = null,Object? updatedAt = freezed,}) {
  return _then(_BinanceStatus(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,rejectionReasonAr: freezed == rejectionReasonAr ? _self.rejectionReasonAr : rejectionReasonAr // ignore: cast_nullable_to_non_nullable
as String?,canStart: null == canStart ? _self.canStart : canStart // ignore: cast_nullable_to_non_nullable
as bool,canCreateApiKeys: null == canCreateApiKeys ? _self.canCreateApiKeys : canCreateApiKeys // ignore: cast_nullable_to_non_nullable
as bool,hasApiKeys: null == hasApiKeys ? _self.hasApiKeys : hasApiKeys // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
