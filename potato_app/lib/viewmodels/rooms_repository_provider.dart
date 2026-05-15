import 'package:potato/models/repositories/rooms_repositories.dart';
import 'package:potato/viewmodels/potato_api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rooms_repository_provider.g.dart';

@riverpod
RoomsRepository roomsRepository(Ref ref) {
  final potatoApi = ref.watch(potatoApiProvider);
  return RoomsRepository(potatoApi);
}
