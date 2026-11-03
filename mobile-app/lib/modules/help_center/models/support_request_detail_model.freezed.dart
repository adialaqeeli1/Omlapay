// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_request_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SupportRequestDetailModel {

 String get id; String get title; String get description; SupportRequestStatus get status; String? get statusColor; String? get ticketId; List<SupportRequestAttachment> get attachments; DateTime get createdAt; DateTime get updatedAt; List<SupportRequestResponse> get responses;
/// Create a copy of SupportRequestDetailModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportRequestDetailModelCopyWith<SupportRequestDetailModel> get copyWith => _$SupportRequestDetailModelCopyWithImpl<SupportRequestDetailModel>(this as SupportRequestDetailModel, _$identity);

  /// Serializes this SupportRequestDetailModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportRequestDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusColor, statusColor) || other.statusColor == statusColor)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.responses, responses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,status,statusColor,ticketId,const DeepCollectionEquality().hash(attachments),createdAt,updatedAt,const DeepCollectionEquality().hash(responses));

@override
String toString() {
  return 'SupportRequestDetailModel(id: $id, title: $title, description: $description, status: $status, statusColor: $statusColor, ticketId: $ticketId, attachments: $attachments, createdAt: $createdAt, updatedAt: $updatedAt, responses: $responses)';
}


}

