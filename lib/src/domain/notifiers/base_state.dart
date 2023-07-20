// ignore_for_file: always_use_package_imports

import 'package:equatable/equatable.dart';

import '../entities/failure.dart';

sealed class BaseState<State> extends Equatable {
  const BaseState();

  const factory BaseState.initial() = BaseInitial;
  const factory BaseState.loading() = BaseLoading;
  const factory BaseState.error(Failure failure) = BaseError;
  const factory BaseState.data(State data) = BaseData;
}

final class BaseInitial<State> extends BaseState<State> {
  const BaseInitial();

  @override
  List<Object?> get props => [];
}

final class BaseLoading<State> extends BaseState<State> {
  const BaseLoading();

  @override
  List<Object?> get props => [];
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
