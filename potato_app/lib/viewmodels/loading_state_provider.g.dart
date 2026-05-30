// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loading_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoadingState)
final loadingStateProvider = LoadingStateProvider._();

final class LoadingStateProvider
    extends $NotifierProvider<LoadingState, LoadingStateProgress> {
  LoadingStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadingStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadingStateHash();

  @$internal
  @override
  LoadingState create() => LoadingState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadingStateProgress value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadingStateProgress>(value),
    );
  }
}

String _$loadingStateHash() => r'cac90594295fddba365a0706fa1c8ad4ec60fd83';

abstract class _$LoadingState extends $Notifier<LoadingStateProgress> {
  LoadingStateProgress build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LoadingStateProgress, LoadingStateProgress>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoadingStateProgress, LoadingStateProgress>,
              LoadingStateProgress,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
