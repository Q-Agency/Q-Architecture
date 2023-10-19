import 'package:dio/dio.dart';
import 'package:q_architecture/q_architecture.dart';

/// An implementation of the [ErrorResolver] interface.
///
/// Handles DioException errors by using the [statusCodeToFailure] map.
/// Returns Failure.generic if the status code is not handled by the [statusCodeToFailure] map.
final class ApiErrorResolver implements ErrorResolver {
  final Map<int, Failure> statusCodeToFailure;

  const ApiErrorResolver({
    required this.statusCodeToFailure,
  });

  @override
  Failure resolve<T>(Object error, [StackTrace? stackTrace]) {
    if (error is! DioException)
      return Failure.generic(error: error, stackTrace: stackTrace);
    final response = error.response;
    final key = statusCodeToFailure.keys
        .firstWhereOrNull((code) => code == response?.statusCode);
    return statusCodeToFailure[key] ??
        Failure.generic(error: error, stackTrace: stackTrace);
  }
}
