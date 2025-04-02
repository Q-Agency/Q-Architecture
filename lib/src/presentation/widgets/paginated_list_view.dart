import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_architecture/paginated_notifier.dart';
import 'package:q_architecture/q_architecture.dart';
import 'package:q_architecture/src/domain/mixins/paginated_stream_notifier_mixin.dart';

class PaginatedListView<Entity, Param, Arg> extends ConsumerWidget {
  /// required [itemBuilder] used for displaying each item in the scroll view,
  /// provides [context], [item] object and its [index] within the list of items
  final Widget? Function(BuildContext context, Entity item, int index)
      itemBuilder;
  final AutoDisposeNotifierProvider<
      AutoDisposePaginatedStreamNotifier<Entity, Param>,
      PaginatedState<Entity>>? autoDisposeStreamNotifierProvider;
  final AutoDisposeFamilyNotifierProvider<
      AutoDisposeFamilyPaginatedStreamNotifier<Entity, Param, Arg>,
      PaginatedState<Entity>,
      Arg>? autoDisposeFamilyStreamNotifierProvider;
  final NotifierFamilyProvider<
      FamilyPaginatedStreamNotifier<Entity, Param, Arg>,
      PaginatedState<Entity>,
      Arg>? familyStreamNotifierProvider;
  final NotifierProvider<PaginatedStreamNotifier<Entity, Param>,
      PaginatedState<Entity>>? streamNotifierProvider;
  final AutoDisposeNotifierProvider<AutoDisposePaginatedNotifier<Entity, Param>,
      PaginatedState<Entity>>? autoDisposeNotifierProvider;
  final AutoDisposeFamilyNotifierProvider<
      AutoDisposeFamilyPaginatedNotifier<Entity, Param, Arg>,
      PaginatedState<Entity>,
      Arg>? autoDisposeFamilyNotifierProvider;
  final NotifierFamilyProvider<FamilyPaginatedNotifier<Entity, Param, Arg>,
      PaginatedState<Entity>, Arg>? familyNotifierProvider;
  final NotifierProvider<PaginatedNotifier<Entity, Param>,
      PaginatedState<Entity>>? notifierProvider;
  final AutoDisposeStateNotifierProvider<
      PaginatedStreamStateNotifier<Entity, Param>,
      PaginatedState<Entity>>? autoDisposeStateNotifierProvider;
  final StateNotifierProvider<PaginatedStreamStateNotifier<Entity, Param>,
      PaginatedState<Entity>>? stateNotifierProvider;

  /// optional builder to customize displaying the refresh functionality on
  /// top of the scrollbar when scroll view is dragged all the way to the top,
  /// defaults to RefreshIndicator
  final Widget Function(
    Future<void> Function() onRefresh,
    Widget child,
  )? refreshWidgetBuilder;

  /// optional builder for displaying Scrollbar or some other custom
  /// scroll bar widget
  final Widget Function(
    ScrollController controller,
    Widget child,
  )? scrollbarWidgetBuilder;
  final Widget Function(Future<void> Function() onRefresh) emptyListBuilder;

  /// optional [onError] callback, provides [failure], information if
  /// an error occurred while the list was empty or not via [listIsEmpty]
  /// and [onRefresh] callback to easily trigger fetching the initial list again
  final Widget? Function(
    Failure failure,
    bool listIsEmpty,
    Future<void> Function() onRefresh,
  )? onError;

  /// optional [loading] widget to be shown before first page is fetched,
  /// defaults to CircularProgressIndicator()
  final Widget? loading;

  /// optional [loadingMore] widget for displaying loader on the bottom of the scroll view
  /// when fetching the next page if [paginatedListViewType] is set to [PaginatedListViewType.infiniteScroll],
  /// defaults to CircularProgressIndicator()
  final Widget? loadingMore;
  final EdgeInsets? listPadding;

  /// optional separator widget to be displayed between two items,
  /// if given spacing attribute will be ignored
  final Widget? separator;

  /// optional [spacing] between the items, defaults to 10px,
  /// will be ignored if separator is given
  final double? spacing;
  final Axis scrollDirection;

  /// [paginatedListViewType] attribute, determines a way to load more items,
  /// automatically while scrolling if [PaginatedListViewType.infiniteScroll] is used or
  /// via load more button if [PaginatedListViewType.loadMoreButton] is used,
  /// defaults to [PaginatedListViewType.infiniteScroll]
  final PaginatedListViewType paginatedListViewType;

  /// optional [loadMoreButtonBuilder] callback for displaying load more widget
  /// on the bottom of the scroll view to the fetch next page by clicking on it,
  /// provides [onLoadMore] callback to the fetch next page,
  /// should not be null if [paginatedListViewType] is set to [PaginatedListViewType.loadMoreButton],
  /// otherwise there will be no way to fetch the next page
  final Widget Function(VoidCallback onLoadMore)? loadMoreButtonBuilder;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;

