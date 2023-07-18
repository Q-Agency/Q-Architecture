// ignore_for_file: always_use_package_imports

import 'package:equatable/equatable.dart';

import '../entities/failure.dart';

sealed class BaseState<State> extends Equatable {
  const BaseState();

  const factory BaseState.initial() = Initial;
  const factory BaseState.loading() = Loading;
  const factory BaseState.error(Failure failure) = Error;
  const factory BaseState.data(State data) = Data;
}

final class Initial<State> extends BaseState<State> {
  const Initial();

  @override
  List<Object?> get props => [];
}

final class Loading<State> extends BaseState<State> {
  const Loading();

  @override
  List<Object?> get props => [];
}

final class Error<State> extends BaseState<State> {
  final Failure failure;

  const Error(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class Data<State> extends BaseState<State> {
  final State data;

  const Data(this.data);

  @override
  List<Object?> get props => [data];
}
