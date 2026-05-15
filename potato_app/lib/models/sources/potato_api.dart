import 'dart:typed_data';

import 'package:potato/models/data/room.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart' hide Headers;

part 'potato_api.g.dart';

@RestApi()
abstract class PotatoApi {
  factory PotatoApi(Dio dio, {String baseUrl}) = _PotatoApi;

  @POST('/chunks/{chunkId}')
  @Headers(<String, dynamic>{'Content-Type': 'application/octet-stream'})
  Future<void> uploadChunk(
    @Path('chunkId') String chunkId,
    @Body() Uint8List bytes,
  );

  @GET('/chunks/{chunkId}')
  @Headers(<String, dynamic>{'Accept': 'application/octet-stream'})
  @DioResponseType(ResponseType.bytes)
  Future<Uint8List> downloadChunk(@Path('chunkId') String chunkId);

  @POST('/rooms/{roomId}')
  Future<void> createRoom(@Path('roomId') String roomId);

  @GET('/rooms/{roomId}')
  Future<Room> getRoom(@Path('roomId') String roomId);

  @POST('/rooms/{roomId}/chunks')
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future<void> addChunkToRoom(
    @Path('roomId') String roomId,
    @Body() ChunkInfos chunkInfos,
  );
}
