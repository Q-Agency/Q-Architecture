import 'package:flutter/widgets.dart';
import 'package:q_architecture/q_architecture.dart';

/// A widget that listens to a [QNotifier] and calls a listener when the state changes.
class QNotifierListener<T> extends StatefulWidget {
  /// The [QNotifier] instance to listen to.
  final QNotifier<T> qNotifier;

  /// The listener to call when the state changes.
  final void Function(BuildContext context, T currentState, T? previousState)
      listener;

  /// Whether to fire the listener immediately when the widget is built.
  final bool fireImmediately;

  /// The child to build.
  final Widget child;

  const QNotifierListener({
    super.key,
    required this.qNotifier,
    required this.listener,
    this.fireImmediately = false,
    required this.child,
  });

  @override
  State<QNotifierListener<T>> createState() => _QNotifierListenerState<T>();
}

class _QNotifierListenerState<T> extends State<QNotifierListener<T>> {
  late QNotifier<T> _qNotifier;

  @override
  void initState() {
    super.initState();
    _qNotifier = widget.qNotifier;
    widget.qNotifier.addListener(_listener);
    if (widget.fireImmediately) _listener();
  }

  @override
  void didUpdateWidget(QNotifierListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.qNotifier != widget.qNotifier) {
      oldWidget.qNotifier.removeListener(_listener);
      _qNotifier = widget.qNotifier;
      _qNotifier.addListener(_listener);
      if (widget.fireImmediately) _listener();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.qNotifier != _qNotifier) {
      _qNotifier = widget.qNotifier;
    }
  }

  @override
  void dispose() {
    _qNotifier.removeListener(_listener);
    super.dispose();
  }

  void _listener() =>
      widget.listener(context, _qNotifier.state, _qNotifier.previousState);

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
