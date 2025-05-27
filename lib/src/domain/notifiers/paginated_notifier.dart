import 'package:either_dart/either.dart';
import 'package:meta/meta.dart';
import 'package:q_architecture/q_architecture.dart';

typedef PaginatedEitherFailureOr<Entity> =
    Future<Either<Failure, PaginatedList<Entity>>>;

abstract class PaginatedNotifier<Entity, Param>
    extends PaginatedStreamNotifier<Entity, Param> {
  PaginatedNotifier(
    super.initialState, {
    super.useGlobalFailure,
    super.autoDispose,
  });

  ///Gets the list or failure, needs to be implemented by the subclass
  @protected
  PaginatedEitherFailureOr<Entity> getListOrFailure(
    int page, [
    Param? parameter,
  ]);

  @override
  PaginatedStreamFailureOr<Entity> getListStreamOrFailure(
    int page, [
    Param? parameter,
  ]) => getListOrFailure(page, parameter).asStream();
}
