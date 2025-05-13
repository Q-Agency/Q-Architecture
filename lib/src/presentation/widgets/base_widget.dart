// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:q_architecture/q_architecture.dart';

class BaseWidget extends StatelessWidget {
  final Widget child;
  final Widget? loadingIndicator;
  final Function(Failure failure) onGlobalFailure;
  final Function(GlobalInfo globalInfo) onGlobalInfo;

  const BaseWidget({
    super.key,
    required this.child,
    required this.onGlobalFailure,
    required this.onGlobalInfo,
    this.loadingIndicator,
  });

  @override
  Widget build(BuildContext context) {
    GetIt.instance<GlobalFailureNotifier>()
        .listen((currentState, previousState) {
      if (currentState == null) return;
      onGlobalFailure(currentState);
    });
    GetIt.instance<GlobalInfoNotifier>().listen((currentState, previousState) {
      if (currentState == null) return;
      onGlobalInfo(currentState);
    });
    final globalLoadingNotifier = GetIt.instance<GlobalLoadingNotifier>();
    return Stack(
      children: [
        child,
        ValueListenableBuilder(
          valueListenable: globalLoadingNotifier,
          builder: (context, value, child) {
            if (value) {
              return loadingIndicator ?? const BaseLoadingIndicator();
            }
            return SizedBox();
          },
        ),
      ],
    );
  }
}
