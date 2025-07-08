import 'package:q_architecture/q_architecture.dart';
import 'package:q_architecture/src/common/utils/service_locator.dart';

void initQArchitecture({List<QNotifierObserver>? observers}) {
  if (observers != null) {
    QNotifier.addObservers(observers);
  }
  setupServiceLocator();
}
