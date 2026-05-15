import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

@freezed
abstract class Room with _$Room {
  @JsonSerializable(explicitToJson: true)
  const factory Room({
    @JsonKey(name: 'chunks_infos') required List<ChunkInfos> chunkInfos,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}

@freezed
abstract class ChunkInfos with _$ChunkInfos {
  @JsonSerializable(explicitToJson: true)
  const factory ChunkInfos({
    @JsonKey(name: 'file_name') required String filename,
    required List<String> chunks,
  }) = _ChunkInfos;

  factory ChunkInfos.fromJson(Map<String, dynamic> json) =>
      _$ChunkInfosFromJson(json);
}
