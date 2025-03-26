import 'package:q_architecture/q_architecture.dart';

class CustomErrorResolver implements ErrorResolver {
  @override
  Failure resolve<T>(Object error, [StackTrace? stackTrace]) {
    final message = error is String ? error : error.toString();
    return Failure.generic(
      title: message,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
