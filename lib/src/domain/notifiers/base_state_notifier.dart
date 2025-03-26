// ignore_for_file: always_use_package_imports

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/q_architecture.dart';
import 'package:q_architecture/src/domain/mixins/base_notifier_mixin.dart';

import 'base_state.dart';

typedef BaseStateNotifierProvider<Notifier extends StateNotifier<BaseState<T>>,
        T>
    = StateNotifierProvider<Notifier, BaseState<T>>;

@Deprecated('Use BaseNotifier instead')
abstract class BaseStateNotifier<DataState>
    extends SimpleStateNotifier<BaseState<DataState>>
    with BaseNotifierMixin<DataState> {
  @override
  BaseStateNotifier(Ref ref) : super(ref, const BaseState.initial()) {
    initWithRefAndGetOrUpdateState(ref, ({newState}) {
      if (newState != null) state = newState;
      return state;
    });
  }
}
