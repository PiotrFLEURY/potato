// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'short_codes_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShortCodeHistory)
final shortCodeHistoryProvider = ShortCodeHistoryProvider._();

final class ShortCodeHistoryProvider
    extends $AsyncNotifierProvider<ShortCodeHistory, List<String>> {
  ShortCodeHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shortCodeHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shortCodeHistoryHash();

  @$internal
  @override
  ShortCodeHistory create() => ShortCodeHistory();
}

String _$shortCodeHistoryHash() => r'1f58a9d39854bc918b2107b069157701cf897b12';

abstract class _$ShortCodeHistory extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
