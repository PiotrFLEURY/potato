// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Room _$RoomFromJson(Map<String, dynamic> json) => _Room(
  chunkInfos: (json['chunks_infos'] as List<dynamic>)
      .map((e) => ChunkInfos.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RoomToJson(_Room instance) => <String, dynamic>{
  'chunks_infos': instance.chunkInfos.map((e) => e.toJson()).toList(),
};

_ChunkInfos _$ChunkInfosFromJson(Map<String, dynamic> json) => _ChunkInfos(
  filename: json['file_name'] as String,
  chunks: (json['chunks'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ChunkInfosToJson(_ChunkInfos instance) =>
    <String, dynamic>{
      'file_name': instance.filename,
      'chunks': instance.chunks,
    };
