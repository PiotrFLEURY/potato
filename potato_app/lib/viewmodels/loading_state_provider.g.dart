// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loading_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoadingState)
final loadingStateProvider = LoadingStateProvider._();

final class LoadingStateProvider extends $NotifierProvider<LoadingState, bool> {
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
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$loadingStateHash() => r'7756dc38244f37078ca70af076b56dd51083bbc0';

abstract class _$LoadingState extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
