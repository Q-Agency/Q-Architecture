import 'package:either_dart/either.dart';
import 'package:q_architecture/src/domain/entities/failure.dart';

typedef EitherFailureOr<T> = Future<Either<Failure, T>>;
typedef StreamFailureOr<T> = Stream<Either<Failure, T>>;
