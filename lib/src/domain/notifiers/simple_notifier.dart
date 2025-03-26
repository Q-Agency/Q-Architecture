import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/src/domain/mixins/simple_notifier_mixin.dart';

abstract class SimpleNotifier<T> extends Notifier<T> with SimpleNotifierMixin {
  T prepareForBuild();

  /// do not override in child classes, use prepareForBuild instead
  @nonVirtual
  @override
  T build() {
    initWithRef(ref);
    return prepareForBuild();
  }
}

abstract class AutoDisposeSimpleNotifier<T> extends AutoDisposeNotifier<T>
    with SimpleNotifierMixin {
  T prepareForBuild();

  /// do not override in child classes, use prepareForBuild instead
  @nonVirtual
  @override
  T build() {
    initWithRef(ref);
    return prepareForBuild();
  }
}

abstract class FamilySimpleNotifier<T, Arg> extends FamilyNotifier<T, Arg>
    with SimpleNotifierMixin {
  T prepareForBuild(Arg arg);

  /// do not override in child classes, use prepareForBuild instead
  @nonVirtual
  @override
  T build(Arg arg) {
    initWithRef(ref);
    return prepareForBuild(arg);
  }
}

abstract class AutoDisposeFamilySimpleNotifier<T, Arg>
    extends AutoDisposeFamilyNotifier<T, Arg> with SimpleNotifierMixin {
  T prepareForBuild(Arg arg);

  /// do not override in child classes, use prepareForBuild instead
  @nonVirtual
  @override
  T build(Arg arg) {
    initWithRef(ref);
    return prepareForBuild(arg);
  }
}
