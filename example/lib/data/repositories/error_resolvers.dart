import 'package:q_architecture/q_architecture.dart';

const exampleApiErrorResolver = ApiErrorResolver(
  statusCodeToFailure: {
    404: UnauthorizedFailure(),
  },
);

class CustomErrorResolver implements ErrorResolver {
  @override
  Failure resolve<T>(Object error, [StackTrace? stackTrace]) {
    return Failure.generic();
  }
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super(title: 'Unauthorized user');
}
