import 'package:flutter/widgets.dart';
import 'package:q_architecture/q_architecture.dart';

class SimpleNotifierListener<T> extends StatefulWidget {
  const SimpleNotifierListener({
    super.key,
    required this.simpleNotifier,
    required this.onChange,
    this.fireImmediately = false,
    required this.child,
  });

  final SimpleNotifier<T> simpleNotifier;
  final void Function(T currentState, T? previousState) onChange;
  final bool fireImmediately;
  final Widget child;

  @override
  State<SimpleNotifierListener<T>> createState() =>
      _SimpleNotifierListenerState<T>();
}

class _SimpleNotifierListenerState<T> extends State<SimpleNotifierListener<T>> {
  VoidCallback? _listenerDisposer;

  @override
  void initState() {
    super.initState();
    widget.simpleNotifier.addListener(_listener);
    if (widget.fireImmediately) _listener();
  }

  @override
  void didUpdateWidget(SimpleNotifierListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.simpleNotifier != widget.simpleNotifier) {
      oldWidget.simpleNotifier.removeListener(_listener);
      widget.simpleNotifier.addListener(_listener);
      if (widget.fireImmediately) _listener();
    }
  }

  @override
  void dispose() {
    _listenerDisposer?.call();
    super.dispose();
  }

  void _listener() {
    widget.onChange(
      widget.simpleNotifier.state,
      widget.simpleNotifier.previousState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
