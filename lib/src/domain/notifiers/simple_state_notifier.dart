// ignore_for_file: always_use_package_imports

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/q_architecture.dart';

abstract class SimpleStateNotifier<T> extends StateNotifier<T>
    with SimpleNotifierController {
  final Ref ref;
  SimpleStateNotifier(this.ref, T initialState) : super(initialState) {
    initWithRef(ref);
  }
}
