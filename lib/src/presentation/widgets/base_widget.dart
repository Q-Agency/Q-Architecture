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
    return SimpleNotifierListener(
      simpleNotifier: GetIt.instance<GlobalFailureNotifier>(),
      onChange: (currentState, previousState) {
        if (currentState == null) return;
        onGlobalFailure(currentState);
      },
      child: SimpleNotifierListener(
        simpleNotifier: GetIt.instance<GlobalInfoNotifier>(),
        onChange: (currentState, previousState) {
          if (currentState == null) return;
          onGlobalInfo(currentState);
        },
        child: Stack(
          children: [
            child,
            ValueListenableBuilder(
              valueListenable: GetIt.instance<GlobalLoadingNotifier>(),
              builder: (context, value, child) {
                if (value) {
                  return loadingIndicator ?? const BaseLoadingIndicator();
                }
                return SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
