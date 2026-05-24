import 'package:potato/models/data/room.dart';
import 'package:potato/viewmodels/rooms_repository_provider.dart';
import 'package:potato/viewmodels/short_codes_history_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'room_provider.g.dart';

@riverpod
Future<Room> room(Ref ref, String roomId) async {
  final roomsRepository = ref.watch(roomsRepositoryProvider);
  final room = await roomsRepository.getRoom(roomId);
  if (room.chunkInfos.isEmpty) {
    ref.read(shortCodeHistoryProvider.notifier).cleanCodeFromHistory(roomId);
  }
  return room;
}
