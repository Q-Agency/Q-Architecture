import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:q_architecture/paginated_notifier.dart';
import 'package:q_architecture/q_architecture.dart';

typedef PaginatedEitherFailureOr<Entity>
    = Future<Either<Failure, PaginatedList<Entity>>>;

abstract class PaginatedNotifier<Entity, Param>
    extends PaginatedStreamNotifier<Entity, Param> {
  PaginatedNotifier(
    super.ref,
    super.initialState, {
    super.useGlobalFailure,
  });

  @protected
  PaginatedEitherFailureOr<Entity> getListOrFailure(
    int page, [
    Param? parameter,
  ]);

  @override
  PaginatedStreamFailureOr<Entity> getListStreamOrFailure(
    int page, [
    Param? parameter,
  ]) =>
      getListOrFailure(page, parameter).asStream();
}
