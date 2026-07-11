// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SupportRequestsResponse {

 List<SupportRequestModel> get requests; SupportRequestPagination? get pagination;
/// Create a copy of SupportRequestsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportRequestsResponseCopyWith<SupportRequestsResponse> get copyWith => _$SupportRequestsResponseCopyWithImpl<SupportRequestsResponse>(this as SupportRequestsResponse, _$identity);

  /// Serializes this SupportRequestsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportRequestsResponse&&const DeepCollectionEquality().equals(other.requests, requests)&&(identical(other.pagination, pagination) || other.pagination == pagination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(requests),pagination);

@override
String toString() {
  return 'SupportRequestsResponse(requests: $requests, pagination: $pagination)';
}


}

/// @nodoc
abstract mixin class $SupportRequestsResponseCopyWith<$Res>  {
  factory $SupportRequestsResponseCopyWith(SupportRequestsResponse value, $Res Function(SupportRequestsResponse) _then) = _$SupportRequestsResponseCopyWithImpl;
@useResult
$Res call({
 List<SupportRequestModel> requests, SupportRequestPagination? pagination
});


$SupportRequestPaginationCopyWith<$Res>? get pagination;

}
/// @nodoc
class _$SupportRequestsResponseCopyWithImpl<$Res>
    implements $SupportRequestsResponseCopyWith<$Res> {
  _$SupportRequestsResponseCopyWithImpl(this._self, this._then);

  final SupportRequestsResponse _self;
  final $Res Function(SupportRequestsResponse) _then;

/// Create a copy of SupportRequestsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requests = null,Object? pagination = freezed,}) {
  return _then(_self.copyWith(
requests: null == requests ? _self.requests : requests // ignore: cast_nullable_to_non_nullable
as List<SupportRequestModel>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as SupportRequestPagination?,
  ));
}
/// Create a copy of SupportRequestsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportRequestPaginationCopyWith<$Res>? get pagination {
    if (_self.pagination == null) {
    return null;
  }

  return $SupportRequestPaginationCopyWith<$Res>(_self.pagination!, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}


