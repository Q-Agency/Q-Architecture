import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:q_architecture/paginated_notifier.dart';
import 'package:q_architecture/q_architecture.dart';

typedef PaginatedStreamFailureOr<Entity>
    = Stream<Either<Failure, PaginatedList<Entity>>>;

abstract class PaginatedStreamNotifier<Entity, Param>
    extends SimpleStateNotifier<PaginatedState<Entity>> {
  final bool useGlobalFailure;

  PaginatedList<Entity>? _lastPaginatedList;
  Param? _parameter;
  StreamSubscription? _listStreamSubscription;

  PaginatedStreamNotifier(
    super.ref,
    super.initialState, {
    this.useGlobalFailure = false,
  });

  @override
  void dispose() {
    _listStreamSubscription?.cancel();
    super.dispose();
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
    if (state is LoadingMore) return;
    final currentList = switch (state) {
      Loaded<Entity>(list: final list) => list,
      PaginatedError<Entity>(list: final list) => list,
      _ => <Entity>[],
    };

    state = PaginatedState.loadingMore(currentList);
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
          if (useGlobalFailure)
            ref.read(globalFailureProvider.notifier).update((_) => failure);
          state = PaginatedState.error(updatedList, failure);
        },
        (paginatedList) {
          _lastPaginatedList = paginatedList;
          updatedList = currentList + paginatedList.data;
          state = PaginatedState.loaded(
            updatedList,
            isLastPage: paginatedList.isLast,
          );
        },
      );
    });
    return _listStreamSubscription?.asFuture();
  }

  void _resetPagination() {
    state = const PaginatedState.loading();
    _lastPaginatedList = null;
    _listStreamSubscription?.cancel();
  }
}
