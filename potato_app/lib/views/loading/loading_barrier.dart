import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potato/viewmodels/loading_state_provider.dart';

class LoadingBarrier extends ConsumerWidget {
  const LoadingBarrier({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingState = ref.watch(loadingStateProvider);
    if (!loadingState.isLoading) {
      return child;
    }
    return Scaffold(
      body: Stack(
        children: [
          child,
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      'assets/images/potato_loading.png',
                      width: 256,
                    ),
                  ),
                ),
                Text(
                  loadingState.message,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: LinearProgressIndicator(
                    value: loadingState.max > 0
                        ? loadingState.value / loadingState.max
                        : null,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
