import 'package:potato/models/repositories/chunks_repositories.dart';
import 'package:potato/viewmodels/potato_api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chunks_repository_provider.g.dart';

@riverpod
ChunksRepositories chunksRepositories(Ref ref) {
  final potatoApi = ref.watch(potatoApiProvider);
  return ChunksRepositories(potatoApi);
}
