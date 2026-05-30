import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loading_state_provider.g.dart';

class LoadingStateProgress {
  final bool isLoading;
  final String message;
  final int value;
  final int max;

  LoadingStateProgress(this.isLoading, this.message, this.value, this.max);

  factory LoadingStateProgress.loading(String message, int max) {
    return LoadingStateProgress(true, message, 0, max);
  }

  factory LoadingStateProgress.empty() {
    return LoadingStateProgress(false, '', 0, 0);
  }
}

@riverpod
class LoadingState extends _$LoadingState {
  @override
  LoadingStateProgress build() {
    return LoadingStateProgress.empty();
  }

  void setLoading(String message, int max) {
    state = LoadingStateProgress.loading(message, max);
  }

  void stopLoading() {
    state = LoadingStateProgress.empty();
  }

  void progress(int value) {
    final currentState = state;
    if (!currentState.isLoading) {
      return;
    }
    state = LoadingStateProgress(
      true,
      currentState.message,
      currentState.value + value,
      currentState.max,
    );
  }
}
