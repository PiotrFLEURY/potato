import 'package:potato/models/data/room.dart';
import 'package:potato/models/encryption/encryption_service.dart';
import 'package:potato/models/sources/potato_api.dart';

class RoomsRepository {
  final PotatoApi api;

  RoomsRepository(this.api);

  Future<void> createRoom(String roomId) async {
    final hashedRoomId = await EncryptionService.hashRoomCode(roomId);
    return api.createRoom(hashedRoomId);
  }

  Future<Room> getRoom(String roomId) async {
    final hashedRoomId = await EncryptionService.hashRoomCode(roomId);
    return api.getRoom(hashedRoomId);
  }

  Future<void> addChunkToRoom(String roomId, ChunkInfos chunkInfos) async {
    final hashedRoomId = await EncryptionService.hashRoomCode(roomId);
    return api.addChunkToRoom(hashedRoomId, chunkInfos);
  }
}
