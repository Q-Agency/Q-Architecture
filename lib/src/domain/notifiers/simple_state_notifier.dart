// ignore_for_file: always_use_package_imports

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/q_architecture.dart';

abstract class SimpleStateNotifier<T> extends StateNotifier<T> {
  final Ref ref;
  Timer? _debounceTimer;
  bool _isThrottling = false;

  SimpleStateNotifier(this.ref, T initialState) : super(initialState);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  ///Show [BaseLoadingIndicator] above the entire app
  @protected
  void showGlobalLoading() =>
      ref.read(globalLoadingProvider.notifier).update((state) => true);

  ///Clear [BaseLoadingIndicator]
  @protected
  void clearGlobalLoading() =>
      ref.read(globalLoadingProvider.notifier).update((state) => false);

  @protected
  void setGlobalFailure(Failure? failure) {
    clearGlobalLoading();
    ref
        .read(globalFailureProvider.notifier)
        .update((state) => failure?.copyWith(uniqueKey: UniqueKey()));
  }

  @protected
  void setGlobalInfo(GlobalInfo? globalInfo) {
    clearGlobalLoading();
    ref
        .read(globalInfoProvider.notifier)
        .update((state) => globalInfo?.copyWith(uniqueKey: UniqueKey()));
  }

  ///Subscribe to another notifier's state changes
  @protected
  void on<U>(
    AlwaysAliveProviderListenable<U> provider,
    void Function(U? previous, U next) invokeFunction, {
    bool Function(U? previous, U next)? skipUpdateCondition,
  }) {
    ref.listen(
      provider,
      (previous, next) {
        if (previous == next) return;
        if (skipUpdateCondition?.call(previous, next) ?? false) return;

        invokeFunction.call(previous, next);
      },
    );
  }

  ///Wait to collect multiple method calls for certain duration before allowing only one method call to proceed
  @protected
  Future<void> debounce({
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    if (_debounceTimer?.isActive == true) {
      _debounceTimer?.cancel();
    }
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
  }) async {
    if (_isThrottling) return;
    _isThrottling = true;
    final functionCompleter = Completer();
    final throttleCompleter = Completer();
    var durationFinished = false;
    final completeThrottle = () {
      if (mounted && !throttleCompleter.isCompleted) {
        _isThrottling = false;
        throttleCompleter.complete();
      }
    };
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
}
