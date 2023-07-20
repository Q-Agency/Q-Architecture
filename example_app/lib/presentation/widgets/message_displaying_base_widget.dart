import 'package:flutter/material.dart';
import 'package:q_architecture/q_architecture.dart';

class MessageDisplayingBaseWidget extends StatelessWidget {
  final Widget? child;
  const MessageDisplayingBaseWidget({
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      onFailure: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${failure.title} ${failure.error}'),
        ),
      ),
      onGlobalInfo: (globalInfo) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${globalInfo.globalInfoStatus} ${globalInfo.message}'),
        ),
      ),
      child: child ?? const SizedBox(),
    );
  }
}
