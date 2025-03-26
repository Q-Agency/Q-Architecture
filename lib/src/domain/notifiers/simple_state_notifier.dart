// ignore_for_file: always_use_package_imports

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/src/domain/mixins/simple_notifier_mixin.dart';

@Deprecated('Use SimpleNotifier instead')
abstract class SimpleStateNotifier<T> extends StateNotifier<T>
    with SimpleNotifierMixin {
  final Ref ref;
  SimpleStateNotifier(this.ref, T initialState) : super(initialState) {
    initWithRef(ref);
  }
}
