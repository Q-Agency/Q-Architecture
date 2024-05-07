import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/base_state_notifier.dart';
import 'package:q_architecture/src/domain/mixins/base_notifier_mixin.dart';
import 'package:q_architecture/src/domain/mixins/simple_notifier_mixin.dart';

abstract class BaseNotifier<T> extends Notifier<BaseState<T>>
    with SimpleNotifierMixin, BaseNotifierMixin<T> {
  void prepareForBuild();

  /// do not override in child classes, use prepareForBuild instead
  @nonVirtual
  @override
  BaseState<T> build() {
    initWithRefAndGetOrUpdateState(
      ref,
      ({newState}) {
        if (newState != null) state = newState;
        return state;
      },
    );
    prepareForBuild();
    return const BaseState.initial();
  }
}

abstract class AutoDisposeBaseNotifier<T>
    extends AutoDisposeNotifier<BaseState<T>>
    with SimpleNotifierMixin, BaseNotifierMixin<T> {
  void prepareForBuild();

  /// do not override in child classes, use prepareForBuild instead
  @nonVirtual
  @override
  BaseState<T> build() {
    initWithRefAndGetOrUpdateState(
      ref,
      ({newState}) {
        if (newState != null) state = newState;
        return state;
      },
    );
    prepareForBuild();
    return const BaseState.initial();
  }
}

abstract class FamilyBaseNotifier<T, Arg>
    extends FamilyNotifier<BaseState<T>, Arg>
    with SimpleNotifierMixin, BaseNotifierMixin<T> {
  void prepareForBuild(Arg arg);

  /// do not override in child classes, use prepareForBuild instead
  @nonVirtual
  @override
  BaseState<T> build(Arg arg) {
    initWithRefAndGetOrUpdateState(
      ref,
      ({newState}) {
        if (newState != null) state = newState;
        return state;
      },
    );
    prepareForBuild(arg);
    return const BaseState.initial();
  }
}

abstract class AutoDisposeFamilyBaseNotifier<T, Arg>
    extends AutoDisposeFamilyNotifier<BaseState<T>, Arg>
    with SimpleNotifierMixin, BaseNotifierMixin<T> {
  void prepareForBuild(Arg arg);

  /// do not override in child classes, use prepareForBuild instead
  @nonVirtual
  @override
  BaseState<T> build(Arg arg) {
    initWithRefAndGetOrUpdateState(
      ref,
      ({newState}) {
        if (newState != null) state = newState;
        return state;
      },
    );
    prepareForBuild(arg);
    return const BaseState.initial();
  }
}
