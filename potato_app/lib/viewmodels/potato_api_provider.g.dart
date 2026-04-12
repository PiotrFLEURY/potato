// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'potato_api_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(potatoApi)
final potatoApiProvider = PotatoApiProvider._();

final class PotatoApiProvider
    extends $FunctionalProvider<PotatoApi, PotatoApi, PotatoApi>
    with $Provider<PotatoApi> {
  PotatoApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'potatoApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$potatoApiHash();

  @$internal
  @override
  $ProviderElement<PotatoApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PotatoApi create(Ref ref) {
    return potatoApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PotatoApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PotatoApi>(value),
    );
  }
}

String _$potatoApiHash() => r'6eddf5068a4a182e724323a74a38116c00402a6d';
