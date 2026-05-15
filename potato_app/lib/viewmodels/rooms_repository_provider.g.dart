// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rooms_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(roomsRepository)
final roomsRepositoryProvider = RoomsRepositoryProvider._();

final class RoomsRepositoryProvider
    extends
        $FunctionalProvider<RoomsRepository, RoomsRepository, RoomsRepository>
    with $Provider<RoomsRepository> {
  RoomsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomsRepositoryHash();

  @$internal
  @override
  $ProviderElement<RoomsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RoomsRepository create(Ref ref) {
    return roomsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoomsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoomsRepository>(value),
    );
  }
}

String _$roomsRepositoryHash() => r'5fa0ba2864caf53ff3a9ce518ab83e445d2a00ac';
