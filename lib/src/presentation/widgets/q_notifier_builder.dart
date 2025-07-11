import 'package:flutter/widgets.dart';
import 'package:q_architecture/q_architecture.dart';

/// A widget that builds a widget when a [QNotifier] changes state.
class QNotifierBuilder<T> extends StatefulWidget {
  /// The [QNotifier] instance to listen to.
  final QNotifier<T> qNotifier;

  /// The builder function.
  final Widget Function(
    BuildContext context,
    T currentState,
    T? previousState,
    Widget? child,
  ) builder;

  /// A [QNotifier]-independent widget which is passed back to the [builder].
  ///
  /// This argument is optional and can be null if the entire widget subtree the
  /// [builder] builds depends on the state of the [QNotifier]. For
  /// example, in the case where the [QNotifier] is a [String] and the
  /// [builder] returns a [Text] widget with the current [String] value, there
  /// would be no useful [child].
  final Widget? child;

  const QNotifierBuilder({
    super.key,
    required this.qNotifier,
    required this.builder,
    this.child,
  });

  @override
  State<QNotifierBuilder<T>> createState() => _QNotifierBuilderState<T>();
}

class _QNotifierBuilderState<T> extends State<QNotifierBuilder<T>> {
  late QNotifier<T> _qNotifier;
  late T _state;

  @override
  void initState() {
    super.initState();
    _qNotifier = widget.qNotifier;
    _state = _qNotifier.state;
  }

  @override
  void didUpdateWidget(QNotifierBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.qNotifier != widget.qNotifier) {
      _qNotifier = widget.qNotifier;
      _state = _qNotifier.state;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.qNotifier != _qNotifier) {
      _qNotifier = widget.qNotifier;
      _state = _qNotifier.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    return QNotifierListener(
      qNotifier: widget.qNotifier,
      listener: (context, currentState, previousState) {
        setState(() => _state = currentState);
      },
      child: widget.builder(
        context,
        _state,
        widget.qNotifier.previousState,
        widget.child,
      ),
    );
  }
}
