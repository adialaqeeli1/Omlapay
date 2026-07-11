// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kyc_rejection_details_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KycRejectionDetailsResponse {

 bool get canResubmit; String? get rejectedProvider; String? get rejectionReason;@JsonKey(name: 'rejectionReason_ar') String? get rejectionReasonAr; String? get rejectType; KycPreviousData? get previousData; KycDocuments? get documents;
/// Create a copy of KycRejectionDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycRejectionDetailsResponseCopyWith<KycRejectionDetailsResponse> get copyWith => _$KycRejectionDetailsResponseCopyWithImpl<KycRejectionDetailsResponse>(this as KycRejectionDetailsResponse, _$identity);

  /// Serializes this KycRejectionDetailsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycRejectionDetailsResponse&&(identical(other.canResubmit, canResubmit) || other.canResubmit == canResubmit)&&(identical(other.rejectedProvider, rejectedProvider) || other.rejectedProvider == rejectedProvider)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.rejectionReasonAr, rejectionReasonAr) || other.rejectionReasonAr == rejectionReasonAr)&&(identical(other.rejectType, rejectType) || other.rejectType == rejectType)&&(identical(other.previousData, previousData) || other.previousData == previousData)&&(identical(other.documents, documents) || other.documents == documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,canResubmit,rejectedProvider,rejectionReason,rejectionReasonAr,rejectType,previousData,documents);

@override
String toString() {
  return 'KycRejectionDetailsResponse(canResubmit: $canResubmit, rejectedProvider: $rejectedProvider, rejectionReason: $rejectionReason, rejectionReasonAr: $rejectionReasonAr, rejectType: $rejectType, previousData: $previousData, documents: $documents)';
}


}

/// @nodoc
abstract mixin class $KycRejectionDetailsResponseCopyWith<$Res>  {
  factory $KycRejectionDetailsResponseCopyWith(KycRejectionDetailsResponse value, $Res Function(KycRejectionDetailsResponse) _then) = _$KycRejectionDetailsResponseCopyWithImpl;
@useResult
$Res call({
 bool canResubmit, String? rejectedProvider, String? rejectionReason,@JsonKey(name: 'rejectionReason_ar') String? rejectionReasonAr, String? rejectType, KycPreviousData? previousData, KycDocuments? documents
});


$KycPreviousDataCopyWith<$Res>? get previousData;$KycDocumentsCopyWith<$Res>? get documents;

}
/// @nodoc
class _$KycRejectionDetailsResponseCopyWithImpl<$Res>
    implements $KycRejectionDetailsResponseCopyWith<$Res> {
  _$KycRejectionDetailsResponseCopyWithImpl(this._self, this._then);

  final KycRejectionDetailsResponse _self;
  final $Res Function(KycRejectionDetailsResponse) _then;

/// Create a copy of KycRejectionDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? canResubmit = null,Object? rejectedProvider = freezed,Object? rejectionReason = freezed,Object? rejectionReasonAr = freezed,Object? rejectType = freezed,Object? previousData = freezed,Object? documents = freezed,}) {
  return _then(_self.copyWith(
canResubmit: null == canResubmit ? _self.canResubmit : canResubmit // ignore: cast_nullable_to_non_nullable
as bool,rejectedProvider: freezed == rejectedProvider ? _self.rejectedProvider : rejectedProvider // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,rejectionReasonAr: freezed == rejectionReasonAr ? _self.rejectionReasonAr : rejectionReasonAr // ignore: cast_nullable_to_non_nullable
as String?,rejectType: freezed == rejectType ? _self.rejectType : rejectType // ignore: cast_nullable_to_non_nullable
as String?,previousData: freezed == previousData ? _self.previousData : previousData // ignore: cast_nullable_to_non_nullable
as KycPreviousData?,documents: freezed == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as KycDocuments?,
  ));
}
/// Create a copy of KycRejectionDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KycPreviousDataCopyWith<$Res>? get previousData {
    if (_self.previousData == null) {
    return null;
  }

  return $KycPreviousDataCopyWith<$Res>(_self.previousData!, (value) {
    return _then(_self.copyWith(previousData: value));
  });
}/// Create a copy of KycRejectionDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KycDocumentsCopyWith<$Res>? get documents {
    if (_self.documents == null) {
    return null;
  }

  return $KycDocumentsCopyWith<$Res>(_self.documents!, (value) {
    return _then(_self.copyWith(documents: value));
  });
}
}


