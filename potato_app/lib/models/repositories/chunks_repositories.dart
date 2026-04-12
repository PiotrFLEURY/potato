import 'dart:typed_data';

import 'package:potato/models/sources/potato_api.dart';

class ChunksRepositories {
  ChunksRepositories(this.potatoApi);

  final PotatoApi potatoApi;

  Future<void> uploadChunk(String chunkId, Uint8List bytes) async {
    await potatoApi.uploadChunk(chunkId, bytes);
  }

  Future<Uint8List> downloadChunk(String chunkId) async {
    return await potatoApi.downloadChunk(chunkId);
  }
}
