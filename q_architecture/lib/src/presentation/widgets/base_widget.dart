import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/q_architecture.dart';

import 'package:q_architecture/src/presentation/widgets/base_loading_indicator.dart';

class BaseWidget extends ConsumerWidget {
  final Widget child;
  final Widget? loadingIndicator;
  final Function(Failure) onFailure;
  final Function(GlobalInfo) onGlobalInfo;

  const BaseWidget({
    required this.child,
    required this.onFailure,
    required this.onGlobalInfo,
    this.loadingIndicator,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<Failure?>(globalFailureProvider, (_, failure) {
      if (failure == null) return;
      onFailure(failure);
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
