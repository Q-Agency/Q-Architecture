import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:q_architecture/q_architecture.dart';

class QNotifier<T> extends ChangeNotifier {
  ///The current state
  T _state;

  ///The previous state, can be null
  T? _previousState;

  final List<_ListenerWrapper> _listenersWrappers = [];
  Timer? _debounceTimer;
  final Map<String, bool> _isThrottlingMap = {};
  final bool _autoDispose;

  /// Constructor for QNotifier
  ///
  /// [state] - The initial state of the notifier
  /// [autoDispose] - If true, the notifier will be disposed when all listeners are removed.
  /// IMPORTANT: When using autoDispose=true, this QNotifier subclass
  /// MUST be registered as a lazySingleton in GetIt, otherwise an exception
  /// will be thrown when attempting to reset the lazy singleton.
  QNotifier(T state, {bool autoDispose = false})
    : _state = state,
      _autoDispose = autoDispose;

  @override
  void dispose() {
    removeAllListeners();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (_autoDispose && !hasListeners) {
      GetIt.instance.resetLazySingleton(instance: this);
    }
  }

  ///Gets the state
  T get state => _state;

  ///Gets the previous state
  T? get previousState => _previousState;

  ///Sets the state
  ///[newState] - the new state
  @protected
  set state(T newState) {
    if (_state == newState) return;
    _previousState = _state;
    _state = newState;
    notifyListeners();
  }

  /// Adds a listener and returns a function that can be called to remove the listener.
  /// The returned callback must be stored and called when the listener should be removed
  /// to prevent memory leaks, especially if the notifier outlives the listening object.
  /// Otherwise, listener can be removed by calling removeSpecificListener with the same listenerId
  /// [listener] - the listener function that will be called when the state changes with the current and previous state
  /// [fireImmediately] - if true, the listener will be called immediately with the current state
  /// [listenerId] - a unique identifier for the listener, if not provided, an empty string will be used
  @useResult
  VoidCallback listen(
    void Function(T currentState, T? previousState) listener, {
    bool fireImmediately = false,
    Object listenerId = '',
  }) {
    // Check if this exact listener is already registered
    final existingListenerIndex = _listenersWrappers.indexWhere(
      (wrapper) => wrapper.id == listenerId,
    );
    // If the listener is already registered, remove it
    if (existingListenerIndex != -1) {
      removeSpecificListener(listenerIndex: existingListenerIndex);
    }
    // Create a wrapped function that calls the listener with state information
    void wrappedListener() => listener(_state, _previousState);
    // Create and store the wrapper
    final wrapper = _ListenerWrapper(id: listenerId, call: wrappedListener);
    // Add to our listeners list
    _listenersWrappers.add(wrapper);
    addListener(wrappedListener);

    if (fireImmediately) wrappedListener();
    // Return a function that removes this specific listener
    return () => removeSpecificListener(listenerId: listenerId);
  }

  ///Removes a specific listener by its ID
  ///[listenerId] - the ID of the listener to remove
  ///[listenerIndex] - the index of the listener to remove
  void removeSpecificListener({Object? listenerId, int? listenerIndex}) {
    assert(
      listenerId != null || listenerIndex != null,
      'listenerId or listenerIndex must be provided',
    );
    final index =
        listenerIndex ??
        _listenersWrappers.indexWhere((wrapper) => wrapper.id == listenerId);
    if (index != -1) {
      final wrapper = _listenersWrappers[index];
      _listenersWrappers.removeAt(index);
      removeListener(wrapper.call);
    }
  }

  /// Removes all listeners
  void removeAllListeners() {
    for (final listener in _listenersWrappers) {
      removeListener(listener.call);
    }
    _listenersWrappers.clear();
  }

  ///Shows [BaseLoadingIndicator] above the entire app
  @protected
  void showGlobalLoading() =>
      GetIt.instance<GlobalLoadingNotifier>().setGlobalLoading(true);

  ///Clears [BaseLoadingIndicator]
  @protected
  void clearGlobalLoading() =>
      GetIt.instance<GlobalLoadingNotifier>().setGlobalLoading(false);

  ///Sets a global failure
  ///[failure] - the failure to set, can be null
  @protected
  void setGlobalFailure(Failure? failure) {
    clearGlobalLoading();
    GetIt.instance<GlobalFailureNotifier>().setFailure(
      failure?.copyWith(uniqueKey: getRandomStringWithTimestamp(10)),
    );
  }

  ///Sets a global info
  ///[globalInfo] - the info to set, can be null
  @protected
  void setGlobalInfo(GlobalInfo? globalInfo) {
    clearGlobalLoading();
    GetIt.instance<GlobalInfoNotifier>().setGlobalInfo(
      globalInfo?.copyWith(uniqueKey: getRandomStringWithTimestamp(10)),
    );
  }

  ///Wait to collect multiple method calls for certain duration before allowing only one method call to proceed
  ///[duration] - the duration to wait before allowing only one method call to proceed
  @protected
  Future<void> debounce({
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    if (_debounceTimer?.isActive == true) _debounceTimer?.cancel();
    final debounceCompleter = Completer();
    _debounceTimer = Timer(duration, () => debounceCompleter.complete());
    await debounceCompleter.future;
  }

  ///Execute given function and then block further executing of the same function for certain duration.
  ///[function] - the function to execute
  ///[duration] - the duration to wait before allowing only one method call to proceed
  ///[waitForFunction] - if set to true it will wait if function finishes after provided duration delay, otherwise will finish immediately after given duration
  ///[throttleIdentifier] - a unique identifier for the throttle, if not provided, an empty string will be used
  @protected
  Future<void> throttle(
    Future<void> Function() function, {
    Duration duration = const Duration(milliseconds: 500),
    bool waitForFunction = true,
    String throttleIdentifier = '',
  }) async {
    if (_isThrottlingMap[throttleIdentifier] == true) return;
    _isThrottlingMap[throttleIdentifier] = true;
    final functionCompleter = Completer();
    final throttleCompleter = Completer();
    var durationFinished = false;
    void completeThrottle() {
      if (!throttleCompleter.isCompleted) {
        _isThrottlingMap[throttleIdentifier] = false;
        throttleCompleter.complete();
      }
    }

    function().then(
      (value) {
        functionCompleter.complete();
        if (durationFinished) completeThrottle();
      },
      onError: (error) {
        functionCompleter.completeError(error);
        if (durationFinished) completeThrottle();
      },
    );
    Future.delayed(duration, () {
      durationFinished = true;
      if (!waitForFunction || functionCompleter.isCompleted) {
        completeThrottle();
      }
    });
    await Future.wait([
      if (waitForFunction) functionCompleter.future,
      throttleCompleter.future,
    ]);
  }

  ///Cancels if throttling is in progress
  ///[throttleIdentifier] - a unique identifier for the throttle, if not provided, an empty string will be used
  @protected
  void cancelThrottle({String throttleIdentifier = ''}) =>
      _isThrottlingMap[throttleIdentifier] = false;

  ///Generates a random string with a timestamp
  ///[length] - the length of the random string
  String getRandomStringWithTimestamp(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final randomStr = String.fromCharCodes(
      List.generate(
        length,
        (index) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$randomStr$timestamp';
  }

  @override
  String toString() => '${describeIdentity(this)}($state)';
}

class _ListenerWrapper extends Equatable {
  final Object id;
  final VoidCallback call;

  const _ListenerWrapper({required this.id, required this.call});

  @override
  List<Object?> get props => [id, call];
}
