import 'package:example/data/api_client.dart';
import 'package:example/data/mappers/example_gender_mapper.dart';
import 'package:example/data/mappers/example_user_entity_mapper.dart';
import 'package:example/data/repositories/example_repository.dart';
import 'package:example/domain/notifiers/example_filters/example_filters_notifier.dart';
import 'package:example/domain/notifiers/example_notifier/example_notifier.dart';
import 'package:example/domain/notifiers/example_pagination/example_paginated_notifier.dart';
import 'package:example/domain/notifiers/example_pagination/example_paginated_stream_notifier.dart';
import 'package:example/domain/notifiers/example_simple_notifier/example_simple_notifier.dart';
import 'package:get_it/get_it.dart';
import 'package:q_architecture/q_architecture.dart' as q_architecture;

final getIt = GetIt.instance;

void setupServiceLocator() {
  q_architecture.setupServiceLocator();
  getIt.registerSingleton<ApiClient>(MockedApiClient());
  getIt.registerSingleton<ExampleGenderMapper>(ExampleGenderMapper());
  getIt.registerSingleton<ExampleUserEntityMapper>(
    ExampleUserEntityMapper(getIt<ExampleGenderMapper>()),
  );
  getIt.registerSingleton<ExampleRepository>(
    ExampleRepositoryImp(
      getIt<ApiClient>(),
      getIt<ExampleUserEntityMapper>(),
    ),
  );
  getIt.registerLazySingleton<ExampleFiltersNotifier>(
    () => ExampleFiltersNotifier(),
    dispose: (instance) => instance.dispose(),
  );
  getIt.registerLazySingleton<ExampleSimpleNotifier>(
    () => ExampleSimpleNotifier(
      getIt<ExampleRepository>(),
      autoDispose: true,
    ),
    dispose: (instance) => instance.dispose(),
  );
  getIt.registerLazySingleton<ExampleNotifier>(
    () => ExampleNotifier(getIt<ExampleRepository>(), autoDispose: true),
    dispose: (instance) => instance.dispose(),
  );
  getIt.registerLazySingleton<ExamplePaginatedNotifier>(
    () =>
        ExamplePaginatedNotifier(getIt<ExampleRepository>(), autoDispose: true),
    dispose: (instance) => instance.dispose(),
  );
  getIt.registerLazySingleton<ExamplePaginatedStreamNotifier>(
    () => ExamplePaginatedStreamNotifier(
      getIt<ExampleRepository>(),
      autoDispose: true,
    ),
    dispose: (instance) => instance.dispose(),
  );
}
