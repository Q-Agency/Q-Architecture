// ignore_for_file: always_use_package_imports

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/q_architecture.dart';

import '../../../data/repositories/example_repository.dart';
import 'example_simple_state.dart';

final exampleSimpleStateNotifierProvider = NotifierProvider.autoDispose<
    ExampleSimpleStateNotifier, ExampleSimpleState>(
  () => ExampleSimpleStateNotifier(),
);

class ExampleSimpleStateNotifier
    extends AutoDisposeSimpleNotifier<ExampleSimpleState> {
  late ExampleRepository _exampleRepository;

  @override
  ExampleSimpleState prepareForBuild() {
    _exampleRepository = ref.watch(exampleRepositoryProvider);
    return const ExampleSimpleState.initial();
  }

  /// Example method when you want to get state updates when calling some repository method
  Future<void> getSomeStringSimpleExample() async {
    await debounce();
    state = const ExampleSimpleState.fetching();
    final result = await _exampleRepository.getSomeString();
    result.fold(
      (failure) {
        state = ExampleSimpleState.error(failure);
      },
      (data) {
        if (data.isEmpty) {
          state = const ExampleSimpleState.empty();
        } else {
          state = ExampleSimpleState.success(data);
        }
      },
    );
  }

  /// Example method when you want to use global loading and global failure methods
  /// when calling some repository method
  Future<void> getSomeStringSimpleExampleGlobalLoading() async {
    showGlobalLoading();
    final result = await _exampleRepository.getSomeString();
    result.fold(
      (failure) {
        setGlobalFailure(failure);
      },
      (data) {
        clearGlobalLoading();
        if (data.isEmpty) {
          state = const ExampleSimpleState.empty();
        } else {
          state = ExampleSimpleState.success(data);
        }
      },
    );
  }
}
