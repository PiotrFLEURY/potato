import 'dart:typed_data';

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
  Future<Uint8List> downloadChunk(@Path('chunkId') String chunkId);
}
