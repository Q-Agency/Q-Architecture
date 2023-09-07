import 'package:dio/dio.dart';
import 'package:q_architecture/q_architecture.dart';
import 'package:q_architecture/src/extensions/iterable_extensions.dart';

class ApiErrorResolver implements ErrorResolver {
  final Map<int, Failure> failures;

  const ApiErrorResolver({
    required this.failures,
  });

  @override
  Failure resolve<T>(Object error, [StackTrace? stackTrace]) {
    if (error is! DioException)
      return Failure.generic(
        error: error,
        stackTrace: stackTrace,
      );
    final response = error.response;
    final key =
        failures.keys.firstWhereOrNull((code) => code == response?.statusCode);
    return failures[key] ??
        Failure.generic(
          error: error,
          stackTrace: stackTrace,
        );
  }
}
