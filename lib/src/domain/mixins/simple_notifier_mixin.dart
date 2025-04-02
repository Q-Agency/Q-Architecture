import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_architecture/q_architecture.dart';

mixin SimpleNotifierMixin {
  late final Ref _ref;
  bool _initialized = false;
  Timer? _debounceTimer;
  final Map<String, bool> _isThrottlingMap = {};

  @protected
  void initWithRef(Ref ref) {
    if (_initialized) return;
    _initialized = true;
    _ref = ref;
    _ref.onDispose(() => _debounceTimer?.cancel());
  }

  ///Show [BaseLoadingIndicator] above the entire app
  @protected
  void showGlobalLoading() =>
      _ref.read(globalLoadingProvider.notifier).update((state) => true);

  ///Clear [BaseLoadingIndicator]
  @protected
  void clearGlobalLoading() =>
      _ref.read(globalLoadingProvider.notifier).update((state) => false);

  @protected
  void setGlobalFailure(Failure? failure) {
    clearGlobalLoading();
    _ref
        .read(globalFailureProvider.notifier)
        .update((state) => failure?.copyWith(uniqueKey: UniqueKey()));
  }

  @protected
  void setGlobalInfo(GlobalInfo? globalInfo) {
    clearGlobalLoading();
    _ref
        .read(globalInfoProvider.notifier)
        .update((state) => globalInfo?.copyWith(uniqueKey: UniqueKey()));
  }

  ///Subscribe to another notifier's state changes
  @protected
  void on<U>(
    ProviderListenable<U> provider,
    void Function(U? previous, U next) invokeFunction, {
    bool Function(U? previous, U next)? skipUpdateCondition,
  }) =>
      _ref.listen(
        provider,
        (previous, next) {
          if (previous == next) return;
          if (skipUpdateCondition?.call(previous, next) ?? false) return;

          invokeFunction.call(previous, next);
        },
      );

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
}
