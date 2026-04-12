import 'package:dio/dio.dart';
import 'package:potato/models/sources/potato_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'potato_api_provider.g.dart';

@riverpod
PotatoApi potatoApi(Ref ref) {
  const backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:8080',
  );
  final dio = Dio(BaseOptions(baseUrl: backendUrl));
  return PotatoApi(dio);
}
