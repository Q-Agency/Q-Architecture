import 'package:example/data/models/example_user_response.dart';

abstract class ApiClient {
  Future<ExampleUserResponse> getUser();
}

class MockedApiClient implements ApiClient {
  @override
  Future<ExampleUserResponse> getUser() async => ExampleUserResponse(
        'firstName',
        'lastName',
        DateTime.now(),
        'gender',
      );
}
