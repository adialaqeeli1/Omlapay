// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationsResponse {

 int get unreadCount; List<NotificationModel> get notifications; PaginationInfo? get pagination;
/// Create a copy of NotificationsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationsResponseCopyWith<NotificationsResponse> get copyWith => _$NotificationsResponseCopyWithImpl<NotificationsResponse>(this as NotificationsResponse, _$identity);

  /// Serializes this NotificationsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationsResponse&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&const DeepCollectionEquality().equals(other.notifications, notifications)&&(identical(other.pagination, pagination) || other.pagination == pagination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unreadCount,const DeepCollectionEquality().hash(notifications),pagination);

@override
String toString() {
  return 'NotificationsResponse(unreadCount: $unreadCount, notifications: $notifications, pagination: $pagination)';
}


}

/// @nodoc
abstract mixin class $NotificationsResponseCopyWith<$Res>  {
  factory $NotificationsResponseCopyWith(NotificationsResponse value, $Res Function(NotificationsResponse) _then) = _$NotificationsResponseCopyWithImpl;
@useResult
$Res call({
 int unreadCount, List<NotificationModel> notifications, PaginationInfo? pagination
});


$PaginationInfoCopyWith<$Res>? get pagination;

}
/// @nodoc
class _$NotificationsResponseCopyWithImpl<$Res>
    implements $NotificationsResponseCopyWith<$Res> {
  _$NotificationsResponseCopyWithImpl(this._self, this._then);

  final NotificationsResponse _self;
  final $Res Function(NotificationsResponse) _then;

/// Create a copy of NotificationsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unreadCount = null,Object? notifications = null,Object? pagination = freezed,}) {
  return _then(_self.copyWith(
unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<NotificationModel>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationInfo?,
  ));
}
/// Create a copy of NotificationsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationInfoCopyWith<$Res>? get pagination {
    if (_self.pagination == null) {
    return null;
  }

  return $PaginationInfoCopyWith<$Res>(_self.pagination!, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}


