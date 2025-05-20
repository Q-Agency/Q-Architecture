import 'package:q_architecture/q_architecture.dart';

///[GlobalLoadingNotifier] can be used to show the loading indicator without updating [BaseNotifier]
///state. The entire app is wrapped in [BaseWidget] and [BaseLoadingIndicator] can be shown above entire
///app by simply calling [showGlobalLoading]. To hide [BaseLoadingIndicator] simply call [clearGlobalLoading]
class GlobalLoadingNotifier extends SimpleNotifier<bool> {
  GlobalLoadingNotifier() : super(false);

  void setGlobalLoading(bool value) => state = value;
}
