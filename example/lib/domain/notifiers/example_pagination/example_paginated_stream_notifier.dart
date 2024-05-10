// ignore_for_file: always_use_package_imports

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/paginated_notifier.dart';

import '../../../data/repositories/example_repository.dart';

final paginatedStreamNotifierProvider = NotifierProvider.autoDispose<
    ExamplePaginatedStreamNotifier, PaginatedState<String>>(
  () => ExamplePaginatedStreamNotifier(),
);

class ExamplePaginatedStreamNotifier
    extends AutoDisposePaginatedStreamNotifier<String, Object> {
  late ExampleRepository _repository;

  @override
  ({PaginatedState<String> initialState, bool useGlobalFailure})
      prepareForBuild() {
    _repository = ref.read(exampleRepositoryProvider);
    getInitialList();
    return (
      initialState: const PaginatedState.loading(),
      useGlobalFailure: false
    );
  }

  @override
  PaginatedStreamFailureOr<String> getListStreamOrFailure(
    int page, [
    Object? parameter,
  ]) =>
      _repository.getPaginatedStreamResult(page);
}
