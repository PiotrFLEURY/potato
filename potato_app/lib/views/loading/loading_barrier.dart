import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potato/viewmodels/loading_state_provider.dart';

class LoadingBarrier extends ConsumerWidget {
  const LoadingBarrier({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingStateProvider);
    if (!isLoading) {
      return child;
    }
    return Stack(
      children: [
        child,
        ModalBarrier(dismissible: false, color: Colors.black.withAlpha(200)),
        Column(
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
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ],
    );
  }
}
