import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_architecture/src/domain/mixins/paginated_stream_notifier_mixin.dart';
import 'package:q_architecture/src/domain/mixins/simple_notifier_mixin.dart';
import 'package:q_architecture/src/domain/notifiers/paginated_state.dart';

abstract class PaginatedStreamNotifier<Entity, Param>
    extends Notifier<PaginatedState<Entity>>
    with SimpleNotifierMixin, PaginatedStreamNotifierMixin<Entity, Param> {
  ({PaginatedState<Entity> initialState, bool useGlobalFailure})
      prepareForBuild();

  /// do not override in child classes, use prepareForBuild instead
  @nonVirtual
  @override
  PaginatedState<Entity> build() {
    initWithRefAndGetOrUpdateState(
      ref,
      ({newState}) {
        if (newState != null) state = newState;
        return state;
      },
    );
    final data = prepareForBuild();
    setUserGlobalFailure(data.useGlobalFailure);
    return data.initialState;
  }
}

abstract class AutoDisposePaginatedStreamNotifier<Entity, Param>
    extends AutoDisposeNotifier<PaginatedState<Entity>>
    with SimpleNotifierMixin, PaginatedStreamNotifierMixin<Entity, Param> {
  ({PaginatedState<Entity> initialState, bool useGlobalFailure})
      prepareForBuild();

  /// do not override in child classes, use prepareForBuild instead
  @nonVirtual
  @override
  PaginatedState<Entity> build() {
    initWithRefAndGetOrUpdateState(
      ref,
      ({newState}) {
        if (newState != null) state = newState;
        return state;
      },
    );
    final data = prepareForBuild();
    setUserGlobalFailure(data.useGlobalFailure);
    return data.initialState;
  }
}

abstract class FamilyPaginatedStreamNotifier<Entity, Param, Arg>
    extends FamilyNotifier<PaginatedState<Entity>, Arg>
    with SimpleNotifierMixin, PaginatedStreamNotifierMixin<Entity, Param> {
  ({PaginatedState<Entity> initialState, bool useGlobalFailure})
      prepareForBuild(Arg arg);

  /// do not override in child classes, use prepareForBuild instead
  @nonVirtual
  @override
  PaginatedState<Entity> build(Arg arg) {
    initWithRefAndGetOrUpdateState(
      ref,
      ({newState}) {
        if (newState != null) state = newState;
        return state;
      },
    );
    final data = prepareForBuild(arg);
    setUserGlobalFailure(data.useGlobalFailure);
    return data.initialState;
  }
}

abstract class AutoDisposeFamilyPaginatedStreamNotifier<Entity, Param, Arg>
    extends AutoDisposeFamilyNotifier<PaginatedState<Entity>, Arg>
    with SimpleNotifierMixin, PaginatedStreamNotifierMixin<Entity, Param> {
  ({PaginatedState<Entity> initialState, bool useGlobalFailure})
      prepareForBuild(Arg arg);

  /// do not override in child classes, use prepareForBuild instead
  @nonVirtual
  @override
  PaginatedState<Entity> build(Arg arg) {
    initWithRefAndGetOrUpdateState(
      ref,
      ({newState}) {
        if (newState != null) state = newState;
        return state;
      },
    );
    final data = prepareForBuild(arg);
    setUserGlobalFailure(data.useGlobalFailure);
    return data.initialState;
  }
}
