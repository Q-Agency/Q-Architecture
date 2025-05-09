import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:q_architecture/q_architecture.dart';

class SimpleNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  T _state;
  T? _previousState;
  final List<VoidCallback> _listeners = [];
  Timer? _debounceTimer;
  final Map<String, bool> _isThrottlingMap = {};

  SimpleNotifier(this._state);

  @override
  void dispose() {
    removeAllListeners();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  T get value => state;

  T get state => _state;

  @protected
  set state(T newState) {
    if (_state == newState) return;
    _previousState = _state;
    _state = newState;
    notifyListeners();
  }

  /// Adds a listener and returns a function that can be called to remove the listener
  VoidCallback listen(
    void Function(T currentState, T? previousState) listener, {
    bool fireImmediately = false,
  }) {
    void wrappedListener() => listener(_state, _previousState);
    _listeners.add(wrappedListener);
    addListener(wrappedListener);
    if (fireImmediately) {
      wrappedListener();
    }
    return () {
      _listeners.remove(listener);
      removeListener(wrappedListener);
    };
  }

  /// Removes all listeners
  void removeAllListeners() {
    for (final listener in _listeners) {
      removeListener(listener);
    }
    _listeners.clear();
  }

  ///Show [BaseLoadingIndicator] above the entire app
  @protected
  void showGlobalLoading() =>
      GetIt.instance<GlobalLoadingNotifier>().setGlobalLoading(true);

  ///Clear [BaseLoadingIndicator]
  @protected
  void clearGlobalLoading() =>
      GetIt.instance<GlobalLoadingNotifier>().setGlobalLoading(false);

  @protected
  void setGlobalFailure(Failure? failure) {
    clearGlobalLoading();
    GetIt.instance<GlobalFailureNotifier>().setFailure(
      failure?.copyWith(uniqueKey: UniqueKey()),
    );
  }

  @protected
  void setGlobalInfo(GlobalInfo? globalInfo) {
    clearGlobalLoading();
    GetIt.instance<GlobalInfoNotifier>().setGlobalInfo(
      globalInfo?.copyWith(uniqueKey: UniqueKey()),
    );
  }

  ///Wait to collect multiple method calls for certain duration before allowing only one method call to proceed
  @protected
  Future<void> debounce({
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    if (_debounceTimer?.isActive == true) _debounceTimer?.cancel();
    final debounceCompleter = Completer();
    _debounceTimer = Timer(
      duration,
      () => debounceCompleter.complete(),
    );
    await debounceCompleter.future;
  }

  ///Execute given function and then block further executing of the same function for certain duration.
  ///[waitForFunction] if set to true it will wait if function finishes after provided duration delay, otherwise will finish immediately after given duration
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
  @protected
  void cancelThrottle({String throttleIdentifier = ''}) =>
      _isThrottlingMap[throttleIdentifier] = false;

  @override
  String toString() => '${describeIdentity(this)}($state)';
}
