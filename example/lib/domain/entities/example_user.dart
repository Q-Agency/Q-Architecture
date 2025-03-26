import 'package:equatable/equatable.dart';
import 'package:example/domain/entities/example_gender.dart';

class ExampleUser extends Equatable {
  final String firstName;
  final String lastName;
  final DateTime birthday;
  final ExampleGender gender;

  const ExampleUser(
    this.firstName,
    this.lastName,
    this.birthday,
    this.gender,
  );

  ExampleUser copyWith({
    String? firstName,
    String? lastName,
    DateTime? birthday,
    ExampleGender? gender,
  }) =>
      ExampleUser(
        firstName ?? this.firstName,
        lastName ?? this.lastName,
        birthday ?? this.birthday,
        gender ?? this.gender,
      );

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        birthday,
        gender,
      ];
}
