// ignore_for_file: always_use_package_imports

import 'package:either_dart/either.dart';

import 'entities/failure.dart';

typedef EitherFailureOr<T> = Future<Either<Failure, T>>;
typedef StreamFailureOr<T> = Stream<Either<Failure, T>>;
