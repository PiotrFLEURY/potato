import 'package:flutter/foundation.dart';
import 'package:potato/models/data/room.dart';
import 'package:potato/models/encryption/encryption_service.dart';
import 'package:potato/viewmodels/chunks_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chunk_infos_bytes_provider.g.dart';

@riverpod
Future<Uint8List> chunkInfosBytes(
  Ref ref,
  String code,
  ChunkInfos chunkInfos,
) async {
  final chunksRepository = ref.read(chunksRepositoriesProvider);
  try {
    final chunks = await Future.wait(
      chunkInfos.chunks.map((chunkId) async {
        final encryptedBytes = await chunksRepository.downloadChunk(chunkId);
        return EncryptionService.decryptBytes(code, encryptedBytes);
      }),
    );
    return Uint8List.fromList(chunks.expand((c) => c).toList());
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrintStack(label: 'Download error: $e', stackTrace: stack);
    }
  }
  return Uint8List(0);
}
