// ignore_for_file: always_use_package_imports

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/paginated_notifier.dart';

import '../../../data/repositories/example_repository.dart';

final paginatedNotifierProvider = NotifierProvider.autoDispose<
    ExamplePaginatedNotifier, PaginatedState<String>>(
  () => ExamplePaginatedNotifier(),
);

class ExamplePaginatedNotifier
    extends AutoDisposePaginatedNotifier<String, Object> {
  late ExampleRepository _repository;

  @override
  ({PaginatedState<String> initialState, bool useGlobalFailure})
      prepareForBuild() {
    _repository = ref.read(exampleRepositoryProvider);
    getInitialList();
    return (
      initialState: const PaginatedState.loading(),
      useGlobalFailure: true
    );
  }

  @override
  PaginatedEitherFailureOr<String> getListOrFailure(
    int page, [
    Object? parameter,
  ]) =>
      _repository.getPaginatedResult(page);
}
