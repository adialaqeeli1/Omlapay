// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeModel {

 String? get profileImage; String get totalBalance; String get totalBalanceSar; List<TransactionModel> get recentTransactions; int get unreadNotifications;
/// Create a copy of HomeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeModelCopyWith<HomeModel> get copyWith => _$HomeModelCopyWithImpl<HomeModel>(this as HomeModel, _$identity);

  /// Serializes this HomeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeModel&&(identical(other.profileImage, profileImage) || other.profileImage == profileImage)&&(identical(other.totalBalance, totalBalance) || other.totalBalance == totalBalance)&&(identical(other.totalBalanceSar, totalBalanceSar) || other.totalBalanceSar == totalBalanceSar)&&const DeepCollectionEquality().equals(other.recentTransactions, recentTransactions)&&(identical(other.unreadNotifications, unreadNotifications) || other.unreadNotifications == unreadNotifications));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profileImage,totalBalance,totalBalanceSar,const DeepCollectionEquality().hash(recentTransactions),unreadNotifications);

@override
String toString() {
  return 'HomeModel(profileImage: $profileImage, totalBalance: $totalBalance, totalBalanceSar: $totalBalanceSar, recentTransactions: $recentTransactions, unreadNotifications: $unreadNotifications)';
}


}

/// @nodoc
abstract mixin class $HomeModelCopyWith<$Res>  {
  factory $HomeModelCopyWith(HomeModel value, $Res Function(HomeModel) _then) = _$HomeModelCopyWithImpl;
@useResult
$Res call({
 String? profileImage, String totalBalance, String totalBalanceSar, List<TransactionModel> recentTransactions, int unreadNotifications
});




}
/// @nodoc
class _$HomeModelCopyWithImpl<$Res>
    implements $HomeModelCopyWith<$Res> {
  _$HomeModelCopyWithImpl(this._self, this._then);

  final HomeModel _self;
  final $Res Function(HomeModel) _then;

/// Create a copy of HomeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileImage = freezed,Object? totalBalance = null,Object? totalBalanceSar = null,Object? recentTransactions = null,Object? unreadNotifications = null,}) {
  return _then(_self.copyWith(
profileImage: freezed == profileImage ? _self.profileImage : profileImage // ignore: cast_nullable_to_non_nullable
as String?,totalBalance: null == totalBalance ? _self.totalBalance : totalBalance // ignore: cast_nullable_to_non_nullable
as String,totalBalanceSar: null == totalBalanceSar ? _self.totalBalanceSar : totalBalanceSar // ignore: cast_nullable_to_non_nullable
as String,recentTransactions: null == recentTransactions ? _self.recentTransactions : recentTransactions // ignore: cast_nullable_to_non_nullable
as List<TransactionModel>,unreadNotifications: null == unreadNotifications ? _self.unreadNotifications : unreadNotifications // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeModel].
extension HomeModelPatterns on HomeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeModel value)  $default,){
final _that = this;
switch (_that) {
case _HomeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeModel value)?  $default,){
final _that = this;
switch (_that) {
case _HomeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? profileImage,  String totalBalance,  String totalBalanceSar,  List<TransactionModel> recentTransactions,  int unreadNotifications)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeModel() when $default != null:
return $default(_that.profileImage,_that.totalBalance,_that.totalBalanceSar,_that.recentTransactions,_that.unreadNotifications);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? profileImage,  String totalBalance,  String totalBalanceSar,  List<TransactionModel> recentTransactions,  int unreadNotifications)  $default,) {final _that = this;
switch (_that) {
case _HomeModel():
return $default(_that.profileImage,_that.totalBalance,_that.totalBalanceSar,_that.recentTransactions,_that.unreadNotifications);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? profileImage,  String totalBalance,  String totalBalanceSar,  List<TransactionModel> recentTransactions,  int unreadNotifications)?  $default,) {final _that = this;
switch (_that) {
case _HomeModel() when $default != null:
return $default(_that.profileImage,_that.totalBalance,_that.totalBalanceSar,_that.recentTransactions,_that.unreadNotifications);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeModel implements HomeModel {
  const _HomeModel({this.profileImage, this.totalBalance = '0.00', this.totalBalanceSar = '0.00', final  List<TransactionModel> recentTransactions = const [], this.unreadNotifications = 0}): _recentTransactions = recentTransactions;
  factory _HomeModel.fromJson(Map<String, dynamic> json) => _$HomeModelFromJson(json);

@override final  String? profileImage;
@override@JsonKey() final  String totalBalance;
@override@JsonKey() final  String totalBalanceSar;
 final  List<TransactionModel> _recentTransactions;
@override@JsonKey() List<TransactionModel> get recentTransactions {
  if (_recentTransactions is EqualUnmodifiableListView) return _recentTransactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentTransactions);
}

@override@JsonKey() final  int unreadNotifications;

/// Create a copy of HomeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeModelCopyWith<_HomeModel> get copyWith => __$HomeModelCopyWithImpl<_HomeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeModel&&(identical(other.profileImage, profileImage) || other.profileImage == profileImage)&&(identical(other.totalBalance, totalBalance) || other.totalBalance == totalBalance)&&(identical(other.totalBalanceSar, totalBalanceSar) || other.totalBalanceSar == totalBalanceSar)&&const DeepCollectionEquality().equals(other._recentTransactions, _recentTransactions)&&(identical(other.unreadNotifications, unreadNotifications) || other.unreadNotifications == unreadNotifications));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profileImage,totalBalance,totalBalanceSar,const DeepCollectionEquality().hash(_recentTransactions),unreadNotifications);

@override
String toString() {
  return 'HomeModel(profileImage: $profileImage, totalBalance: $totalBalance, totalBalanceSar: $totalBalanceSar, recentTransactions: $recentTransactions, unreadNotifications: $unreadNotifications)';
}


}

/// @nodoc
abstract mixin class _$HomeModelCopyWith<$Res> implements $HomeModelCopyWith<$Res> {
  factory _$HomeModelCopyWith(_HomeModel value, $Res Function(_HomeModel) _then) = __$HomeModelCopyWithImpl;
@override @useResult
$Res call({
 String? profileImage, String totalBalance, String totalBalanceSar, List<TransactionModel> recentTransactions, int unreadNotifications
});




}
/// @nodoc
class __$HomeModelCopyWithImpl<$Res>
    implements _$HomeModelCopyWith<$Res> {
  __$HomeModelCopyWithImpl(this._self, this._then);

  final _HomeModel _self;
  final $Res Function(_HomeModel) _then;

/// Create a copy of HomeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileImage = freezed,Object? totalBalance = null,Object? totalBalanceSar = null,Object? recentTransactions = null,Object? unreadNotifications = null,}) {
  return _then(_HomeModel(
profileImage: freezed == profileImage ? _self.profileImage : profileImage // ignore: cast_nullable_to_non_nullable
as String?,totalBalance: null == totalBalance ? _self.totalBalance : totalBalance // ignore: cast_nullable_to_non_nullable
as String,totalBalanceSar: null == totalBalanceSar ? _self.totalBalanceSar : totalBalanceSar // ignore: cast_nullable_to_non_nullable
as String,recentTransactions: null == recentTransactions ? _self._recentTransactions : recentTransactions // ignore: cast_nullable_to_non_nullable
as List<TransactionModel>,unreadNotifications: null == unreadNotifications ? _self.unreadNotifications : unreadNotifications // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
