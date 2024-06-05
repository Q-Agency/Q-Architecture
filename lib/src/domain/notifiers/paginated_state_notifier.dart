import 'package:either_dart/either.dart';
import 'package:q_architecture/paginated_notifier.dart';
import 'package:q_architecture/q_architecture.dart';
import 'package:q_architecture/src/domain/mixins/paginated_notifier_mixin.dart';

typedef PaginatedEitherFailureOr<Entity>
    = Future<Either<Failure, PaginatedList<Entity>>>;

abstract class PaginatedStateNotifier<Entity, Param>
    extends PaginatedStreamStateNotifier<Entity, Param>
    with PaginatedNotifierMixin<Entity, Param> {
  PaginatedStateNotifier(
    super.ref,
    super.initialState, {
    super.useGlobalFailure,
  });
}
