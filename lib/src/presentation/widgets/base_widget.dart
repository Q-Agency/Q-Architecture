import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_architecture/q_architecture.dart';

class BaseWidget extends ConsumerWidget {
  final Widget child;
  final Widget? loadingIndicator;
  final Function(Failure failure) onGlobalFailure;
  final Function(GlobalInfo globalInfo) onGlobalInfo;

  const BaseWidget({
    required this.child,
    required this.onGlobalFailure,
    required this.onGlobalInfo,
    this.loadingIndicator,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<Failure?>(globalFailureProvider, (_, failure) {
      if (failure == null) return;
      onGlobalFailure(failure);
    });
    ref.listen<GlobalInfo?>(globalInfoProvider, (_, globalInfo) {
      if (globalInfo == null) return;
      onGlobalInfo(globalInfo);
    });
    final showLoading = ref.watch(globalLoadingProvider);
    return Stack(
      children: [
        child,
        if (showLoading) loadingIndicator ?? const BaseLoadingIndicator(),
      ],
    );
  }
}
