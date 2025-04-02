import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_architecture/paginated_notifier.dart';
import 'package:q_architecture/q_architecture.dart';
import 'package:q_architecture/src/domain/mixins/paginated_stream_notifier_mixin.dart';

typedef PaginatedStreamFailureOr<Entity>
    = Stream<Either<Failure, PaginatedList<Entity>>>;

@Deprecated('Use PaginatedStreamNotifier instead')
abstract class PaginatedStreamStateNotifier<Entity, Param>
    extends SimpleStateNotifier<PaginatedState<Entity>>
    with PaginatedStreamNotifierMixin<Entity, Param> {
  @override
  PaginatedStreamStateNotifier(
    Ref ref,
    PaginatedState<Entity> initialState, {
    bool useGlobalFailure = false,
  }) : super(ref, initialState) {
    initWithRefUseGlobalFailureAndGetOrUpdateState(ref, useGlobalFailure, ({
      newState,
    }) {
      if (newState != null) state = newState;
      return state;
    });
  }
}
