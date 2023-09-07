import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:q_architecture/q_architecture.dart';

mixin ErrorToFailureMixin {
  EitherFailureOr<T> execute<T>(
    EitherFailureOr<T> Function() function, {
    required ErrorResolver errorResolver,
  }) async {
    try {
      return await function();
    } catch (err, stackTrace) {
      return Left(errorResolver.resolve(err, stackTrace));
    }
  }
}

abstract interface class ErrorResolver {
  Failure resolve<T>(Object error, [StackTrace? stackTrace]);
}

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

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