  const PaginatedListView({
    required this.itemBuilder,
    required this.emptyListBuilder,
    this.autoDisposeStreamNotifierProvider,
    this.autoDisposeFamilyStreamNotifierProvider,
    this.familyStreamNotifierProvider,
    this.streamNotifierProvider,
    this.autoDisposeNotifierProvider,
    this.notifierProvider,
    this.autoDisposeFamilyNotifierProvider,
    this.familyNotifierProvider,
    this.autoDisposeStateNotifierProvider,
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
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedState = ref.watch(commonNotifierProvider);
    Widget getRefreshWidget({required Widget child}) =>
        refreshWidgetBuilder?.call(
          () async => _refresh(ref),
          child,
        ) ??
        RefreshIndicator(onRefresh: () async => _refresh(ref), child: child);
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
    final onFetchMore =
        paginatedListViewType == PaginatedListViewType.infiniteScroll
            ? () => _getNextPage(ref)
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
          onFetchMore: onFetchMore,
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
          onFetchMore: onFetchMore,
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
              onFetchMore: onFetchMore,
            ),
    };
  }

  ProviderListenable<PaginatedState<Entity>> get commonNotifierProvider {
    assert(
      [
            autoDisposeStreamNotifierProvider,
            autoDisposeFamilyStreamNotifierProvider,
            familyStreamNotifierProvider,
            streamNotifierProvider,
            autoDisposeNotifierProvider,
            notifierProvider,
            autoDisposeFamilyNotifierProvider,
            familyNotifierProvider,
            autoDisposeStateNotifierProvider,
            stateNotifierProvider,
          ].where((param) => param != null).length ==
          1,
      'Only one provider should be provided at a time.',
    );
    return autoDisposeStreamNotifierProvider ??
        autoDisposeFamilyStreamNotifierProvider ??
        familyStreamNotifierProvider ??
        streamNotifierProvider ??
        autoDisposeNotifierProvider ??
        notifierProvider ??
        autoDisposeFamilyNotifierProvider ??
        familyNotifierProvider ??
        autoDisposeStateNotifierProvider ??
        stateNotifierProvider!;
  }

  Refreshable<PaginatedStreamNotifierMixin> get commonNotifier {
    if (autoDisposeStreamNotifierProvider != null) {
      return autoDisposeStreamNotifierProvider!.notifier;
    }
    if (autoDisposeFamilyStreamNotifierProvider != null) {
      return autoDisposeFamilyStreamNotifierProvider!.notifier;
    }
    if (familyStreamNotifierProvider != null) {
      return familyStreamNotifierProvider!.notifier;
    }
    if (streamNotifierProvider != null) {
      return streamNotifierProvider!.notifier;
    }
    if (autoDisposeNotifierProvider != null) {
      return autoDisposeNotifierProvider!.notifier;
    }
    if (notifierProvider != null) {
      return notifierProvider!.notifier;
    }
    if (autoDisposeFamilyNotifierProvider != null) {
      return autoDisposeFamilyNotifierProvider!.notifier;
    }
    if (autoDisposeStateNotifierProvider != null) {
      return autoDisposeStateNotifierProvider!.notifier;
    }
    if (familyNotifierProvider != null) {
      return familyNotifierProvider!.notifier;
    }
    return stateNotifierProvider!.notifier;
  }

  bool _onScrollNotification(ScrollNotification scrollInfo, WidgetRef ref) {
    if (paginatedListViewType == PaginatedListViewType.infiniteScroll &&
        scrollInfo.shouldLoadMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _getNextPage(ref));
    }
    return scrollInfo.depth == 0;
  }

  void _getNextPage(WidgetRef ref) => ref.read(commonNotifier).getNextPage();

  void _refresh(WidgetRef ref) => ref.read(commonNotifier).refresh();
}

enum PaginatedListViewType { infiniteScroll, loadMoreButton }

class _ListView<Entity> extends StatefulWidget {
  final Widget? Function(BuildContext context, Entity item, int index)
      itemBuilder;
  final Widget Function({required Widget child}) refreshWidgetBuilder;
  final Widget Function({
    required ScrollController controller,
    required Widget child,
  }) scrollbarWidgetBuilder;
  final Widget Function() emptyListBuilder;
  final Widget? Function()? loadMoreButtonBuilder;
  final List<Entity> list;
  final bool Function(ScrollNotification notification) onNotification;
  final Widget? loading;
  final bool isLoading;
  final EdgeInsets? listPadding;
  final Widget? separator;
  final double? spacing;
  final Axis scrollDirection;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final VoidCallback? onFetchMore;

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
    this.onFetchMore,
    super.key,
  });

  @override
  State<_ListView<Entity>> createState() => _ListViewState<Entity>();
}

class _ListViewState<Entity> extends State<_ListView<Entity>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    // Schedule a check for scrollability after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfScrollable());
  }

  @override
  void didUpdateWidget(_ListView<Entity> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check scrollability when list changes
    if (widget.list.length != oldWidget.list.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfScrollable());
    }
  }

  void _checkIfScrollable() {
    if (_scrollController.hasClients && !_scrollController.isScrollable) {
      widget.onFetchMore?.call();
    }
  }

  @override
  void dispose() {
    // Only dispose the controller if we created it
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
                    return widget.itemBuilder(
                      context,
                      widget.list[index],
                      index,
                    );
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

extension _PaginatedScrollController on ScrollController {
  bool get isScrollable => position.maxScrollExtent > 0;
}
