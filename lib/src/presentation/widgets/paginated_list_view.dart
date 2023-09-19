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
  final Widget Function(
    Future<void> Function() onRefresh,
    Widget child,
  )? refreshWidgetBuilder;
  final Widget Function(
    ScrollController controller,
    Widget child,
  )? scrollbarWidgetBuilder;
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
  final ScrollController? scrollController;

  const PaginatedListView({
    required this.itemBuilder,
    required this.emptyListBuilder,
    this.autoDisposeStateNotifier,
    this.stateNotifierProvider,
    this.refreshWidgetBuilder,
    this.scrollbarWidgetBuilder,
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
    this.scrollController,
    super.key,
  }) : assert(
          autoDisposeStateNotifier != null || stateNotifierProvider != null,
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedState = ref.watch(stateNotifier);
    Widget getRefreshWidget({required Widget child}) =>
        refreshWidgetBuilder?.call(
          () async => _refresh(ref),
          child,
        ) ??
        RefreshIndicator(
          onRefresh: () async => _refresh(ref),
          child: child,
        );
    Widget getScrollbarWidget({
      required ScrollController controller,
      required Widget child,
    }) =>
        scrollbarWidgetBuilder?.call(controller, child) ?? child;
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
          scrollbarWidgetBuilder: getScrollbarWidget,
          emptyListBuilder: getListEmpty,
          onNotification: (info) => _onScrollNotification(info, ref),
          scrollPhysics: scrollPhysics,
          scrollController: scrollController,
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
          scrollbarWidgetBuilder: getScrollbarWidget,
          emptyListBuilder: getListEmpty,
          onNotification: (info) => _onScrollNotification(info, ref),
          loadMoreButtonBuilder: () => getLoadMoreButton(isLastPage),
          scrollPhysics: scrollPhysics,
          scrollController: scrollController,
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
              scrollbarWidgetBuilder: getScrollbarWidget,
              emptyListBuilder: getListEmpty,
              onNotification: (info) => _onScrollNotification(info, ref),
              loadMoreButtonBuilder: () => getLoadMoreButton(false),
              scrollPhysics: scrollPhysics,
              scrollController: scrollController,
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

class _ListView<Entity> extends StatefulWidget {
  final Widget? Function(BuildContext, Entity) itemBuilder;
  final Widget Function({required Widget child}) refreshWidgetBuilder;
  final Widget Function({
    required ScrollController controller,
    required Widget child,
  }) scrollbarWidgetBuilder;
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
  final ScrollController? scrollController;

  const _ListView({
    required this.itemBuilder,
    required this.list,
    required this.refreshWidgetBuilder,
    required this.scrollbarWidgetBuilder,
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
    this.scrollController,
    super.key,
  });

  @override
  State<_ListView<Entity>> createState() => _ListViewState<Entity>();
}

class _ListViewState<Entity> extends State<_ListView<Entity>> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.list.isNotEmpty
        ? NotificationListener(
            onNotification: widget.onNotification,
            child: widget.refreshWidgetBuilder(
              child: widget.scrollbarWidgetBuilder(
                controller: _scrollController,
                child: ListView.separated(
                  controller: _scrollController,
                  physics: widget.scrollPhysics,
                  padding: widget.listPadding,
                  scrollDirection: widget.scrollDirection,
                  itemBuilder: (context, index) {
                    if (index == widget.list.length + 1) {
                      return widget.isLoading
                          ? widget.loading ??
                              const Center(child: CircularProgressIndicator())
                          : const SizedBox();
                    }
                    if (index == widget.list.length) {
                      return widget.loadMoreButtonBuilder?.call() ??
                          const SizedBox();
                    }
                    return widget.itemBuilder(context, widget.list[index]);
                  },
                  itemCount: widget.list.length + 2,
                  separatorBuilder: (_, index) => index < widget.list.length - 1
                      ? widget.separator ??
                          SizedBox(height: widget.spacing ?? 10)
                      : const SizedBox(),
                ),
              ),
            ),
          )
        : widget.emptyListBuilder();
  }
}

extension _PaginatedScrollNotification on ScrollNotification {
  static const _loadMoreScrollOffset = 50;
  bool get shouldLoadMore =>
      metrics.pixels >= metrics.maxScrollExtent - _loadMoreScrollOffset;
}
