// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chunks_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chunksRepositories)
final chunksRepositoriesProvider = ChunksRepositoriesProvider._();

final class ChunksRepositoriesProvider
    extends
        $FunctionalProvider<
          ChunksRepositories,
          ChunksRepositories,
          ChunksRepositories
        >
    with $Provider<ChunksRepositories> {
  ChunksRepositoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chunksRepositoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chunksRepositoriesHash();

  @$internal
  @override
  $ProviderElement<ChunksRepositories> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChunksRepositories create(Ref ref) {
    return chunksRepositories(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChunksRepositories value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChunksRepositories>(value),
    );
  }
}

String _$chunksRepositoriesHash() =>
    r'b4db0035a5191c4ebe6b882fbcd7bce93ce32be7';
