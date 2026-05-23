// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chunk_infos_bytes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chunkInfosBytes)
final chunkInfosBytesProvider = ChunkInfosBytesFamily._();

final class ChunkInfosBytesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List>,
          Uint8List,
          FutureOr<Uint8List>
        >
    with $FutureModifier<Uint8List>, $FutureProvider<Uint8List> {
  ChunkInfosBytesProvider._({
    required ChunkInfosBytesFamily super.from,
    required (String, ChunkInfos) super.argument,
  }) : super(
         retry: null,
         name: r'chunkInfosBytesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chunkInfosBytesHash();

  @override
  String toString() {
    return r'chunkInfosBytesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List> create(Ref ref) {
    final argument = this.argument as (String, ChunkInfos);
    return chunkInfosBytes(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChunkInfosBytesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chunkInfosBytesHash() => r'9aeeedea3cac316820faac6eda53c38cc40539cc';

final class ChunkInfosBytesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List>, (String, ChunkInfos)> {
  ChunkInfosBytesFamily._()
    : super(
        retry: null,
        name: r'chunkInfosBytesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChunkInfosBytesProvider call(String code, ChunkInfos chunkInfos) =>
      ChunkInfosBytesProvider._(argument: (code, chunkInfos), from: this);

  @override
  String toString() => r'chunkInfosBytesProvider';
}
