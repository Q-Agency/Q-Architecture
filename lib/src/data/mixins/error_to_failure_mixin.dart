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
