import 'dart:math';

import 'package:either_dart/either.dart';
import 'package:example/data/api_client.dart';
import 'package:example/data/mappers/example_user_entity_mapper.dart';
import 'package:example/data/models/example_user_response.dart';
import 'package:example/data/repositories/error_resolvers.dart';
import 'package:example/domain/entities/example_user.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/paginated_notifier.dart';
import 'package:q_architecture/q_architecture.dart';

final exampleRepositoryProvider = Provider<ExampleRepository>(
  (ref) => ExampleRepositoryImp(
    ref.watch(apiClientProvider),
    ref.watch(exampleUserEntityMapperProvider),
  ),
);

abstract class ExampleRepository {
  EitherFailureOr<ExampleUser> apiCallExample();
  EitherFailureOr<String> getSomeString();

  StreamFailureOr<String> getSomeStringsStreamed();

  PaginatedStreamFailureOr<String> getPaginatedStreamResult(int page);

  PaginatedEitherFailureOr<String> getPaginatedResult(int page);
}

class ExampleRepositoryImp
    with ErrorToFailureMixin
    implements ExampleRepository {
  final ApiClient _apiClient;
  final EntityMapper<ExampleUser, ExampleUserResponse> _userMapper;
  var _counter = 0;

  ExampleRepositoryImp(
    this._apiClient,
    this._userMapper,
  );

  @override
  EitherFailureOr<ExampleUser> apiCallExample() => execute(
        () async {
          final userResponse = await _apiClient.getUser();
          final user = _userMapper(userResponse);
          return Right(user);
        },
        errorResolver: CustomErrorResolver(),
      );

  @override
  StreamFailureOr<String> getSomeStringsStreamed() async* {
    yield const Right('Some sentence from cache');

    await 3.seconds;
    yield const Right('Some sentence from network');
  }

  @override
  EitherFailureOr<String> getSomeString() => execute(
        () async {
          await 3.seconds;
          if (Random().nextBool()) {
            return const Right('Some sentence');
          } else {
            throw Exception();
          }
        },
        errorResolver: CustomErrorResolver(),
      );

  @override
  PaginatedStreamFailureOr<String> getPaginatedStreamResult(int page) async* {
    if (page == 1) {
      _counter = 0;
    }
    List<String>? someStrings;
    if (page == 1) {
      someStrings = _getStrings();
      yield Right(PaginatedList(data: someStrings, isLast: false, page: 1));
    }
    await 3.seconds;
    if (Random().nextBool()) {
      yield Right(
        PaginatedList(
          data: someStrings ?? _getStrings(),
          isLast: page == 4,
          page: page,
        ),
      );
    } else {
      yield Left(Failure.generic());
    }
  }

  @override
  PaginatedEitherFailureOr<String> getPaginatedResult(int page) async {
    await 3.seconds;
    if (Random().nextBool()) {
      if (page == 1) {
        _counter = 0;
      }
      return Right(
        PaginatedList(
          data: _getStrings(),
          isLast: page == 4,
          page: page,
        ),
      );
    }
    return Left(Failure.generic());
  }

  List<String> _getStrings() => [
        '${++_counter}',
        '${++_counter}',
        '${++_counter}',
        '${++_counter}',
        '${++_counter}',
        '${++_counter}',
        '${++_counter}',
        '${++_counter}',
        '${++_counter}',
        '${++_counter}',
      ];
}
