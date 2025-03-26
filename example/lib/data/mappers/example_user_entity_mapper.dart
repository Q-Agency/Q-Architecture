import 'package:example/data/mappers/example_gender_mapper.dart';
import 'package:example/data/models/example_user_response.dart';
import 'package:example/domain/entities/example_user.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/q_architecture.dart';

final exampleUserEntityMapperProvider =
    Provider<EntityMapper<ExampleUser, ExampleUserResponse>>(
  (ref) => (response) {
    final exampleGenderMapper = ref.watch(exampleGenderMapperProvider);
    return ExampleUser(
      response.firstName,
      response.lastName,
      response.birthday,
      exampleGenderMapper(response.gender),
    );
  },
);
