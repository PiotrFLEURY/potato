import 'package:potato/models/data/room.dart';
import 'package:potato/viewmodels/rooms_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'room_provider.g.dart';

@riverpod
Future<Room> room(Ref ref, String roomId) {
  final roomsRepository = ref.watch(roomsRepositoryProvider);
  return roomsRepository.getRoom(roomId);
}
