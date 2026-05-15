import 'package:potato/models/data/room.dart';
import 'package:potato/models/sources/potato_api.dart';

class RoomsRepository {
  final PotatoApi api;

  RoomsRepository(this.api);

  Future<void> createRoom(String roomId) => api.createRoom(roomId);

  Future<Room> getRoom(String roomId) => api.getRoom(roomId);

  Future<void> addChunkToRoom(String roomId, ChunkInfos chunkInfos) =>
      api.addChunkToRoom(roomId, chunkInfos);
}
