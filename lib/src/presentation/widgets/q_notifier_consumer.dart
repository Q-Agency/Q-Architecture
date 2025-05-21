import 'package:flutter/widgets.dart';
import 'package:q_architecture/q_architecture.dart';

class QNotifierConsumer<T> extends StatefulWidget {
  /// The [QNotifier] instance to listen to.
  final QNotifier<T> qNotifier;

  /// The listener to call when the state changes.
  final void Function(BuildContext context, T currentState, T? previousState)
  listener;

  /// The builder function.
  final Widget Function(
    BuildContext context,
    T currentState,
    T? previousState,
    Widget? child,
  )
  builder;

  /// A [QNotifier]-independent widget which is passed back to the [builder].
  ///
  /// This argument is optional and can be null if the entire widget subtree the
  /// [builder] builds depends on the state of the [QNotifier]. For
  /// example, in the case where the [QNotifier] is a [String] and the
  /// [builder] returns a [Text] widget with the current [String] value, there
  /// would be no useful [child].
  final Widget? child;

  const QNotifierConsumer({
    super.key,
    required this.qNotifier,
    required this.listener,
    required this.builder,
    this.child,
  });

  @override
  State<QNotifierConsumer<T>> createState() => _QNotifierConsumerState<T>();
}

class _QNotifierConsumerState<T> extends State<QNotifierConsumer<T>> {
  late QNotifier<T> _qNotifier;

  @override
  void initState() {
    super.initState();
    _qNotifier = widget.qNotifier;
  }

  @override
  void didUpdateWidget(QNotifierConsumer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.qNotifier != widget.qNotifier) {
      _qNotifier = widget.qNotifier;
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
  Widget build(BuildContext context) {
    return QNotifierBuilder(
      qNotifier: _qNotifier,
      builder: (context, currentState, previousState, child) {
        widget.listener(context, currentState, previousState);
        return widget.builder(context, currentState, previousState, child);
      },
      child: widget.child,
    );
  }
}
