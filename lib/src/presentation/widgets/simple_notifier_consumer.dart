import 'package:flutter/widgets.dart';
import 'package:q_architecture/q_architecture.dart';

class SimpleNotifierConsumer<T> extends StatefulWidget {
  /// The [SimpleNotifier] instance to listen to.
  final SimpleNotifier<T> simpleNotifier;

  /// The listener to call when the state changes.
  final void Function(BuildContext context, T currentState, T? previousState)
      listener;

  /// The builder function.
  final Widget Function(
    BuildContext context,
    T currentState,
    T? previousState,
    Widget? child,
  ) builder;

  /// A [SimpleNotifier]-independent widget which is passed back to the [builder].
  ///
  /// This argument is optional and can be null if the entire widget subtree the
  /// [builder] builds depends on the state of the [SimpleNotifier]. For
  /// example, in the case where the [SimpleNotifier] is a [String] and the
  /// [builder] returns a [Text] widget with the current [String] value, there
  /// would be no useful [child].
  final Widget? child;

  const SimpleNotifierConsumer({
    super.key,
    required this.simpleNotifier,
    required this.listener,
    required this.builder,
    this.child,
  });

  @override
  State<SimpleNotifierConsumer<T>> createState() =>
      _SimpleNotifierConsumerState<T>();
}

class _SimpleNotifierConsumerState<T> extends State<SimpleNotifierConsumer<T>> {
  late SimpleNotifier<T> _simpleNotifier;

  @override
  void initState() {
    super.initState();
    _simpleNotifier = widget.simpleNotifier;
  }

  @override
  void didUpdateWidget(SimpleNotifierConsumer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.simpleNotifier != widget.simpleNotifier) {
      _simpleNotifier = widget.simpleNotifier;
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
  Widget build(BuildContext context) {
    return SimpleNotifierBuilder(
      simpleNotifier: _simpleNotifier,
      builder: (context, currentState, previousState, child) {
        widget.listener(context, currentState, previousState);
        return widget.builder(context, currentState, previousState, child);
      },
      child: widget.child,
    );
  }
}
