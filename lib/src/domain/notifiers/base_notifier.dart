import 'package:either_dart/either.dart';
import 'package:meta/meta.dart';
import 'package:q_architecture/q_architecture.dart';

typedef PreHandleData<T> = bool Function(T data);
typedef PreHandleFailure = bool Function(Failure failure);

class BaseNotifier<DataState> extends QNotifier<BaseState<DataState>> {
  BaseNotifier({super.autoDispose}) : super(BaseState.initial());

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
  }) async {
    _setLoading(withLoadingState, globalLoading);

    final result = await function;
    _handleResult(
      result,
      onDataReceived,
      onFailureOccurred,
      withLoadingState,
      globalLoading,
      globalFailure,
    );
  }

  /// Executes received stream [function] with additional parameters to control if loading state should be set while executing [function] by providing [withLoadingState] param.
  /// Usage is the same as the [execute] method with the main difference in number of [function] results (and consequently number of state updates) as it is a stream of data
  @protected
  Future<void> executeStreamed(
    StreamFailureOr<DataState> function, {
    PreHandleData<DataState>? onDataReceived,
    PreHandleFailure? onFailureOccurred,
    bool withLoadingState = true,
    bool globalLoading = false,
    bool globalFailure = true,
  }) async {
    _setLoading(withLoadingState, globalLoading);

    await for (final result in function) {
      _handleResult(
        result,
        onDataReceived,
        onFailureOccurred,
        withLoadingState,
        globalLoading,
        globalFailure,
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
  ) {
    result.fold(
      (failure) => _onFailure(
        failure,
        onFailureOccurred,
        withLoadingState,
        globalFailure,
      ),
      (data) => _onData(data, onDataReceived, withLoadingState),
    );
  }

  void _onFailure(
    Failure failure,
    PreHandleFailure? onFailureOccurred,
    bool withLoadingState,
    bool globalFailure,
  ) {
    final shouldProceedWithFailure = onFailureOccurred?.call(failure) ?? true;
    if (!shouldProceedWithFailure || globalFailure || !withLoadingState) {
      _unsetLoading(withLoadingState);
    }
    if (shouldProceedWithFailure) {
      globalFailure
          ? setGlobalFailure(failure)
          : state = BaseState.error(failure);
    }
  }

  void _onData(
    DataState data,
    PreHandleData<DataState>? onDataReceived,
    bool withLoadingState,
  ) {
    final shouldUpdateState = onDataReceived?.call(data) ?? true;
    _unsetLoading(shouldUpdateState ? false : withLoadingState);
    if (shouldUpdateState) {
      state = BaseState.data(data);
    }
  }

  ///Shows global loading if [globalLoading] == true
  ///Set [withLoadingState] == true if you want to change [BaseNotifier] state to [BaseState.loading]
  void _setLoading(bool withLoadingState, bool globalLoading) {
    if (withLoadingState) {
      state = BaseState.loading();
    }
    if (globalLoading) showGlobalLoading();
  }

  ///Clears global loading
  ///Set [withLoadingState] == true if you want to reset [BaseNotifier] state to [BaseState.initial]
  void _unsetLoading(bool withLoadingState) {
    final isAlreadyLoading = switch (state) {
      BaseLoading() => true,
      _ => false,
    };
    if (withLoadingState && isAlreadyLoading) {
      state = BaseState.initial();
    }
    clearGlobalLoading();
  }
}
