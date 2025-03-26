import 'package:example/data/repositories/example_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/paginated_notifier.dart';

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
    _repository = ref.watch(exampleRepositoryProvider);
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
