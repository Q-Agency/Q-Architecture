import 'package:equatable/equatable.dart';
import 'package:q_architecture/q_architecture.dart';

sealed class ExampleSimpleState extends Equatable {
  const ExampleSimpleState();

  const factory ExampleSimpleState.initial() = Initial;
  const factory ExampleSimpleState.empty() = Empty;
  const factory ExampleSimpleState.fetching() = Fetching;
  const factory ExampleSimpleState.success(String sentence) = Success;
  const factory ExampleSimpleState.error(Failure failure) = Error;
}

final class Initial extends ExampleSimpleState {
  const Initial();

  @override
  List<Object?> get props => [];
}

final class Empty extends ExampleSimpleState {
  const Empty();

  @override
  List<Object?> get props => [];
}

final class Fetching extends ExampleSimpleState {
  const Fetching();

  @override
  List<Object?> get props => [];
}

final class Success extends ExampleSimpleState {
  final String sentence;
  const Success(this.sentence);

  @override
  List<Object?> get props => [];
}

final class Error<State> extends ExampleSimpleState {
  final Failure failure;

  const Error(this.failure);

  @override
  List<Object?> get props => [failure];
}
