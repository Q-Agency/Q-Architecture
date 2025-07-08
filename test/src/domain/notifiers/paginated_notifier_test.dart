// ignore_for_file: unused_result

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:q_architecture/q_architecture.dart';

class MockTestRepository extends Mock implements TestRepository {}

void main() {
  late TestRepository testRepository;
  final Failure testGenericFailure = Failure.generic(
    title: 'Unknown error occurred',
  );
  late TestNotifier testNotifier;
  setUpAll(() {
    initQArchitecture();
  });

  setUp(() {
    testRepository = MockTestRepository();
    testNotifier = TestNotifier(testRepository);
  });

  List<String> getList({required int page}) =>
      List.generate(5, (index) => 'page: $page, index: $index');

  PaginatedEitherFailureOr<String> getPageResponse({
    required int page,
    bool shouldFail = false,
  }) async {
    await 300.milliseconds;
    if (shouldFail) {
      return Left(Failure.generic(title: 'Unknown error occurred'));
    }
    return Right(
      PaginatedList(
        data: List.generate(5, (index) => 'page: $page, index: $index'),
        isLast: page == 2,
        page: page,
      ),
    );
  }

  group('getInitialList()', () {
    test(
      'should emit [Loading, Loaded] when repository returns PaginatedList',
      () async {
        when(
          () => testRepository.getListOrFailure(1),
        ).thenAnswer((_) => getPageResponse(page: 1));
        final states = <PaginatedState>[];
        testNotifier.listen(
          (currentState, _) => states.add(currentState),
          fireImmediately: true,
        );
        await testNotifier.getInitialList();
        expect(
          [
            PaginatedState<String>.loading(),
            PaginatedState.loaded(getList(page: 1), isLastPage: false),
          ],
          states,
        );
      },
    );

    test(
      'show emit [Loading, Error] when repository returns PaginatedList and then Failure',
      () async {
        when(
          () => testRepository.getListOrFailure(1),
        ).thenAnswer((_) => getPageResponse(page: 1, shouldFail: true));
        final states = <PaginatedState>[];
        testNotifier.listen(
          (currentState, _) => states.add(currentState),
          fireImmediately: true,
        );
        await testNotifier.getInitialList();
        expect(
          [
            const PaginatedState<String>.loading(),
            PaginatedState<String>.error(const [], testGenericFailure),
          ],
          states,
        );
      },
    );
  });

  group('getNextPage()', () {
    test(
      'should emit [LoadingMore, Loaded] when repository returns PaginatedList',
      () async {
        when(
          () => testRepository.getListOrFailure(1),
        ).thenAnswer((_) => getPageResponse(page: 1));
        final states = <PaginatedState>[];
        testNotifier.listen(
          (currentState, _) => states.add(currentState),
          fireImmediately: false,
        );
        await testNotifier.getNextPage();
        expect(
          [
            const PaginatedState<String>.loadingMore([]),
            PaginatedState<String>.loaded(getList(page: 1), isLastPage: false),
          ],
          states,
        );
      },
    );
  });

  group('getInitialList() and getNextPage() combined', () {
    test(
      'should emit [Loading, Loaded, LoadingMore, Loaded] when repository first returns PaginatedList and then another PaginatedList',
      () async {
        when(
          () => testRepository.getListOrFailure(1),
        ).thenAnswer((_) => getPageResponse(page: 1));
        when(
          () => testRepository.getListOrFailure(2),
        ).thenAnswer((_) => getPageResponse(page: 2));
        final states = <PaginatedState>[];
        testNotifier.listen(
          (currentState, _) => states.add(currentState),
          fireImmediately: true,
        );
        await testNotifier.getInitialList();
        await testNotifier.getNextPage();
        expect(
          [
            const PaginatedState<String>.loading(),
            PaginatedState.loaded(getList(page: 1), isLastPage: false),
            PaginatedState.loadingMore(getList(page: 1)),
            PaginatedState.loaded(
              getList(page: 1) + getList(page: 2),
              isLastPage: true,
            ),
          ],
          states,
        );
      },
    );

    test(
      'should emit [Loading, Loaded, LoadingMore, Loaded] when repository returns PaginatedList and then another PaginatedList (second getNextPage() will be ignored)',
      () async {
        when(
          () => testRepository.getListOrFailure(1),
        ).thenAnswer((_) => getPageResponse(page: 1));
        when(
          () => testRepository.getListOrFailure(2),
        ).thenAnswer((_) => getPageResponse(page: 2));
        final states = <PaginatedState>[];
        testNotifier.listen(
          (currentState, _) => states.add(currentState),
          fireImmediately: true,
        );
        await testNotifier.getInitialList();
        await testNotifier.getNextPage();
        await testNotifier.getNextPage();
        expect(
          [
            const PaginatedState<String>.loading(),
            PaginatedState.loaded(getList(page: 1), isLastPage: false),
            PaginatedState.loadingMore(getList(page: 1)),
            PaginatedState.loaded(
              getList(page: 1) + getList(page: 2),
              isLastPage: true,
            ),
          ],
          states,
        );
      },
    );

    test(
      'show emit [Loading, Loaded, LoadingMore, Error] when repository returns PaginatedList and then Failure',
      () async {
        when(
          () => testRepository.getListOrFailure(1),
        ).thenAnswer((_) => getPageResponse(page: 1));
        when(
          () => testRepository.getListOrFailure(2),
        ).thenAnswer((_) => getPageResponse(page: 2, shouldFail: true));
        final states = <PaginatedState>[];
        testNotifier.listen(
          (currentState, _) => states.add(currentState),
          fireImmediately: true,
        );
        await testNotifier.getInitialList();
        await testNotifier.getNextPage();
        expect(
          [
            const PaginatedState<String>.loading(),
            PaginatedState.loaded(getList(page: 1), isLastPage: false),
            PaginatedState.loadingMore(getList(page: 1)),
            PaginatedState.error(getList(page: 1), testGenericFailure),
          ],
          states,
        );
      },
    );
  });

  group('refresh()', () {
    test(
      'should emit [Loading, Error, Loading, Loaded] when repository returns Failure and then PaginatedList',
      () async {
        var counter = 0;
        when(() => testRepository.getListOrFailure(1)).thenAnswer((_) {
          if (counter == 0) {
            counter++;
            return getPageResponse(page: 1, shouldFail: true);
          }
          return getPageResponse(page: 1);
        });
        when(
          () => testRepository.getListOrFailure(2),
        ).thenAnswer((_) => getPageResponse(page: 2));
        final states = <PaginatedState>[];
        testNotifier.listen(
          (currentState, _) => states.add(currentState),
          fireImmediately: true,
        );
        await testNotifier.getInitialList();
        await testNotifier.refresh();
        expect(
          [
            const PaginatedState<String>.loading(),
            PaginatedState<String>.error(const [], testGenericFailure),
            const PaginatedState<String>.loading(),
            PaginatedState<String>.loaded(getList(page: 1), isLastPage: false),
          ],
          states,
        );
      },
    );

    test(
      'should emit [Loading, Loaded, LoadingMore, Loaded, Loading, Loaded] when repository returns PaginatedList, then PaginatedList and then initial PaginatedList',
      () async {
        when(
          () => testRepository.getListOrFailure(1),
        ).thenAnswer((_) => getPageResponse(page: 1));
        when(
          () => testRepository.getListOrFailure(2),
        ).thenAnswer((_) => getPageResponse(page: 2));
        final states = <PaginatedState>[];
        testNotifier.listen(
          (currentState, _) => states.add(currentState),
          fireImmediately: true,
        );
        await testNotifier.getInitialList();
        await testNotifier.getNextPage();
        await testNotifier.refresh();
        expect(
          [
            const PaginatedState<String>.loading(),
            PaginatedState.loaded(getList(page: 1), isLastPage: false),
            PaginatedState.loadingMore(getList(page: 1)),
            PaginatedState.loaded(
              getList(page: 1) + getList(page: 2),
              isLastPage: true,
            ),
            const PaginatedState<String>.loading(),
            PaginatedState.loaded(getList(page: 1), isLastPage: false),
          ],
          states,
        );
      },
    );
  });
}

abstract class TestRepository {
  PaginatedEitherFailureOr<String> getListOrFailure(
    int page, [
    Object? parameter,
  ]);
}

class TestNotifier extends PaginatedNotifier<String, Object> {
  final TestRepository _testRepository;

  TestNotifier(this._testRepository) : super(PaginatedLoading());

  @override
  PaginatedEitherFailureOr<String> getListOrFailure(
    int page, [
    Object? parameter,
  ]) =>
      _testRepository.getListOrFailure(page, parameter);
}
