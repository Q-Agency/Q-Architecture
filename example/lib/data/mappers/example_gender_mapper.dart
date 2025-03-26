import 'package:example/domain/entities/example_gender.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/q_architecture.dart';

final exampleGenderMapperProvider =
    Provider<EntityMapper<ExampleGender, String>>(
  (_) => (genderString) => _exampleGenderMap[genderString]!,
);

final _exampleGenderMap = {
  'male': ExampleGender.male,
  'female': ExampleGender.male,
  'other': ExampleGender.male,
};
