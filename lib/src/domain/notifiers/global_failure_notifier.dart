import 'package:q_architecture/q_architecture.dart';

///[GlobalFailureNotifier] can be used to show the failure without updating [BaseStateNotifier] state.
///
///The entire app is wrapped in [BaseWidget] which listens to this provider and failure can be shown above entire
///app by simply setting [globalFailure] to true when calling [BaseStateNotifier.execute] method.
class GlobalFailureNotifier extends SimpleNotifier<Failure?> {
  GlobalFailureNotifier() : super(null);

  void setFailure(Failure? failure) => state = failure;
}
