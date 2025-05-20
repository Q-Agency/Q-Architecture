import 'package:example/data/repositories/example_repository.dart';
import 'package:q_architecture/q_architecture.dart';

class ExamplePaginatedNotifier extends PaginatedNotifier<String, Object> {
  final ExampleRepository _repository;

  ExamplePaginatedNotifier(this._repository, {super.autoDispose})
      : super(const PaginatedState.loading(), useGlobalFailure: true) {
    getInitialList();
  }

  @override
  PaginatedEitherFailureOr<String> getListOrFailure(
    int page, [
    Object? parameter,
  ]) =>
      _repository.getPaginatedResult(page);
}
