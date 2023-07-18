import 'package:example/data/models/example_user_response.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((_) => MockedApiClient());

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
