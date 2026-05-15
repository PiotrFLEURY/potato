// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Room {

@JsonKey(name: 'chunks_infos') List<ChunkInfos> get chunkInfos;
/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomCopyWith<Room> get copyWith => _$RoomCopyWithImpl<Room>(this as Room, _$identity);

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Room&&const DeepCollectionEquality().equals(other.chunkInfos, chunkInfos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(chunkInfos));

@override
String toString() {
  return 'Room(chunkInfos: $chunkInfos)';
}


}

/// @nodoc
abstract mixin class $RoomCopyWith<$Res>  {
  factory $RoomCopyWith(Room value, $Res Function(Room) _then) = _$RoomCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'chunks_infos') List<ChunkInfos> chunkInfos
});




}
/// @nodoc
class _$RoomCopyWithImpl<$Res>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._self, this._then);

  final Room _self;
  final $Res Function(Room) _then;

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chunkInfos = null,}) {
  return _then(_self.copyWith(
chunkInfos: null == chunkInfos ? _self.chunkInfos : chunkInfos // ignore: cast_nullable_to_non_nullable
as List<ChunkInfos>,
  ));
}

}


/// Adds pattern-matching-related methods to [Room].
extension RoomPatterns on Room {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Room value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Room() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Room value)  $default,){
final _that = this;
switch (_that) {
case _Room():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Room value)?  $default,){
final _that = this;
switch (_that) {
case _Room() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'chunks_infos')  List<ChunkInfos> chunkInfos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Room() when $default != null:
return $default(_that.chunkInfos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'chunks_infos')  List<ChunkInfos> chunkInfos)  $default,) {final _that = this;
switch (_that) {
case _Room():
return $default(_that.chunkInfos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'chunks_infos')  List<ChunkInfos> chunkInfos)?  $default,) {final _that = this;
switch (_that) {
case _Room() when $default != null:
return $default(_that.chunkInfos);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Room implements Room {
  const _Room({@JsonKey(name: 'chunks_infos') required final  List<ChunkInfos> chunkInfos}): _chunkInfos = chunkInfos;
  factory _Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

 final  List<ChunkInfos> _chunkInfos;
@override@JsonKey(name: 'chunks_infos') List<ChunkInfos> get chunkInfos {
  if (_chunkInfos is EqualUnmodifiableListView) return _chunkInfos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chunkInfos);
}


/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomCopyWith<_Room> get copyWith => __$RoomCopyWithImpl<_Room>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoomToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Room&&const DeepCollectionEquality().equals(other._chunkInfos, _chunkInfos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_chunkInfos));

@override
String toString() {
  return 'Room(chunkInfos: $chunkInfos)';
}


}

/// @nodoc
abstract mixin class _$RoomCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$RoomCopyWith(_Room value, $Res Function(_Room) _then) = __$RoomCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'chunks_infos') List<ChunkInfos> chunkInfos
});




}
/// @nodoc
class __$RoomCopyWithImpl<$Res>
    implements _$RoomCopyWith<$Res> {
  __$RoomCopyWithImpl(this._self, this._then);

  final _Room _self;
  final $Res Function(_Room) _then;

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chunkInfos = null,}) {
  return _then(_Room(
chunkInfos: null == chunkInfos ? _self._chunkInfos : chunkInfos // ignore: cast_nullable_to_non_nullable
as List<ChunkInfos>,
  ));
}


}


/// @nodoc
mixin _$ChunkInfos {

@JsonKey(name: 'file_name') String get filename; List<String> get chunks;
/// Create a copy of ChunkInfos
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChunkInfosCopyWith<ChunkInfos> get copyWith => _$ChunkInfosCopyWithImpl<ChunkInfos>(this as ChunkInfos, _$identity);

  /// Serializes this ChunkInfos to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChunkInfos&&(identical(other.filename, filename) || other.filename == filename)&&const DeepCollectionEquality().equals(other.chunks, chunks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,filename,const DeepCollectionEquality().hash(chunks));

@override
String toString() {
  return 'ChunkInfos(filename: $filename, chunks: $chunks)';
}


}

/// @nodoc
abstract mixin class $ChunkInfosCopyWith<$Res>  {
  factory $ChunkInfosCopyWith(ChunkInfos value, $Res Function(ChunkInfos) _then) = _$ChunkInfosCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'file_name') String filename, List<String> chunks
});




}
/// @nodoc
class _$ChunkInfosCopyWithImpl<$Res>
    implements $ChunkInfosCopyWith<$Res> {
  _$ChunkInfosCopyWithImpl(this._self, this._then);

  final ChunkInfos _self;
  final $Res Function(ChunkInfos) _then;

/// Create a copy of ChunkInfos
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filename = null,Object? chunks = null,}) {
  return _then(_self.copyWith(
filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,chunks: null == chunks ? _self.chunks : chunks // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChunkInfos].
extension ChunkInfosPatterns on ChunkInfos {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChunkInfos value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChunkInfos() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChunkInfos value)  $default,){
final _that = this;
switch (_that) {
case _ChunkInfos():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChunkInfos value)?  $default,){
final _that = this;
switch (_that) {
case _ChunkInfos() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'file_name')  String filename,  List<String> chunks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChunkInfos() when $default != null:
return $default(_that.filename,_that.chunks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'file_name')  String filename,  List<String> chunks)  $default,) {final _that = this;
switch (_that) {
case _ChunkInfos():
return $default(_that.filename,_that.chunks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'file_name')  String filename,  List<String> chunks)?  $default,) {final _that = this;
switch (_that) {
case _ChunkInfos() when $default != null:
return $default(_that.filename,_that.chunks);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ChunkInfos implements ChunkInfos {
  const _ChunkInfos({@JsonKey(name: 'file_name') required this.filename, required final  List<String> chunks}): _chunks = chunks;
  factory _ChunkInfos.fromJson(Map<String, dynamic> json) => _$ChunkInfosFromJson(json);

@override@JsonKey(name: 'file_name') final  String filename;
 final  List<String> _chunks;
@override List<String> get chunks {
  if (_chunks is EqualUnmodifiableListView) return _chunks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chunks);
}


/// Create a copy of ChunkInfos
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChunkInfosCopyWith<_ChunkInfos> get copyWith => __$ChunkInfosCopyWithImpl<_ChunkInfos>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChunkInfosToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChunkInfos&&(identical(other.filename, filename) || other.filename == filename)&&const DeepCollectionEquality().equals(other._chunks, _chunks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,filename,const DeepCollectionEquality().hash(_chunks));

@override
String toString() {
  return 'ChunkInfos(filename: $filename, chunks: $chunks)';
}


}

/// @nodoc
abstract mixin class _$ChunkInfosCopyWith<$Res> implements $ChunkInfosCopyWith<$Res> {
  factory _$ChunkInfosCopyWith(_ChunkInfos value, $Res Function(_ChunkInfos) _then) = __$ChunkInfosCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'file_name') String filename, List<String> chunks
});




}
/// @nodoc
class __$ChunkInfosCopyWithImpl<$Res>
    implements _$ChunkInfosCopyWith<$Res> {
  __$ChunkInfosCopyWithImpl(this._self, this._then);

  final _ChunkInfos _self;
  final $Res Function(_ChunkInfos) _then;

/// Create a copy of ChunkInfos
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filename = null,Object? chunks = null,}) {
  return _then(_ChunkInfos(
filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,chunks: null == chunks ? _self._chunks : chunks // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
