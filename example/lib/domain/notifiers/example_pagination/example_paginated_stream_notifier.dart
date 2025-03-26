import 'package:example/data/repositories/example_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/paginated_notifier.dart';

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
    _repository = ref.watch(exampleRepositoryProvider);
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