/// Adds pattern-matching-related methods to [KycRejectionDetailsResponse].
extension KycRejectionDetailsResponsePatterns on KycRejectionDetailsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KycRejectionDetailsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KycRejectionDetailsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KycRejectionDetailsResponse value)  $default,){
final _that = this;
switch (_that) {
case _KycRejectionDetailsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KycRejectionDetailsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _KycRejectionDetailsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool canResubmit,  String? rejectedProvider,  String? rejectionReason, @JsonKey(name: 'rejectionReason_ar')  String? rejectionReasonAr,  String? rejectType,  KycPreviousData? previousData,  KycDocuments? documents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycRejectionDetailsResponse() when $default != null:
return $default(_that.canResubmit,_that.rejectedProvider,_that.rejectionReason,_that.rejectionReasonAr,_that.rejectType,_that.previousData,_that.documents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool canResubmit,  String? rejectedProvider,  String? rejectionReason, @JsonKey(name: 'rejectionReason_ar')  String? rejectionReasonAr,  String? rejectType,  KycPreviousData? previousData,  KycDocuments? documents)  $default,) {final _that = this;
switch (_that) {
case _KycRejectionDetailsResponse():
return $default(_that.canResubmit,_that.rejectedProvider,_that.rejectionReason,_that.rejectionReasonAr,_that.rejectType,_that.previousData,_that.documents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool canResubmit,  String? rejectedProvider,  String? rejectionReason, @JsonKey(name: 'rejectionReason_ar')  String? rejectionReasonAr,  String? rejectType,  KycPreviousData? previousData,  KycDocuments? documents)?  $default,) {final _that = this;
switch (_that) {
case _KycRejectionDetailsResponse() when $default != null:
return $default(_that.canResubmit,_that.rejectedProvider,_that.rejectionReason,_that.rejectionReasonAr,_that.rejectType,_that.previousData,_that.documents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycRejectionDetailsResponse implements KycRejectionDetailsResponse {
  const _KycRejectionDetailsResponse({this.canResubmit = false, this.rejectedProvider, this.rejectionReason, @JsonKey(name: 'rejectionReason_ar') this.rejectionReasonAr, this.rejectType, this.previousData, this.documents});
  factory _KycRejectionDetailsResponse.fromJson(Map<String, dynamic> json) => _$KycRejectionDetailsResponseFromJson(json);

@override@JsonKey() final  bool canResubmit;
@override final  String? rejectedProvider;
@override final  String? rejectionReason;
@override@JsonKey(name: 'rejectionReason_ar') final  String? rejectionReasonAr;
@override final  String? rejectType;
@override final  KycPreviousData? previousData;
@override final  KycDocuments? documents;

/// Create a copy of KycRejectionDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KycRejectionDetailsResponseCopyWith<_KycRejectionDetailsResponse> get copyWith => __$KycRejectionDetailsResponseCopyWithImpl<_KycRejectionDetailsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KycRejectionDetailsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycRejectionDetailsResponse&&(identical(other.canResubmit, canResubmit) || other.canResubmit == canResubmit)&&(identical(other.rejectedProvider, rejectedProvider) || other.rejectedProvider == rejectedProvider)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.rejectionReasonAr, rejectionReasonAr) || other.rejectionReasonAr == rejectionReasonAr)&&(identical(other.rejectType, rejectType) || other.rejectType == rejectType)&&(identical(other.previousData, previousData) || other.previousData == previousData)&&(identical(other.documents, documents) || other.documents == documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,canResubmit,rejectedProvider,rejectionReason,rejectionReasonAr,rejectType,previousData,documents);

@override
String toString() {
  return 'KycRejectionDetailsResponse(canResubmit: $canResubmit, rejectedProvider: $rejectedProvider, rejectionReason: $rejectionReason, rejectionReasonAr: $rejectionReasonAr, rejectType: $rejectType, previousData: $previousData, documents: $documents)';
}


}

/// @nodoc
abstract mixin class _$KycRejectionDetailsResponseCopyWith<$Res> implements $KycRejectionDetailsResponseCopyWith<$Res> {
  factory _$KycRejectionDetailsResponseCopyWith(_KycRejectionDetailsResponse value, $Res Function(_KycRejectionDetailsResponse) _then) = __$KycRejectionDetailsResponseCopyWithImpl;
@override @useResult
$Res call({
 bool canResubmit, String? rejectedProvider, String? rejectionReason,@JsonKey(name: 'rejectionReason_ar') String? rejectionReasonAr, String? rejectType, KycPreviousData? previousData, KycDocuments? documents
});


@override $KycPreviousDataCopyWith<$Res>? get previousData;@override $KycDocumentsCopyWith<$Res>? get documents;

}
/// @nodoc
class __$KycRejectionDetailsResponseCopyWithImpl<$Res>
    implements _$KycRejectionDetailsResponseCopyWith<$Res> {
  __$KycRejectionDetailsResponseCopyWithImpl(this._self, this._then);

  final _KycRejectionDetailsResponse _self;
  final $Res Function(_KycRejectionDetailsResponse) _then;

/// Create a copy of KycRejectionDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? canResubmit = null,Object? rejectedProvider = freezed,Object? rejectionReason = freezed,Object? rejectionReasonAr = freezed,Object? rejectType = freezed,Object? previousData = freezed,Object? documents = freezed,}) {
  return _then(_KycRejectionDetailsResponse(
canResubmit: null == canResubmit ? _self.canResubmit : canResubmit // ignore: cast_nullable_to_non_nullable
as bool,rejectedProvider: freezed == rejectedProvider ? _self.rejectedProvider : rejectedProvider // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,rejectionReasonAr: freezed == rejectionReasonAr ? _self.rejectionReasonAr : rejectionReasonAr // ignore: cast_nullable_to_non_nullable
as String?,rejectType: freezed == rejectType ? _self.rejectType : rejectType // ignore: cast_nullable_to_non_nullable
as String?,previousData: freezed == previousData ? _self.previousData : previousData // ignore: cast_nullable_to_non_nullable
as KycPreviousData?,documents: freezed == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as KycDocuments?,
  ));
}

/// Create a copy of KycRejectionDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KycPreviousDataCopyWith<$Res>? get previousData {
    if (_self.previousData == null) {
    return null;
  }

  return $KycPreviousDataCopyWith<$Res>(_self.previousData!, (value) {
    return _then(_self.copyWith(previousData: value));
  });
}/// Create a copy of KycRejectionDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KycDocumentsCopyWith<$Res>? get documents {
    if (_self.documents == null) {
    return null;
  }

  return $KycDocumentsCopyWith<$Res>(_self.documents!, (value) {
    return _then(_self.copyWith(documents: value));
  });
}
}


/// @nodoc
mixin _$KycPreviousData {

 String? get firstName; String? get lastName; String? get dob; String? get country; String? get nationality; String? get address; String? get city;
/// Create a copy of KycPreviousData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycPreviousDataCopyWith<KycPreviousData> get copyWith => _$KycPreviousDataCopyWithImpl<KycPreviousData>(this as KycPreviousData, _$identity);

  /// Serializes this KycPreviousData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycPreviousData&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.country, country) || other.country == country)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,dob,country,nationality,address,city);

@override
String toString() {
  return 'KycPreviousData(firstName: $firstName, lastName: $lastName, dob: $dob, country: $country, nationality: $nationality, address: $address, city: $city)';
}


}

/// @nodoc
abstract mixin class $KycPreviousDataCopyWith<$Res>  {
  factory $KycPreviousDataCopyWith(KycPreviousData value, $Res Function(KycPreviousData) _then) = _$KycPreviousDataCopyWithImpl;
@useResult
$Res call({
 String? firstName, String? lastName, String? dob, String? country, String? nationality, String? address, String? city
});




}
/// @nodoc
class _$KycPreviousDataCopyWithImpl<$Res>
    implements $KycPreviousDataCopyWith<$Res> {
  _$KycPreviousDataCopyWithImpl(this._self, this._then);

  final KycPreviousData _self;
  final $Res Function(KycPreviousData) _then;

/// Create a copy of KycPreviousData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = freezed,Object? lastName = freezed,Object? dob = freezed,Object? country = freezed,Object? nationality = freezed,Object? address = freezed,Object? city = freezed,}) {
  return _then(_self.copyWith(
firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,nationality: freezed == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [KycPreviousData].
extension KycPreviousDataPatterns on KycPreviousData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KycPreviousData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KycPreviousData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KycPreviousData value)  $default,){
final _that = this;
switch (_that) {
case _KycPreviousData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KycPreviousData value)?  $default,){
final _that = this;
switch (_that) {
case _KycPreviousData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? firstName,  String? lastName,  String? dob,  String? country,  String? nationality,  String? address,  String? city)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycPreviousData() when $default != null:
return $default(_that.firstName,_that.lastName,_that.dob,_that.country,_that.nationality,_that.address,_that.city);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? firstName,  String? lastName,  String? dob,  String? country,  String? nationality,  String? address,  String? city)  $default,) {final _that = this;
switch (_that) {
case _KycPreviousData():
return $default(_that.firstName,_that.lastName,_that.dob,_that.country,_that.nationality,_that.address,_that.city);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? firstName,  String? lastName,  String? dob,  String? country,  String? nationality,  String? address,  String? city)?  $default,) {final _that = this;
switch (_that) {
case _KycPreviousData() when $default != null:
return $default(_that.firstName,_that.lastName,_that.dob,_that.country,_that.nationality,_that.address,_that.city);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycPreviousData implements KycPreviousData {
  const _KycPreviousData({this.firstName, this.lastName, this.dob, this.country, this.nationality, this.address, this.city});
  factory _KycPreviousData.fromJson(Map<String, dynamic> json) => _$KycPreviousDataFromJson(json);

@override final  String? firstName;
@override final  String? lastName;
@override final  String? dob;
@override final  String? country;
@override final  String? nationality;
@override final  String? address;
@override final  String? city;

/// Create a copy of KycPreviousData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KycPreviousDataCopyWith<_KycPreviousData> get copyWith => __$KycPreviousDataCopyWithImpl<_KycPreviousData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KycPreviousDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycPreviousData&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.country, country) || other.country == country)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,dob,country,nationality,address,city);

@override
String toString() {
  return 'KycPreviousData(firstName: $firstName, lastName: $lastName, dob: $dob, country: $country, nationality: $nationality, address: $address, city: $city)';
}


}

/// @nodoc
abstract mixin class _$KycPreviousDataCopyWith<$Res> implements $KycPreviousDataCopyWith<$Res> {
  factory _$KycPreviousDataCopyWith(_KycPreviousData value, $Res Function(_KycPreviousData) _then) = __$KycPreviousDataCopyWithImpl;
@override @useResult
$Res call({
 String? firstName, String? lastName, String? dob, String? country, String? nationality, String? address, String? city
});




}
/// @nodoc
class __$KycPreviousDataCopyWithImpl<$Res>
    implements _$KycPreviousDataCopyWith<$Res> {
  __$KycPreviousDataCopyWithImpl(this._self, this._then);

  final _KycPreviousData _self;
  final $Res Function(_KycPreviousData) _then;

/// Create a copy of KycPreviousData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = freezed,Object? lastName = freezed,Object? dob = freezed,Object? country = freezed,Object? nationality = freezed,Object? address = freezed,Object? city = freezed,}) {
  return _then(_KycPreviousData(
firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,nationality: freezed == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$KycDocuments {

 String? get frontUrl; String? get backUrl; String? get faceUrl;
/// Create a copy of KycDocuments
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycDocumentsCopyWith<KycDocuments> get copyWith => _$KycDocumentsCopyWithImpl<KycDocuments>(this as KycDocuments, _$identity);

  /// Serializes this KycDocuments to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycDocuments&&(identical(other.frontUrl, frontUrl) || other.frontUrl == frontUrl)&&(identical(other.backUrl, backUrl) || other.backUrl == backUrl)&&(identical(other.faceUrl, faceUrl) || other.faceUrl == faceUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,frontUrl,backUrl,faceUrl);

@override
String toString() {
  return 'KycDocuments(frontUrl: $frontUrl, backUrl: $backUrl, faceUrl: $faceUrl)';
}


}

/// @nodoc
abstract mixin class $KycDocumentsCopyWith<$Res>  {
  factory $KycDocumentsCopyWith(KycDocuments value, $Res Function(KycDocuments) _then) = _$KycDocumentsCopyWithImpl;
@useResult
$Res call({
 String? frontUrl, String? backUrl, String? faceUrl
});




}
/// @nodoc
class _$KycDocumentsCopyWithImpl<$Res>
    implements $KycDocumentsCopyWith<$Res> {
  _$KycDocumentsCopyWithImpl(this._self, this._then);

  final KycDocuments _self;
  final $Res Function(KycDocuments) _then;

/// Create a copy of KycDocuments
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? frontUrl = freezed,Object? backUrl = freezed,Object? faceUrl = freezed,}) {
  return _then(_self.copyWith(
frontUrl: freezed == frontUrl ? _self.frontUrl : frontUrl // ignore: cast_nullable_to_non_nullable
as String?,backUrl: freezed == backUrl ? _self.backUrl : backUrl // ignore: cast_nullable_to_non_nullable
as String?,faceUrl: freezed == faceUrl ? _self.faceUrl : faceUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [KycDocuments].
extension KycDocumentsPatterns on KycDocuments {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KycDocuments value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KycDocuments() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KycDocuments value)  $default,){
final _that = this;
switch (_that) {
case _KycDocuments():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KycDocuments value)?  $default,){
final _that = this;
switch (_that) {
case _KycDocuments() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? frontUrl,  String? backUrl,  String? faceUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycDocuments() when $default != null:
return $default(_that.frontUrl,_that.backUrl,_that.faceUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? frontUrl,  String? backUrl,  String? faceUrl)  $default,) {final _that = this;
switch (_that) {
case _KycDocuments():
return $default(_that.frontUrl,_that.backUrl,_that.faceUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? frontUrl,  String? backUrl,  String? faceUrl)?  $default,) {final _that = this;
switch (_that) {
case _KycDocuments() when $default != null:
return $default(_that.frontUrl,_that.backUrl,_that.faceUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycDocuments implements KycDocuments {
  const _KycDocuments({this.frontUrl, this.backUrl, this.faceUrl});
  factory _KycDocuments.fromJson(Map<String, dynamic> json) => _$KycDocumentsFromJson(json);

@override final  String? frontUrl;
@override final  String? backUrl;
@override final  String? faceUrl;

/// Create a copy of KycDocuments
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KycDocumentsCopyWith<_KycDocuments> get copyWith => __$KycDocumentsCopyWithImpl<_KycDocuments>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KycDocumentsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycDocuments&&(identical(other.frontUrl, frontUrl) || other.frontUrl == frontUrl)&&(identical(other.backUrl, backUrl) || other.backUrl == backUrl)&&(identical(other.faceUrl, faceUrl) || other.faceUrl == faceUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,frontUrl,backUrl,faceUrl);

@override
String toString() {
  return 'KycDocuments(frontUrl: $frontUrl, backUrl: $backUrl, faceUrl: $faceUrl)';
}


}

/// @nodoc
abstract mixin class _$KycDocumentsCopyWith<$Res> implements $KycDocumentsCopyWith<$Res> {
  factory _$KycDocumentsCopyWith(_KycDocuments value, $Res Function(_KycDocuments) _then) = __$KycDocumentsCopyWithImpl;
@override @useResult
$Res call({
 String? frontUrl, String? backUrl, String? faceUrl
});




}
/// @nodoc
class __$KycDocumentsCopyWithImpl<$Res>
    implements _$KycDocumentsCopyWith<$Res> {
  __$KycDocumentsCopyWithImpl(this._self, this._then);

  final _KycDocuments _self;
  final $Res Function(_KycDocuments) _then;

/// Create a copy of KycDocuments
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? frontUrl = freezed,Object? backUrl = freezed,Object? faceUrl = freezed,}) {
  return _then(_KycDocuments(
frontUrl: freezed == frontUrl ? _self.frontUrl : frontUrl // ignore: cast_nullable_to_non_nullable
as String?,backUrl: freezed == backUrl ? _self.backUrl : backUrl // ignore: cast_nullable_to_non_nullable
as String?,faceUrl: freezed == faceUrl ? _self.faceUrl : faceUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
