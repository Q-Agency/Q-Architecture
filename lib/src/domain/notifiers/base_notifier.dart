import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/base_state_notifier.dart';
import 'package:q_architecture/q_architecture.dart';

typedef PreHandleData<T> = bool Function(T data);
typedef PreHandleFailure = bool Function(Failure failure);

mixin BaseNotifierController<DataState> on SimpleNotifierController {
  /// Executes received [function] with additional parameters to control if loading state should be set while executing [function] by providing [withLoadingState] param.
  ///
  /// Also if you want loading shown over all screens, it can se set via [globalLoading] param.
  /// To show failure over all screens instead changing the state, it can be set via [globalFailure] params.
  /// If your method gets called more than once in a short period, you can set [withDebounce] param to true to wait for
  /// [debounceDuration], if [debounceDuration] is not provided, default will be used.
  /// To filter and control which data will update the state, [onDataReceived] callback can be passed. Alternatively,
  /// if callback always return false, custom data handling can be implemented.
  /// To filter and control which failure will update the state or be shown globally, [onFailureOccurred] callback can be
  /// passed. Similar to [onDataReceived] if always returned false, custom failure handling can be implemented.
  @protected
  Future<void> execute(
    EitherFailureOr<DataState> function, {
    PreHandleData<DataState>? onDataReceived,
    PreHandleFailure? onFailureOccurred,
    bool withLoadingState = true,
    bool globalLoading = false,
    bool globalFailure = true,
    required BaseState<DataState> Function({BaseState<DataState>? newState})
        getOrUpdateState,
  }) async {
    _setLoading(withLoadingState, globalLoading, getOrUpdateState);

    final result = await function;
    _handleResult(
      result,
      onDataReceived,
      onFailureOccurred,
      withLoadingState,
      globalLoading,
      globalFailure,
      getOrUpdateState,
    );
  }

  /// Executes received stream [function] with additional parameters to control if loading state should be set while executing [function] by providing [withLoadingState] param.
  /// Usage is the same as the [execute] method with the main difference in number of [function] results (and consequently number of state updates) as it is a stream of data
  @protected
  // ignore: avoid-redundant-async
  Future<void> executeStreamed(
    StreamFailureOr<DataState> function, {
    PreHandleData<DataState>? onDataReceived,
    PreHandleFailure? onFailureOccurred,
    bool withLoadingState = true,
    bool globalLoading = false,
    bool globalFailure = true,
    required BaseState<DataState> Function({BaseState<DataState>? newState})
        getOrUpdateState,
  }) async {
    _setLoading(withLoadingState, globalLoading, getOrUpdateState);

    await for (final result in function) {
      _handleResult(
        result,
        onDataReceived,
        onFailureOccurred,
        withLoadingState,
        globalLoading,
        globalFailure,
        getOrUpdateState,
      );
    }
  }

  void _handleResult(
    Either<Failure, DataState> result,
    PreHandleData<DataState>? onDataReceived,
    PreHandleFailure? onFailureOccurred,
    bool withLoadingState,
    bool globalLoading,
    bool globalFailure,
    BaseState<DataState> Function({BaseState<DataState>? newState})
        getOrUpdateState,
  ) {
    result.fold(
      (failure) => _onFailure(
        failure,
        onFailureOccurred,
        withLoadingState,
        globalFailure,
        getOrUpdateState,
      ),
      (data) =>
          _onData(data, onDataReceived, withLoadingState, getOrUpdateState),
    );
  }

  void _onFailure(
    Failure failure,
    PreHandleFailure? onFailureOccurred,
    bool withLoadingState,
    bool globalFailure,
    BaseState<DataState> Function({BaseState<DataState>? newState})
        getOrUpdateState,
  ) {
    final shouldProceedWithFailure = onFailureOccurred?.call(failure) ?? true;
    if (!shouldProceedWithFailure || globalFailure || !withLoadingState) {
      _unsetLoading(withLoadingState, getOrUpdateState);
    }
    if (shouldProceedWithFailure) {
      globalFailure
          ? setGlobalFailure(failure)
          : getOrUpdateState(newState: BaseState.error(failure));
    }
  }

  void _onData(
    DataState data,
    PreHandleData<DataState>? onDataReceived,
    bool withLoadingState,
    BaseState<DataState> Function({BaseState<DataState>? newState})
        getOrUpdateState,
  ) {
    final shouldUpdateState = onDataReceived?.call(data) ?? true;
    _unsetLoading(
      shouldUpdateState ? false : withLoadingState,
      getOrUpdateState,
    );
    if (shouldUpdateState) {
      getOrUpdateState(newState: BaseState.data(data));
    }
  }

  ///Shows global loading if [globalLoading] == true
  ///Set [withLoadingState] == true if you want to change [BaseStateNotifier] state to [BaseState.loading]
  void _setLoading(
    bool withLoadingState,
    bool globalLoading,
    BaseState<DataState> Function({BaseState<DataState>? newState})
        getOrUpdateState,
  ) {
    if (withLoadingState) getOrUpdateState(newState: const BaseState.loading());
    if (globalLoading) showGlobalLoading();
  }

  ///Clears global loading
  ///Set [withLoadingState] == true if you want to reset [BaseStateNotifier] state to [BaseState.initial]
  void _unsetLoading(
    bool withLoadingState,
    BaseState<DataState> Function({BaseState<DataState>? newState})
        getOrUpdateState,
  ) {
    final isAlreadyLoading = switch (getOrUpdateState()) {
      BaseLoading() => true,
      _ => false,
    };
    if (withLoadingState && isAlreadyLoading) {
      getOrUpdateState(newState: const BaseState.initial());
    }
    clearGlobalLoading();
  }
}

abstract class BaseNotifier<T> extends Notifier<BaseState<T>>
    with SimpleNotifierController, BaseNotifierController<T> {}

abstract class AutoDisposeBaseNotifier<T>
    extends AutoDisposeNotifier<BaseState<T>>
    with SimpleNotifierController, BaseNotifierController {}

abstract class FamilyBaseNotifier<T, Param>
    extends FamilyNotifier<BaseState<T>, Param>
    with SimpleNotifierController, BaseNotifierController {}

abstract class AutoDisposeFamilyBaseNotifier<T, Param>
    extends AutoDisposeFamilyNotifier<BaseState<T>, Param>
    with SimpleNotifierController, BaseNotifierController {}
