import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:q_architecture/q_architecture.dart';

class BaseWidget extends StatefulWidget {
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
  State<BaseWidget> createState() => _BaseWidgetState();
}

class _BaseWidgetState extends State<BaseWidget> {
  @override
  void initState() {
    super.initState();

    GetIt.instance<GlobalFailureNotifier>()
        .listen((currentState, previousState) {
      if (currentState == null) return;
      widget.onGlobalFailure(currentState);
    });
    GetIt.instance<GlobalInfoNotifier>().listen((currentState, previousState) {
      if (currentState == null) return;
      widget.onGlobalInfo(currentState);
    });
  }

  @override
  Widget build(BuildContext context) {
    final globalLoadingNotifier = GetIt.instance<GlobalLoadingNotifier>();
    return Stack(
      children: [
        widget.child,
        ValueListenableBuilder(
          valueListenable: globalLoadingNotifier,
          builder: (context, value, child) {
            if (value) {
              return widget.loadingIndicator ?? const BaseLoadingIndicator();
            }
            return SizedBox();
          },
        ),
      ],
    );
  }
}
