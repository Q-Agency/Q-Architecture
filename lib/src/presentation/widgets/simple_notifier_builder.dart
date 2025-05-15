import 'package:flutter/widgets.dart';
import 'package:q_architecture/q_architecture.dart';

/// A widget that builds a widget when a [SimpleNotifier] changes state.
class SimpleNotifierBuilder<T> extends StatefulWidget {
  /// The [SimpleNotifier] instance to listen to.
  final SimpleNotifier<T> simpleNotifier;

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

  const SimpleNotifierBuilder({
    super.key,
    required this.simpleNotifier,
    required this.builder,
    this.child,
  });

  @override
  State<SimpleNotifierBuilder<T>> createState() =>
      _SimpleNotifierBuilderState<T>();
}

class _SimpleNotifierBuilderState<T> extends State<SimpleNotifierBuilder<T>> {
  late T state;

  @override
  void initState() {
    super.initState();
    state = widget.simpleNotifier.state;
    widget.simpleNotifier.addListener(_stateChanged);
  }

  @override
  void didUpdateWidget(SimpleNotifierBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.simpleNotifier != widget.simpleNotifier) {
      oldWidget.simpleNotifier.removeListener(_stateChanged);
      state = widget.simpleNotifier.state;
      widget.simpleNotifier.addListener(_stateChanged);
    }
  }

  @override
  void dispose() {
    widget.simpleNotifier.removeListener(_stateChanged);
    super.dispose();
  }

  void _stateChanged() => setState(() => state = widget.simpleNotifier.state);

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      state,
      widget.simpleNotifier.previousState,
      widget.child,
    );
  }
}
