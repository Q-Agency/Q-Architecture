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
    return QNotifierListener(
      qNotifier: GetIt.instance<GlobalFailureNotifier>(),
      listener: (context, currentState, previousState) {
        if (currentState == null) return;
        onGlobalFailure(currentState);
      },
      child: QNotifierListener(
        qNotifier: GetIt.instance<GlobalInfoNotifier>(),
        listener: (context, currentState, previousState) {
          if (currentState == null) return;
          onGlobalInfo(currentState);
        },
        child: Stack(
          children: [
            child,
            QNotifierBuilder(
              qNotifier: GetIt.instance<GlobalLoadingNotifier>(),
              builder: (context, currentState, previousState, child) {
                if (currentState) {
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
