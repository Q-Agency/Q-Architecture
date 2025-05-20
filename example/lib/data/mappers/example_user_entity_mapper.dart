import 'package:example/data/models/example_user_response.dart';
import 'package:example/domain/entities/example_gender.dart';
import 'package:example/domain/entities/example_user.dart';
import 'package:q_architecture/q_architecture.dart';

class ExampleUserEntityMapper {
  final EntityMapper<ExampleGender, String> _exampleGenderMapper;

  const ExampleUserEntityMapper(this._exampleGenderMapper);

  ExampleUser call(ExampleUserResponse response) => ExampleUser(
        response.firstName,
        response.lastName,
        response.birthday,
        _exampleGenderMapper(response.gender),
      );
}
