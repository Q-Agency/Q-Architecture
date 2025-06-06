import 'package:equatable/equatable.dart';
import 'package:q_architecture/src/domain/entities/failure.dart';

sealed class BaseState<State> extends Equatable {
  const BaseState();

  const factory BaseState.initial() = BaseInitial;
  const factory BaseState.loading() = BaseLoading;
  const factory BaseState.error(Failure failure) = BaseError;
  const factory BaseState.data(State data) = BaseData;

  @override
  List<Object?> get props => [];
}

final class BaseInitial<State> extends BaseState<State> {
  const BaseInitial();
}

final class BaseLoading<State> extends BaseState<State> {
  const BaseLoading();
}

final class BaseError<State> extends BaseState<State> {
  final Failure failure;

  const BaseError(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class BaseData<State> extends BaseState<State> {
  final State data;

  const BaseData(this.data);

  @override
  List<Object?> get props => [data];
}
