import 'package:q_architecture/q_architecture.dart';

/// Abstract interface for observing QNotifier lifecycle events
abstract interface class QNotifierObserver {
  /// Called when a QNotifier is initialized
  /// [notifier] - The QNotifier instance that was initialized
  /// [initialState] - The initial state of the notifier
  void onInitialized(QNotifier notifier, dynamic initialState);

  /// Called when a QNotifier state changes
  /// [notifier] - The QNotifier instance that changed
  /// [previousState] - The previous state value
  /// [currentState] - The new state value
  void onStateChanged(
    QNotifier notifier,
    dynamic previousState,
    dynamic currentState,
  );

  /// Called when a QNotifier is disposed
  /// [notifier] - The QNotifier instance that was disposed
  /// [finalState] - The final state before disposal
  void onDisposed(QNotifier notifier, dynamic finalState);
}
