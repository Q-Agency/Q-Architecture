// ignore_for_file: always_use_package_imports

import 'entities/failure.dart';

typedef Either<U, T> = (U? failure, T? data);
typedef EitherFailureOr<T> = Future<Either<Failure, T>>;
typedef StreamFailureOr<T> = Stream<Either<Failure, T>>;

typedef HandleLeft<U> = void Function(U);
typedef HandleRight<T> = void Function(T);

//ignore: prefer-match-file-name
extension Dartz<U, T> on Either<U, T> {
  void fold(HandleLeft left, HandleRight<T> right) {
    final (failure, data) = this;
    if (failure != null) return left(failure);
    if (data != null) return right(data);
  }

  bool isLeft() => this.$1 != null;
  bool isRight() => this.$2 != null;
  U asLeft() {
    if (this.$1 == null) throw NoValuePresentException();
    return this.$1!;
  }

  T asRight() {
    if (this.$2 == null) throw NoValuePresentException();
    return this.$2!;
  }
}

Either<U, T> right<U, T>(T data) => (null, data);

Either<U, T> left<U, T>(U failure) => (failure, null);

class NoValuePresentException extends Error {}
