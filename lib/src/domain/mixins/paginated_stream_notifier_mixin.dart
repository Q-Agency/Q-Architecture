import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/paginated_notifier.dart';
import 'package:q_architecture/q_architecture.dart';
import 'package:q_architecture/src/domain/mixins/simple_notifier_mixin.dart';

mixin PaginatedStreamNotifierMixin<Entity, Param> on SimpleNotifierMixin {
  late final Ref _ref;
  late final bool _useGlobalFailure;
  late final PaginatedState<Entity> Function({PaginatedState<Entity>? newState})
      _getOrUpdateState;
  bool _initialized = false;
  PaginatedList<Entity>? _lastPaginatedList;
  Param? _parameter;
  StreamSubscription? _listStreamSubscription;

  @protected
  void initWithRefUseGlobalFailureAndGetOrUpdateState(
    Ref ref,
    bool useGlobalFailure,
    PaginatedState<Entity> Function({PaginatedState<Entity>? newState})
        getOrUpdateState,
  ) {
    if (_initialized) return;
    _initialized = true;
    super.initWithRef(ref);
    _ref = ref;
    _useGlobalFailure = useGlobalFailure;
    _getOrUpdateState = getOrUpdateState;
    _ref.onDispose(() => _listStreamSubscription?.cancel());
  }

  Future<void> getInitialList([Param? param]) async {
    _parameter = param;
    _resetPagination();
    await _getListOn(
      page: 1,
      currentList: [],
      parameter: _parameter,
    );
  }

  Future<void> getNextPage() async {
    if (_lastPaginatedList?.isLast ?? false) return;
    if (_getOrUpdateState() is PaginatedLoadingMore) return;
    final currentList = switch (_getOrUpdateState()) {
      PaginatedLoaded<Entity>(list: final list) => list,
      PaginatedError<Entity>(list: final list) => list,
      _ => <Entity>[],
    };

    _getOrUpdateState(newState: PaginatedState.loadingMore(currentList));
    final nextPage = (_lastPaginatedList?.page ?? 0) + 1;
    await _getListOn(
      page: nextPage,
      parameter: _parameter,
      currentList: currentList,
    );
  }

  Future<void> refresh() => getInitialList(_parameter);

  @protected
  PaginatedStreamFailureOr<Entity> getListStreamOrFailure(
    int page, [
    Param? parameter,
  ]);

  Future<void> _getListOn({
    required int page,
    required List<Entity> currentList,
    Param? parameter,
  }) async {
    var updatedList = currentList;
    _listStreamSubscription?.cancel();
    _listStreamSubscription =
        getListStreamOrFailure(page, parameter).listen((result) {
      result.fold(
        (failure) {
          if (_useGlobalFailure) {
            _ref.read(globalFailureProvider.notifier).update((_) => failure);
          }
          _getOrUpdateState(
            newState: PaginatedState.error(updatedList, failure),
          );
        },
        (paginatedList) {
          _lastPaginatedList = paginatedList;
          updatedList = currentList + paginatedList.data;
          _getOrUpdateState(
            newState: PaginatedState.loaded(
              updatedList,
              isLastPage: paginatedList.isLast,
            ),
          );
        },
      );
    });
    return _listStreamSubscription?.asFuture();
  }

  void _resetPagination() {
    if (_initialized) {
      _getOrUpdateState(newState: const PaginatedState.loading());
    }
    _lastPaginatedList = null;
    _listStreamSubscription?.cancel();
  }
}
