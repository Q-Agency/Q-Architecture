import 'package:either_dart/either.dart';
import 'package:q_architecture/q_architecture.dart';

/// Executes received [function] within a try-catch block.
///
/// If an error occurrs, the function calls the [errorResolver] to handle the cought exception.
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