/// Adds pattern-matching-related methods to [NotificationsResponse].
extension NotificationsResponsePatterns on NotificationsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationsResponse value)  $default,){
final _that = this;
switch (_that) {
case _NotificationsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int unreadCount,  List<NotificationModel> notifications,  PaginationInfo? pagination)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationsResponse() when $default != null:
return $default(_that.unreadCount,_that.notifications,_that.pagination);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int unreadCount,  List<NotificationModel> notifications,  PaginationInfo? pagination)  $default,) {final _that = this;
switch (_that) {
case _NotificationsResponse():
return $default(_that.unreadCount,_that.notifications,_that.pagination);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int unreadCount,  List<NotificationModel> notifications,  PaginationInfo? pagination)?  $default,) {final _that = this;
switch (_that) {
case _NotificationsResponse() when $default != null:
return $default(_that.unreadCount,_that.notifications,_that.pagination);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationsResponse implements NotificationsResponse {
  const _NotificationsResponse({this.unreadCount = 0, final  List<NotificationModel> notifications = const [], this.pagination}): _notifications = notifications;
  factory _NotificationsResponse.fromJson(Map<String, dynamic> json) => _$NotificationsResponseFromJson(json);

@override@JsonKey() final  int unreadCount;
 final  List<NotificationModel> _notifications;
@override@JsonKey() List<NotificationModel> get notifications {
  if (_notifications is EqualUnmodifiableListView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifications);
}

@override final  PaginationInfo? pagination;

/// Create a copy of NotificationsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationsResponseCopyWith<_NotificationsResponse> get copyWith => __$NotificationsResponseCopyWithImpl<_NotificationsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationsResponse&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&const DeepCollectionEquality().equals(other._notifications, _notifications)&&(identical(other.pagination, pagination) || other.pagination == pagination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unreadCount,const DeepCollectionEquality().hash(_notifications),pagination);

@override
String toString() {
  return 'NotificationsResponse(unreadCount: $unreadCount, notifications: $notifications, pagination: $pagination)';
}


}

/// @nodoc
abstract mixin class _$NotificationsResponseCopyWith<$Res> implements $NotificationsResponseCopyWith<$Res> {
  factory _$NotificationsResponseCopyWith(_NotificationsResponse value, $Res Function(_NotificationsResponse) _then) = __$NotificationsResponseCopyWithImpl;
@override @useResult
$Res call({
 int unreadCount, List<NotificationModel> notifications, PaginationInfo? pagination
});


@override $PaginationInfoCopyWith<$Res>? get pagination;

}
/// @nodoc
class __$NotificationsResponseCopyWithImpl<$Res>
    implements _$NotificationsResponseCopyWith<$Res> {
  __$NotificationsResponseCopyWithImpl(this._self, this._then);

  final _NotificationsResponse _self;
  final $Res Function(_NotificationsResponse) _then;

/// Create a copy of NotificationsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unreadCount = null,Object? notifications = null,Object? pagination = freezed,}) {
  return _then(_NotificationsResponse(
unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,notifications: null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<NotificationModel>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationInfo?,
  ));
}

/// Create a copy of NotificationsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationInfoCopyWith<$Res>? get pagination {
    if (_self.pagination == null) {
    return null;
  }

  return $PaginationInfoCopyWith<$Res>(_self.pagination!, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}


/// @nodoc
mixin _$PaginationInfo {

 String? get nextCursor; bool get hasMore; String get limit;
/// Create a copy of PaginationInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginationInfoCopyWith<PaginationInfo> get copyWith => _$PaginationInfoCopyWithImpl<PaginationInfo>(this as PaginationInfo, _$identity);

  /// Serializes this PaginationInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginationInfo&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nextCursor,hasMore,limit);

@override
String toString() {
  return 'PaginationInfo(nextCursor: $nextCursor, hasMore: $hasMore, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $PaginationInfoCopyWith<$Res>  {
  factory $PaginationInfoCopyWith(PaginationInfo value, $Res Function(PaginationInfo) _then) = _$PaginationInfoCopyWithImpl;
@useResult
$Res call({
 String? nextCursor, bool hasMore, String limit
});




}
/// @nodoc
class _$PaginationInfoCopyWithImpl<$Res>
    implements $PaginationInfoCopyWith<$Res> {
  _$PaginationInfoCopyWithImpl(this._self, this._then);

  final PaginationInfo _self;
  final $Res Function(PaginationInfo) _then;

/// Create a copy of PaginationInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nextCursor = freezed,Object? hasMore = null,Object? limit = null,}) {
  return _then(_self.copyWith(
nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginationInfo].
extension PaginationInfoPatterns on PaginationInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginationInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginationInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginationInfo value)  $default,){
final _that = this;
switch (_that) {
case _PaginationInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginationInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PaginationInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? nextCursor,  bool hasMore,  String limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginationInfo() when $default != null:
return $default(_that.nextCursor,_that.hasMore,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? nextCursor,  bool hasMore,  String limit)  $default,) {final _that = this;
switch (_that) {
case _PaginationInfo():
return $default(_that.nextCursor,_that.hasMore,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? nextCursor,  bool hasMore,  String limit)?  $default,) {final _that = this;
switch (_that) {
case _PaginationInfo() when $default != null:
return $default(_that.nextCursor,_that.hasMore,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginationInfo implements PaginationInfo {
  const _PaginationInfo({this.nextCursor, this.hasMore = false, this.limit = '20'});
  factory _PaginationInfo.fromJson(Map<String, dynamic> json) => _$PaginationInfoFromJson(json);

@override final  String? nextCursor;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  String limit;

/// Create a copy of PaginationInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginationInfoCopyWith<_PaginationInfo> get copyWith => __$PaginationInfoCopyWithImpl<_PaginationInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginationInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginationInfo&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nextCursor,hasMore,limit);

@override
String toString() {
  return 'PaginationInfo(nextCursor: $nextCursor, hasMore: $hasMore, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$PaginationInfoCopyWith<$Res> implements $PaginationInfoCopyWith<$Res> {
  factory _$PaginationInfoCopyWith(_PaginationInfo value, $Res Function(_PaginationInfo) _then) = __$PaginationInfoCopyWithImpl;
@override @useResult
$Res call({
 String? nextCursor, bool hasMore, String limit
});




}
/// @nodoc
class __$PaginationInfoCopyWithImpl<$Res>
    implements _$PaginationInfoCopyWith<$Res> {
  __$PaginationInfoCopyWithImpl(this._self, this._then);

  final _PaginationInfo _self;
  final $Res Function(_PaginationInfo) _then;

/// Create a copy of PaginationInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nextCursor = freezed,Object? hasMore = null,Object? limit = null,}) {
  return _then(_PaginationInfo(
nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$NotificationModel {

 String get id; String get title;@JsonKey(name: 'title_ar') String? get titleAr; String get message;@JsonKey(name: 'message_ar') String? get messageAr; NotificationType get type; bool get isRead; DateTime get createdAt; String? get referenceId; String? get referenceType;
/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationModelCopyWith<NotificationModel> get copyWith => _$NotificationModelCopyWithImpl<NotificationModel>(this as NotificationModel, _$identity);

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.titleAr, titleAr) || other.titleAr == titleAr)&&(identical(other.message, message) || other.message == message)&&(identical(other.messageAr, messageAr) || other.messageAr == messageAr)&&(identical(other.type, type) || other.type == type)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.referenceType, referenceType) || other.referenceType == referenceType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,titleAr,message,messageAr,type,isRead,createdAt,referenceId,referenceType);

@override
String toString() {
  return 'NotificationModel(id: $id, title: $title, titleAr: $titleAr, message: $message, messageAr: $messageAr, type: $type, isRead: $isRead, createdAt: $createdAt, referenceId: $referenceId, referenceType: $referenceType)';
}


}

/// @nodoc
abstract mixin class $NotificationModelCopyWith<$Res>  {
  factory $NotificationModelCopyWith(NotificationModel value, $Res Function(NotificationModel) _then) = _$NotificationModelCopyWithImpl;
@useResult
$Res call({
 String id, String title,@JsonKey(name: 'title_ar') String? titleAr, String message,@JsonKey(name: 'message_ar') String? messageAr, NotificationType type, bool isRead, DateTime createdAt, String? referenceId, String? referenceType
});




}
/// @nodoc
class _$NotificationModelCopyWithImpl<$Res>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._self, this._then);

  final NotificationModel _self;
  final $Res Function(NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? titleAr = freezed,Object? message = null,Object? messageAr = freezed,Object? type = null,Object? isRead = null,Object? createdAt = null,Object? referenceId = freezed,Object? referenceType = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,titleAr: freezed == titleAr ? _self.titleAr : titleAr // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,messageAr: freezed == messageAr ? _self.messageAr : messageAr // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,referenceType: freezed == referenceType ? _self.referenceType : referenceType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationModel].
extension NotificationModelPatterns on NotificationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'title_ar')  String? titleAr,  String message, @JsonKey(name: 'message_ar')  String? messageAr,  NotificationType type,  bool isRead,  DateTime createdAt,  String? referenceId,  String? referenceType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.title,_that.titleAr,_that.message,_that.messageAr,_that.type,_that.isRead,_that.createdAt,_that.referenceId,_that.referenceType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'title_ar')  String? titleAr,  String message, @JsonKey(name: 'message_ar')  String? messageAr,  NotificationType type,  bool isRead,  DateTime createdAt,  String? referenceId,  String? referenceType)  $default,) {final _that = this;
switch (_that) {
case _NotificationModel():
return $default(_that.id,_that.title,_that.titleAr,_that.message,_that.messageAr,_that.type,_that.isRead,_that.createdAt,_that.referenceId,_that.referenceType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @JsonKey(name: 'title_ar')  String? titleAr,  String message, @JsonKey(name: 'message_ar')  String? messageAr,  NotificationType type,  bool isRead,  DateTime createdAt,  String? referenceId,  String? referenceType)?  $default,) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.title,_that.titleAr,_that.message,_that.messageAr,_that.type,_that.isRead,_that.createdAt,_that.referenceId,_that.referenceType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationModel implements NotificationModel {
  const _NotificationModel({required this.id, required this.title, @JsonKey(name: 'title_ar') this.titleAr, required this.message, @JsonKey(name: 'message_ar') this.messageAr, this.type = NotificationType.system, this.isRead = false, required this.createdAt, this.referenceId, this.referenceType});
  factory _NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey(name: 'title_ar') final  String? titleAr;
@override final  String message;
@override@JsonKey(name: 'message_ar') final  String? messageAr;
@override@JsonKey() final  NotificationType type;
@override@JsonKey() final  bool isRead;
@override final  DateTime createdAt;
@override final  String? referenceId;
@override final  String? referenceType;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationModelCopyWith<_NotificationModel> get copyWith => __$NotificationModelCopyWithImpl<_NotificationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.titleAr, titleAr) || other.titleAr == titleAr)&&(identical(other.message, message) || other.message == message)&&(identical(other.messageAr, messageAr) || other.messageAr == messageAr)&&(identical(other.type, type) || other.type == type)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.referenceType, referenceType) || other.referenceType == referenceType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,titleAr,message,messageAr,type,isRead,createdAt,referenceId,referenceType);

@override
String toString() {
  return 'NotificationModel(id: $id, title: $title, titleAr: $titleAr, message: $message, messageAr: $messageAr, type: $type, isRead: $isRead, createdAt: $createdAt, referenceId: $referenceId, referenceType: $referenceType)';
}


}

/// @nodoc
abstract mixin class _$NotificationModelCopyWith<$Res> implements $NotificationModelCopyWith<$Res> {
  factory _$NotificationModelCopyWith(_NotificationModel value, $Res Function(_NotificationModel) _then) = __$NotificationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@JsonKey(name: 'title_ar') String? titleAr, String message,@JsonKey(name: 'message_ar') String? messageAr, NotificationType type, bool isRead, DateTime createdAt, String? referenceId, String? referenceType
});




}
/// @nodoc
class __$NotificationModelCopyWithImpl<$Res>
    implements _$NotificationModelCopyWith<$Res> {
  __$NotificationModelCopyWithImpl(this._self, this._then);

  final _NotificationModel _self;
  final $Res Function(_NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? titleAr = freezed,Object? message = null,Object? messageAr = freezed,Object? type = null,Object? isRead = null,Object? createdAt = null,Object? referenceId = freezed,Object? referenceType = freezed,}) {
  return _then(_NotificationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,titleAr: freezed == titleAr ? _self.titleAr : titleAr // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,messageAr: freezed == messageAr ? _self.messageAr : messageAr // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,referenceType: freezed == referenceType ? _self.referenceType : referenceType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