/// @nodoc
abstract mixin class $SupportRequestDetailModelCopyWith<$Res>  {
  factory $SupportRequestDetailModelCopyWith(SupportRequestDetailModel value, $Res Function(SupportRequestDetailModel) _then) = _$SupportRequestDetailModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, SupportRequestStatus status, String? statusColor, String? ticketId, List<SupportRequestAttachment> attachments, DateTime createdAt, DateTime updatedAt, List<SupportRequestResponse> responses
});




}
/// @nodoc
class _$SupportRequestDetailModelCopyWithImpl<$Res>
    implements $SupportRequestDetailModelCopyWith<$Res> {
  _$SupportRequestDetailModelCopyWithImpl(this._self, this._then);

  final SupportRequestDetailModel _self;
  final $Res Function(SupportRequestDetailModel) _then;

/// Create a copy of SupportRequestDetailModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? status = null,Object? statusColor = freezed,Object? ticketId = freezed,Object? attachments = null,Object? createdAt = null,Object? updatedAt = null,Object? responses = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SupportRequestStatus,statusColor: freezed == statusColor ? _self.statusColor : statusColor // ignore: cast_nullable_to_non_nullable
as String?,ticketId: freezed == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SupportRequestAttachment>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,responses: null == responses ? _self.responses : responses // ignore: cast_nullable_to_non_nullable
as List<SupportRequestResponse>,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportRequestDetailModel].
extension SupportRequestDetailModelPatterns on SupportRequestDetailModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportRequestDetailModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportRequestDetailModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportRequestDetailModel value)  $default,){
final _that = this;
switch (_that) {
case _SupportRequestDetailModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportRequestDetailModel value)?  $default,){
final _that = this;
switch (_that) {
case _SupportRequestDetailModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  SupportRequestStatus status,  String? statusColor,  String? ticketId,  List<SupportRequestAttachment> attachments,  DateTime createdAt,  DateTime updatedAt,  List<SupportRequestResponse> responses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportRequestDetailModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.status,_that.statusColor,_that.ticketId,_that.attachments,_that.createdAt,_that.updatedAt,_that.responses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  SupportRequestStatus status,  String? statusColor,  String? ticketId,  List<SupportRequestAttachment> attachments,  DateTime createdAt,  DateTime updatedAt,  List<SupportRequestResponse> responses)  $default,) {final _that = this;
switch (_that) {
case _SupportRequestDetailModel():
return $default(_that.id,_that.title,_that.description,_that.status,_that.statusColor,_that.ticketId,_that.attachments,_that.createdAt,_that.updatedAt,_that.responses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  SupportRequestStatus status,  String? statusColor,  String? ticketId,  List<SupportRequestAttachment> attachments,  DateTime createdAt,  DateTime updatedAt,  List<SupportRequestResponse> responses)?  $default,) {final _that = this;
switch (_that) {
case _SupportRequestDetailModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.status,_that.statusColor,_that.ticketId,_that.attachments,_that.createdAt,_that.updatedAt,_that.responses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupportRequestDetailModel implements SupportRequestDetailModel {
  const _SupportRequestDetailModel({required this.id, required this.title, this.description = '', this.status = SupportRequestStatus.pending, this.statusColor, this.ticketId, final  List<SupportRequestAttachment> attachments = const [], required this.createdAt, required this.updatedAt, final  List<SupportRequestResponse> responses = const []}): _attachments = attachments,_responses = responses;
  factory _SupportRequestDetailModel.fromJson(Map<String, dynamic> json) => _$SupportRequestDetailModelFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  String description;
@override@JsonKey() final  SupportRequestStatus status;
@override final  String? statusColor;
@override final  String? ticketId;
 final  List<SupportRequestAttachment> _attachments;
@override@JsonKey() List<SupportRequestAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<SupportRequestResponse> _responses;
@override@JsonKey() List<SupportRequestResponse> get responses {
  if (_responses is EqualUnmodifiableListView) return _responses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_responses);
}


/// Create a copy of SupportRequestDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportRequestDetailModelCopyWith<_SupportRequestDetailModel> get copyWith => __$SupportRequestDetailModelCopyWithImpl<_SupportRequestDetailModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupportRequestDetailModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportRequestDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusColor, statusColor) || other.statusColor == statusColor)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._responses, _responses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,status,statusColor,ticketId,const DeepCollectionEquality().hash(_attachments),createdAt,updatedAt,const DeepCollectionEquality().hash(_responses));

@override
String toString() {
  return 'SupportRequestDetailModel(id: $id, title: $title, description: $description, status: $status, statusColor: $statusColor, ticketId: $ticketId, attachments: $attachments, createdAt: $createdAt, updatedAt: $updatedAt, responses: $responses)';
}


}

/// @nodoc
abstract mixin class _$SupportRequestDetailModelCopyWith<$Res> implements $SupportRequestDetailModelCopyWith<$Res> {
  factory _$SupportRequestDetailModelCopyWith(_SupportRequestDetailModel value, $Res Function(_SupportRequestDetailModel) _then) = __$SupportRequestDetailModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, SupportRequestStatus status, String? statusColor, String? ticketId, List<SupportRequestAttachment> attachments, DateTime createdAt, DateTime updatedAt, List<SupportRequestResponse> responses
});




}
/// @nodoc
class __$SupportRequestDetailModelCopyWithImpl<$Res>
    implements _$SupportRequestDetailModelCopyWith<$Res> {
  __$SupportRequestDetailModelCopyWithImpl(this._self, this._then);

  final _SupportRequestDetailModel _self;
  final $Res Function(_SupportRequestDetailModel) _then;

/// Create a copy of SupportRequestDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? status = null,Object? statusColor = freezed,Object? ticketId = freezed,Object? attachments = null,Object? createdAt = null,Object? updatedAt = null,Object? responses = null,}) {
  return _then(_SupportRequestDetailModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SupportRequestStatus,statusColor: freezed == statusColor ? _self.statusColor : statusColor // ignore: cast_nullable_to_non_nullable
as String?,ticketId: freezed == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SupportRequestAttachment>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,responses: null == responses ? _self._responses : responses // ignore: cast_nullable_to_non_nullable
as List<SupportRequestResponse>,
  ));
}


}


/// @nodoc
mixin _$SupportRequestAttachment {

 String get url; String get type;
/// Create a copy of SupportRequestAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportRequestAttachmentCopyWith<SupportRequestAttachment> get copyWith => _$SupportRequestAttachmentCopyWithImpl<SupportRequestAttachment>(this as SupportRequestAttachment, _$identity);

  /// Serializes this SupportRequestAttachment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportRequestAttachment&&(identical(other.url, url) || other.url == url)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,type);

@override
String toString() {
  return 'SupportRequestAttachment(url: $url, type: $type)';
}


}

