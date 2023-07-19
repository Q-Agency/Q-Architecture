import 'package:equatable/equatable.dart';
import 'package:q_architecture/q_architecture.dart';

sealed class PaginatedState<T> extends Equatable {
  const PaginatedState();

  const factory PaginatedState.loading() = PaginatedLoading;
  const factory PaginatedState.loadingMore(List<T> list) = LoadingMore;
  const factory PaginatedState.loaded(List<T> list, {bool isLastPage}) = Loaded;
  const factory PaginatedState.error(List<T> list, Failure failure) =
      PaginatedError;
}

final class PaginatedLoading<T> extends PaginatedState<T> {
  const PaginatedLoading();

  @override
  List<Object?> get props => [];
}

final class LoadingMore<T> extends PaginatedState<T> {
  final List<T> list;
  const LoadingMore(this.list);

  @override
  List<Object?> get props => [list];
}

final class PaginatedError<T> extends PaginatedState<T> {
  final Failure failure;
  final List<T> list;

  const PaginatedError(this.list, this.failure);

  @override
  List<Object?> get props => [list, failure];
}

final class Loaded<T> extends PaginatedState<T> {
  final List<T> list;
  final bool isLastPage;

  const Loaded(
    this.list, {
    this.isLastPage = false,
  });

  @override
  List<Object?> get props => [list];
}
