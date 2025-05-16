import 'package:flutter/widgets.dart';
import 'package:q_architecture/q_architecture.dart';

/// A widget that listens to a [SimpleNotifier] and calls a listener when the state changes.
class SimpleNotifierListener<T> extends StatefulWidget {
  /// The [SimpleNotifier] instance to listen to.
  final SimpleNotifier<T> simpleNotifier;

  /// The listener to call when the state changes.
  final void Function(BuildContext context, T currentState, T? previousState)
      listener;

  /// Whether to fire the listener immediately when the widget is built.
  final bool fireImmediately;

  /// The child to build.
  final Widget child;

  const SimpleNotifierListener({
    super.key,
    required this.simpleNotifier,
    required this.listener,
    this.fireImmediately = false,
    required this.child,
  });

  @override
  State<SimpleNotifierListener<T>> createState() =>
      _SimpleNotifierListenerState<T>();
}

class _SimpleNotifierListenerState<T> extends State<SimpleNotifierListener<T>> {
  late SimpleNotifier<T> _simpleNotifier;
  @override
  void initState() {
    super.initState();
    _simpleNotifier = widget.simpleNotifier;
    widget.simpleNotifier.addListener(_listener);
    if (widget.fireImmediately) _listener();
  }

  @override
  void didUpdateWidget(SimpleNotifierListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.simpleNotifier != widget.simpleNotifier) {
      oldWidget.simpleNotifier.removeListener(_listener);
      _simpleNotifier = widget.simpleNotifier;
      _simpleNotifier.addListener(_listener);
      if (widget.fireImmediately) _listener();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.simpleNotifier != _simpleNotifier) {
      _simpleNotifier = widget.simpleNotifier;
    }
  }

  @override
  void dispose() {
    _simpleNotifier.removeListener(_listener);
    super.dispose();
  }

  void _listener() => widget.listener(
        context,
        _simpleNotifier.state,
        _simpleNotifier.previousState,
      );

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