/// Adds pattern-matching-related methods to [SupportRequestsResponse].
extension SupportRequestsResponsePatterns on SupportRequestsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportRequestsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportRequestsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportRequestsResponse value)  $default,){
final _that = this;
switch (_that) {
case _SupportRequestsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportRequestsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SupportRequestsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SupportRequestModel> requests,  SupportRequestPagination? pagination)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportRequestsResponse() when $default != null:
return $default(_that.requests,_that.pagination);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SupportRequestModel> requests,  SupportRequestPagination? pagination)  $default,) {final _that = this;
switch (_that) {
case _SupportRequestsResponse():
return $default(_that.requests,_that.pagination);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SupportRequestModel> requests,  SupportRequestPagination? pagination)?  $default,) {final _that = this;
switch (_that) {
case _SupportRequestsResponse() when $default != null:
return $default(_that.requests,_that.pagination);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupportRequestsResponse implements SupportRequestsResponse {
  const _SupportRequestsResponse({final  List<SupportRequestModel> requests = const [], this.pagination}): _requests = requests;
  factory _SupportRequestsResponse.fromJson(Map<String, dynamic> json) => _$SupportRequestsResponseFromJson(json);

 final  List<SupportRequestModel> _requests;
@override@JsonKey() List<SupportRequestModel> get requests {
  if (_requests is EqualUnmodifiableListView) return _requests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requests);
}

@override final  SupportRequestPagination? pagination;

/// Create a copy of SupportRequestsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportRequestsResponseCopyWith<_SupportRequestsResponse> get copyWith => __$SupportRequestsResponseCopyWithImpl<_SupportRequestsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupportRequestsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportRequestsResponse&&const DeepCollectionEquality().equals(other._requests, _requests)&&(identical(other.pagination, pagination) || other.pagination == pagination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_requests),pagination);

@override
String toString() {
  return 'SupportRequestsResponse(requests: $requests, pagination: $pagination)';
}


}

/// @nodoc
abstract mixin class _$SupportRequestsResponseCopyWith<$Res> implements $SupportRequestsResponseCopyWith<$Res> {
  factory _$SupportRequestsResponseCopyWith(_SupportRequestsResponse value, $Res Function(_SupportRequestsResponse) _then) = __$SupportRequestsResponseCopyWithImpl;
@override @useResult
$Res call({
 List<SupportRequestModel> requests, SupportRequestPagination? pagination
});


@override $SupportRequestPaginationCopyWith<$Res>? get pagination;

}
/// @nodoc
class __$SupportRequestsResponseCopyWithImpl<$Res>
    implements _$SupportRequestsResponseCopyWith<$Res> {
  __$SupportRequestsResponseCopyWithImpl(this._self, this._then);

  final _SupportRequestsResponse _self;
  final $Res Function(_SupportRequestsResponse) _then;

/// Create a copy of SupportRequestsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requests = null,Object? pagination = freezed,}) {
  return _then(_SupportRequestsResponse(
requests: null == requests ? _self._requests : requests // ignore: cast_nullable_to_non_nullable
as List<SupportRequestModel>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as SupportRequestPagination?,
  ));
}

/// Create a copy of SupportRequestsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportRequestPaginationCopyWith<$Res>? get pagination {
    if (_self.pagination == null) {
    return null;
  }

  return $SupportRequestPaginationCopyWith<$Res>(_self.pagination!, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}


/// @nodoc
mixin _$SupportRequestPagination {

 String get page; String get limit; int get total; int get totalPages;
/// Create a copy of SupportRequestPagination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportRequestPaginationCopyWith<SupportRequestPagination> get copyWith => _$SupportRequestPaginationCopyWithImpl<SupportRequestPagination>(this as SupportRequestPagination, _$identity);

  /// Serializes this SupportRequestPagination to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportRequestPagination&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,limit,total,totalPages);

@override
String toString() {
  return 'SupportRequestPagination(page: $page, limit: $limit, total: $total, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class $SupportRequestPaginationCopyWith<$Res>  {
  factory $SupportRequestPaginationCopyWith(SupportRequestPagination value, $Res Function(SupportRequestPagination) _then) = _$SupportRequestPaginationCopyWithImpl;
@useResult
$Res call({
 String page, String limit, int total, int totalPages
});




}
/// @nodoc
class _$SupportRequestPaginationCopyWithImpl<$Res>
    implements $SupportRequestPaginationCopyWith<$Res> {
  _$SupportRequestPaginationCopyWithImpl(this._self, this._then);

  final SupportRequestPagination _self;
  final $Res Function(SupportRequestPagination) _then;

/// Create a copy of SupportRequestPagination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? limit = null,Object? total = null,Object? totalPages = null,}) {
  return _then(_self.copyWith(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportRequestPagination].
extension SupportRequestPaginationPatterns on SupportRequestPagination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportRequestPagination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportRequestPagination() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportRequestPagination value)  $default,){
final _that = this;
switch (_that) {
case _SupportRequestPagination():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportRequestPagination value)?  $default,){
final _that = this;
switch (_that) {
case _SupportRequestPagination() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String page,  String limit,  int total,  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportRequestPagination() when $default != null:
return $default(_that.page,_that.limit,_that.total,_that.totalPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String page,  String limit,  int total,  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _SupportRequestPagination():
return $default(_that.page,_that.limit,_that.total,_that.totalPages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String page,  String limit,  int total,  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _SupportRequestPagination() when $default != null:
return $default(_that.page,_that.limit,_that.total,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupportRequestPagination implements SupportRequestPagination {
  const _SupportRequestPagination({this.page = '1', this.limit = '10', this.total = 0, this.totalPages = 1});
  factory _SupportRequestPagination.fromJson(Map<String, dynamic> json) => _$SupportRequestPaginationFromJson(json);

@override@JsonKey() final  String page;
@override@JsonKey() final  String limit;
@override@JsonKey() final  int total;
@override@JsonKey() final  int totalPages;

/// Create a copy of SupportRequestPagination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportRequestPaginationCopyWith<_SupportRequestPagination> get copyWith => __$SupportRequestPaginationCopyWithImpl<_SupportRequestPagination>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupportRequestPaginationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportRequestPagination&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,limit,total,totalPages);

@override
String toString() {
  return 'SupportRequestPagination(page: $page, limit: $limit, total: $total, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$SupportRequestPaginationCopyWith<$Res> implements $SupportRequestPaginationCopyWith<$Res> {
  factory _$SupportRequestPaginationCopyWith(_SupportRequestPagination value, $Res Function(_SupportRequestPagination) _then) = __$SupportRequestPaginationCopyWithImpl;
@override @useResult
$Res call({
 String page, String limit, int total, int totalPages
});




}
/// @nodoc
class __$SupportRequestPaginationCopyWithImpl<$Res>
    implements _$SupportRequestPaginationCopyWith<$Res> {
  __$SupportRequestPaginationCopyWithImpl(this._self, this._then);

  final _SupportRequestPagination _self;
  final $Res Function(_SupportRequestPagination) _then;

/// Create a copy of SupportRequestPagination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? limit = null,Object? total = null,Object? totalPages = null,}) {
  return _then(_SupportRequestPagination(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SupportRequestModel {

 String get id; String get title; SupportRequestStatus get status; String? get statusColor; DateTime get createdAt;
/// Create a copy of SupportRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportRequestModelCopyWith<SupportRequestModel> get copyWith => _$SupportRequestModelCopyWithImpl<SupportRequestModel>(this as SupportRequestModel, _$identity);

  /// Serializes this SupportRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusColor, statusColor) || other.statusColor == statusColor)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,status,statusColor,createdAt);

@override
String toString() {
  return 'SupportRequestModel(id: $id, title: $title, status: $status, statusColor: $statusColor, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SupportRequestModelCopyWith<$Res>  {
  factory $SupportRequestModelCopyWith(SupportRequestModel value, $Res Function(SupportRequestModel) _then) = _$SupportRequestModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, SupportRequestStatus status, String? statusColor, DateTime createdAt
});




}
/// @nodoc
class _$SupportRequestModelCopyWithImpl<$Res>
    implements $SupportRequestModelCopyWith<$Res> {
  _$SupportRequestModelCopyWithImpl(this._self, this._then);

  final SupportRequestModel _self;
  final $Res Function(SupportRequestModel) _then;

/// Create a copy of SupportRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? status = null,Object? statusColor = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SupportRequestStatus,statusColor: freezed == statusColor ? _self.statusColor : statusColor // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportRequestModel].
extension SupportRequestModelPatterns on SupportRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _SupportRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _SupportRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  SupportRequestStatus status,  String? statusColor,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportRequestModel() when $default != null:
return $default(_that.id,_that.title,_that.status,_that.statusColor,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  SupportRequestStatus status,  String? statusColor,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SupportRequestModel():
return $default(_that.id,_that.title,_that.status,_that.statusColor,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  SupportRequestStatus status,  String? statusColor,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SupportRequestModel() when $default != null:
return $default(_that.id,_that.title,_that.status,_that.statusColor,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupportRequestModel implements SupportRequestModel {
  const _SupportRequestModel({required this.id, required this.title, this.status = SupportRequestStatus.pending, this.statusColor, required this.createdAt});
  factory _SupportRequestModel.fromJson(Map<String, dynamic> json) => _$SupportRequestModelFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  SupportRequestStatus status;
@override final  String? statusColor;
@override final  DateTime createdAt;

/// Create a copy of SupportRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportRequestModelCopyWith<_SupportRequestModel> get copyWith => __$SupportRequestModelCopyWithImpl<_SupportRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupportRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusColor, statusColor) || other.statusColor == statusColor)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,status,statusColor,createdAt);

@override
String toString() {
  return 'SupportRequestModel(id: $id, title: $title, status: $status, statusColor: $statusColor, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SupportRequestModelCopyWith<$Res> implements $SupportRequestModelCopyWith<$Res> {
  factory _$SupportRequestModelCopyWith(_SupportRequestModel value, $Res Function(_SupportRequestModel) _then) = __$SupportRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, SupportRequestStatus status, String? statusColor, DateTime createdAt
});




}
/// @nodoc
class __$SupportRequestModelCopyWithImpl<$Res>
    implements _$SupportRequestModelCopyWith<$Res> {
  __$SupportRequestModelCopyWithImpl(this._self, this._then);

  final _SupportRequestModel _self;
  final $Res Function(_SupportRequestModel) _then;

/// Create a copy of SupportRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? status = null,Object? statusColor = freezed,Object? createdAt = null,}) {
  return _then(_SupportRequestModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SupportRequestStatus,statusColor: freezed == statusColor ? _self.statusColor : statusColor // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