/// @nodoc
abstract mixin class $SupportRequestAttachmentCopyWith<$Res>  {
  factory $SupportRequestAttachmentCopyWith(SupportRequestAttachment value, $Res Function(SupportRequestAttachment) _then) = _$SupportRequestAttachmentCopyWithImpl;
@useResult
$Res call({
 String url, String type
});




}
/// @nodoc
class _$SupportRequestAttachmentCopyWithImpl<$Res>
    implements $SupportRequestAttachmentCopyWith<$Res> {
  _$SupportRequestAttachmentCopyWithImpl(this._self, this._then);

  final SupportRequestAttachment _self;
  final $Res Function(SupportRequestAttachment) _then;

/// Create a copy of SupportRequestAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? type = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportRequestAttachment].
extension SupportRequestAttachmentPatterns on SupportRequestAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportRequestAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportRequestAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportRequestAttachment value)  $default,){
final _that = this;
switch (_that) {
case _SupportRequestAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportRequestAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _SupportRequestAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportRequestAttachment() when $default != null:
return $default(_that.url,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String type)  $default,) {final _that = this;
switch (_that) {
case _SupportRequestAttachment():
return $default(_that.url,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String type)?  $default,) {final _that = this;
switch (_that) {
case _SupportRequestAttachment() when $default != null:
return $default(_that.url,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupportRequestAttachment implements SupportRequestAttachment {
  const _SupportRequestAttachment({required this.url, this.type = 'document'});
  factory _SupportRequestAttachment.fromJson(Map<String, dynamic> json) => _$SupportRequestAttachmentFromJson(json);

@override final  String url;
@override@JsonKey() final  String type;

/// Create a copy of SupportRequestAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportRequestAttachmentCopyWith<_SupportRequestAttachment> get copyWith => __$SupportRequestAttachmentCopyWithImpl<_SupportRequestAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupportRequestAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportRequestAttachment&&(identical(other.url, url) || other.url == url)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,type);

@override
String toString() {
  return 'SupportRequestAttachment(url: $url, type: $type)';
}


}

/// @nodoc
abstract mixin class _$SupportRequestAttachmentCopyWith<$Res> implements $SupportRequestAttachmentCopyWith<$Res> {
  factory _$SupportRequestAttachmentCopyWith(_SupportRequestAttachment value, $Res Function(_SupportRequestAttachment) _then) = __$SupportRequestAttachmentCopyWithImpl;
@override @useResult
$Res call({
 String url, String type
});




}
/// @nodoc
class __$SupportRequestAttachmentCopyWithImpl<$Res>
    implements _$SupportRequestAttachmentCopyWith<$Res> {
  __$SupportRequestAttachmentCopyWithImpl(this._self, this._then);

  final _SupportRequestAttachment _self;
  final $Res Function(_SupportRequestAttachment) _then;

/// Create a copy of SupportRequestAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? type = null,}) {
  return _then(_SupportRequestAttachment(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SupportRequestResponse {

 String get id; String get message; DateTime get createdAt; bool get isAdminResponse; List<SupportRequestAttachment> get attachments;
/// Create a copy of SupportRequestResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportRequestResponseCopyWith<SupportRequestResponse> get copyWith => _$SupportRequestResponseCopyWithImpl<SupportRequestResponse>(this as SupportRequestResponse, _$identity);

  /// Serializes this SupportRequestResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportRequestResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isAdminResponse, isAdminResponse) || other.isAdminResponse == isAdminResponse)&&const DeepCollectionEquality().equals(other.attachments, attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,createdAt,isAdminResponse,const DeepCollectionEquality().hash(attachments));

@override
String toString() {
  return 'SupportRequestResponse(id: $id, message: $message, createdAt: $createdAt, isAdminResponse: $isAdminResponse, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class $SupportRequestResponseCopyWith<$Res>  {
  factory $SupportRequestResponseCopyWith(SupportRequestResponse value, $Res Function(SupportRequestResponse) _then) = _$SupportRequestResponseCopyWithImpl;
@useResult
$Res call({
 String id, String message, DateTime createdAt, bool isAdminResponse, List<SupportRequestAttachment> attachments
});




}
/// @nodoc
class _$SupportRequestResponseCopyWithImpl<$Res>
    implements $SupportRequestResponseCopyWith<$Res> {
  _$SupportRequestResponseCopyWithImpl(this._self, this._then);

  final SupportRequestResponse _self;
  final $Res Function(SupportRequestResponse) _then;

/// Create a copy of SupportRequestResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? message = null,Object? createdAt = null,Object? isAdminResponse = null,Object? attachments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isAdminResponse: null == isAdminResponse ? _self.isAdminResponse : isAdminResponse // ignore: cast_nullable_to_non_nullable
as bool,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SupportRequestAttachment>,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportRequestResponse].
extension SupportRequestResponsePatterns on SupportRequestResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportRequestResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportRequestResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportRequestResponse value)  $default,){
final _that = this;
switch (_that) {
case _SupportRequestResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportRequestResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SupportRequestResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String message,  DateTime createdAt,  bool isAdminResponse,  List<SupportRequestAttachment> attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportRequestResponse() when $default != null:
return $default(_that.id,_that.message,_that.createdAt,_that.isAdminResponse,_that.attachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String message,  DateTime createdAt,  bool isAdminResponse,  List<SupportRequestAttachment> attachments)  $default,) {final _that = this;
switch (_that) {
case _SupportRequestResponse():
return $default(_that.id,_that.message,_that.createdAt,_that.isAdminResponse,_that.attachments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String message,  DateTime createdAt,  bool isAdminResponse,  List<SupportRequestAttachment> attachments)?  $default,) {final _that = this;
switch (_that) {
case _SupportRequestResponse() when $default != null:
return $default(_that.id,_that.message,_that.createdAt,_that.isAdminResponse,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupportRequestResponse implements SupportRequestResponse {
  const _SupportRequestResponse({required this.id, this.message = '', required this.createdAt, this.isAdminResponse = false, final  List<SupportRequestAttachment> attachments = const []}): _attachments = attachments;
  factory _SupportRequestResponse.fromJson(Map<String, dynamic> json) => _$SupportRequestResponseFromJson(json);

@override final  String id;
@override@JsonKey() final  String message;
@override final  DateTime createdAt;
@override@JsonKey() final  bool isAdminResponse;
 final  List<SupportRequestAttachment> _attachments;
@override@JsonKey() List<SupportRequestAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}


/// Create a copy of SupportRequestResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportRequestResponseCopyWith<_SupportRequestResponse> get copyWith => __$SupportRequestResponseCopyWithImpl<_SupportRequestResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupportRequestResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportRequestResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isAdminResponse, isAdminResponse) || other.isAdminResponse == isAdminResponse)&&const DeepCollectionEquality().equals(other._attachments, _attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,createdAt,isAdminResponse,const DeepCollectionEquality().hash(_attachments));

@override
String toString() {
  return 'SupportRequestResponse(id: $id, message: $message, createdAt: $createdAt, isAdminResponse: $isAdminResponse, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$SupportRequestResponseCopyWith<$Res> implements $SupportRequestResponseCopyWith<$Res> {
  factory _$SupportRequestResponseCopyWith(_SupportRequestResponse value, $Res Function(_SupportRequestResponse) _then) = __$SupportRequestResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String message, DateTime createdAt, bool isAdminResponse, List<SupportRequestAttachment> attachments
});




}
/// @nodoc
class __$SupportRequestResponseCopyWithImpl<$Res>
    implements _$SupportRequestResponseCopyWith<$Res> {
  __$SupportRequestResponseCopyWithImpl(this._self, this._then);

  final _SupportRequestResponse _self;
  final $Res Function(_SupportRequestResponse) _then;

/// Create a copy of SupportRequestResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? message = null,Object? createdAt = null,Object? isAdminResponse = null,Object? attachments = null,}) {
  return _then(_SupportRequestResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isAdminResponse: null == isAdminResponse ? _self.isAdminResponse : isAdminResponse // ignore: cast_nullable_to_non_nullable
as bool,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SupportRequestAttachment>,
  ));
}


}

// dart format on
