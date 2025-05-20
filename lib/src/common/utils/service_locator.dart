import 'package:get_it/get_it.dart';
import 'package:q_architecture/q_architecture.dart';

void setupServiceLocator() {
  GetIt.instance
      .registerSingleton<GlobalFailureNotifier>(GlobalFailureNotifier());
  GetIt.instance.registerSingleton<GlobalInfoNotifier>(GlobalInfoNotifier());
  GetIt.instance
      .registerSingleton<GlobalLoadingNotifier>(GlobalLoadingNotifier());
}
