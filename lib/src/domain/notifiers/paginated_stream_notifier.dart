import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:meta/meta.dart';
import 'package:q_architecture/q_architecture.dart';

typedef PaginatedStreamFailureOr<Entity>
    = Stream<Either<Failure, PaginatedList<Entity>>>;

abstract class PaginatedStreamNotifier<Entity, Param>
    extends QNotifier<PaginatedState<Entity>> {
  final bool _useGlobalFailure;
  PaginatedList<Entity>? _lastPaginatedList;
  Param? _parameter;
  StreamSubscription? _listStreamSubscription;

  PaginatedStreamNotifier(
    super.initialState, {
    bool useGlobalFailure = false,
    super.autoDispose,
  }) : _useGlobalFailure = useGlobalFailure;

  ///Gets the initial list
  ///[param] - the optional parameter to get the initial list
  Future<void> getInitialList([Param? param]) async {
    _parameter = param;
    _resetPagination();
    await _getListOn(page: 1, currentList: [], parameter: _parameter);
  }

  @override
  void dispose() {
    _listStreamSubscription?.cancel();
    super.dispose();
  }

  ///Gets the next page
  Future<void> getNextPage() async {
    if (_lastPaginatedList?.isLast ?? false) return;
    if (state is PaginatedLoadingMore) return;
    final currentList = switch (state) {
      PaginatedLoaded<Entity>(list: final list) => list,
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

  ///Refreshes the list to the initial state
  Future<void> refresh() => getInitialList(_parameter);

  ///Gets the list stream or failure, needs to be implemented by the subclass
  ///[page] - the page number
  ///[parameter] - the optional parameter
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
    _listStreamSubscription = getListStreamOrFailure(page, parameter).listen((
      result,
    ) {
      result.fold(
        (failure) {
          if (_useGlobalFailure) {
            setGlobalFailure(failure);
          }
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
    state = PaginatedState.loading();
    _lastPaginatedList = null;
    _listStreamSubscription?.cancel();
  }
}
