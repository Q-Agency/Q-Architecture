import 'package:example/data/repositories/example_repository.dart';
import 'package:q_architecture/q_architecture.dart';

class ExamplePaginatedStreamNotifier
    extends PaginatedStreamNotifier<String, Object> {
  final ExampleRepository _repository;

  ExamplePaginatedStreamNotifier(this._repository, {super.autoDispose})
      : super(PaginatedState.loading()) {
    getInitialList();
  }

  @override
  PaginatedStreamFailureOr<String> getListStreamOrFailure(
    int page, [
    Object? parameter,
  ]) =>
      _repository.getPaginatedStreamResult(page);
}
