import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/paginated_notifier.dart';
import 'package:q_architecture/q_architecture.dart';

class PaginatedListView<Entity, Param> extends ConsumerWidget {
  final Widget? Function(BuildContext, Entity) itemBuilder;
  final AutoDisposeStateNotifierProvider<PaginatedStreamNotifier<Entity, Param>,
      PaginatedState<Entity>>? autoDisposeStateNotifier;
  final StateNotifierProvider<PaginatedStreamNotifier<Entity, Param>,
      PaginatedState<Entity>>? stateNotifierProvider;
  final Widget Function(Widget child, Future<void> Function() onRefresh)?
      refreshWidgetBuilder;
  final Widget Function(Future<void> Function() onRefresh) emptyListBuilder;
  final Widget? Function(
    Failure failure,
    bool listIsEmpty,
    Future<void> Function() onRefresh,
  )? onError;
  final Widget? loading;
  final Widget? loadingMore;
  final EdgeInsets? listPadding;
  final Widget? separator;
  final double? spacing;
  final Axis scrollDirection;
  final PaginatedListViewType paginatedListViewType;
  final Widget Function(VoidCallback onLoadMore)? loadMoreButtonBuilder;
  final ScrollPhysics? scrollPhysics;

  const PaginatedListView({
    required this.itemBuilder,
    required this.emptyListBuilder,
    this.autoDisposeStateNotifier,
    this.stateNotifierProvider,
    this.refreshWidgetBuilder,
    this.onError,
    this.loading,
    this.loadingMore,
    this.listPadding,
    this.separator,
    this.spacing,
    this.scrollDirection = Axis.vertical,
    this.paginatedListViewType = PaginatedListViewType.infiniteScroll,
    this.loadMoreButtonBuilder,
    this.scrollPhysics,
    super.key,
  }) : assert(
            autoDisposeStateNotifier != null || stateNotifierProvider != null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedState = ref.watch(stateNotifier);
    Widget getRefreshWidget(child) =>
        refreshWidgetBuilder?.call(child, () async => _refresh(ref)) ??
        RefreshIndicator(
          onRefresh: () async => _refresh(ref),
          child: child,
        );
    Widget getListEmpty() => emptyListBuilder.call(() async => _refresh(ref));

    Widget? getLoadMoreButton(bool isLastPage) =>
        paginatedListViewType == PaginatedListViewType.loadMoreButton &&
                loadMoreButtonBuilder != null &&
                !isLastPage
            ? loadMoreButtonBuilder!(() => _getNextPage(ref))
            : null;

    return switch (paginatedState) {
      PaginatedLoadingMore<Entity>(list: final list) => _ListView(
          itemBuilder: itemBuilder,
          list: list,
          isLoading: true,
          loading: loadingMore,
          listPadding: listPadding,
          scrollDirection: scrollDirection,
          spacing: spacing,
          separator: separator,
          refreshWidgetBuilder: getRefreshWidget,
          emptyListBuilder: getListEmpty,
          onNotification: (info) => _onScrollNotification(info, ref),
          scrollPhysics: scrollPhysics,
        ),
      PaginatedLoaded(list: final list, isLastPage: final isLastPage) =>
        _ListView(
          itemBuilder: itemBuilder,
          list: list,
          listPadding: listPadding,
          scrollDirection: scrollDirection,
          spacing: spacing,
          separator: separator,
          refreshWidgetBuilder: getRefreshWidget,
          emptyListBuilder: getListEmpty,
          onNotification: (info) => _onScrollNotification(info, ref),
          loadMoreButtonBuilder: () => getLoadMoreButton(isLastPage),
          scrollPhysics: scrollPhysics,
        ),
      PaginatedLoading() => loading ??
          const Center(
            child: CircularProgressIndicator(),
          ),
      PaginatedError(list: final list, failure: final failure) =>
        onError?.call(failure, list.isEmpty, () async => _refresh(ref)) ??
            _ListView(
              itemBuilder: itemBuilder,
              list: list,
              listPadding: listPadding,
              scrollDirection: scrollDirection,
              spacing: spacing,
              separator: separator,
              refreshWidgetBuilder: getRefreshWidget,
              emptyListBuilder: getListEmpty,
              onNotification: (info) => _onScrollNotification(info, ref),
              loadMoreButtonBuilder: () => getLoadMoreButton(false),
              scrollPhysics: scrollPhysics,
            ),
    };
  }

  ProviderListenable<PaginatedState<Entity>> get stateNotifier =>
      autoDisposeStateNotifier ?? stateNotifierProvider!;

  // ignore: member-ordering
  bool _onScrollNotification(ScrollNotification scrollInfo, WidgetRef ref) {
    if (paginatedListViewType == PaginatedListViewType.infiniteScroll &&
        scrollInfo.shouldLoadMore) {
      _getNextPage(ref);
    }
    return scrollInfo.depth == 0;
  }

  // ignore: member-ordering
  void _getNextPage(WidgetRef ref) {
    if (autoDisposeStateNotifier != null) {
      ref.read(autoDisposeStateNotifier!.notifier).getNextPage();
    } else {
      ref.read(stateNotifierProvider!.notifier).getNextPage();
    }
  }

  // ignore: member-ordering
  void _refresh(WidgetRef ref) {
    if (autoDisposeStateNotifier != null) {
      ref.read(autoDisposeStateNotifier!.notifier).refresh();
    } else {
      ref.read(stateNotifierProvider!.notifier).refresh();
    }
  }
}

enum PaginatedListViewType { infiniteScroll, loadMoreButton }

class _ListView<Entity> extends StatelessWidget {
  final Widget? Function(BuildContext, Entity) itemBuilder;
  final Widget Function(Widget child) refreshWidgetBuilder;
  final Widget Function() emptyListBuilder;
  final Widget? Function()? loadMoreButtonBuilder;
  final List<Entity> list;
  final bool Function(ScrollNotification) onNotification;
  final Widget? loading;
  final bool isLoading;
  final EdgeInsets? listPadding;
  final Widget? separator;
  final double? spacing;
  final Axis scrollDirection;
  final ScrollPhysics? scrollPhysics;

  const _ListView({
    required this.itemBuilder,
    required this.list,
    required this.refreshWidgetBuilder,
    required this.emptyListBuilder,
    this.loadMoreButtonBuilder,
    required this.onNotification,
    this.loading,
    this.isLoading = false,
    this.listPadding,
    this.separator,
    this.spacing,
    required this.scrollDirection,
    this.scrollPhysics,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return list.isNotEmpty
        ? NotificationListener(
            onNotification: onNotification,
            child: refreshWidgetBuilder(ListView.separated(
              physics: scrollPhysics,
              padding: listPadding,
              scrollDirection: scrollDirection,
              itemBuilder: (context, index) {
                if (index == list.length + 1) {
                  return isLoading
                      ? loading ??
                          const Center(child: CircularProgressIndicator())
                      : const SizedBox();
                }
                if (index == list.length) {
                  return loadMoreButtonBuilder?.call() ?? const SizedBox();
                }
                return itemBuilder(context, list[index]);
              },
              itemCount: list.length + 2,
              separatorBuilder: (_, index) => index < list.length - 1
                  ? separator ?? SizedBox(height: spacing ?? 10)
                  : const SizedBox(),
            )),
          )
        : emptyListBuilder();
  }
}

extension PaginatedScrollNotification on ScrollNotification {
  static const _loadMoreScrollOffset = 50;
  bool get shouldLoadMore =>
      metrics.pixels >= metrics.maxScrollExtent - _loadMoreScrollOffset;
}
