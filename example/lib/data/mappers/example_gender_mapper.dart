import 'package:example/domain/entities/example_gender.dart';

class ExampleGenderMapper {
  ExampleGender call(String genderString) => _exampleGenderMap[genderString]!;
}

final _exampleGenderMap = {
  'male': ExampleGender.male,
  'female': ExampleGender.male,
  'other': ExampleGender.male,
};
