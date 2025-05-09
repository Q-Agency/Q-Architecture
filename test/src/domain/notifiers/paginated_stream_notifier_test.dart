import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:q_architecture/q_architecture.dart';

//ignore: prefer-match-file-name
class MockTestRepository extends Mock implements TestRepository {}

void main() {
  late TestRepository testRepository;
  final Failure testGenericFailure =
      Failure.generic(title: 'Unknown error occurred');
  late TestNotifier testNotifier;
  setUpAll(() {
    setupServiceLocator();
  });

  setUp(() {
    testRepository = MockTestRepository();
    testNotifier = TestNotifier(testRepository);
  });

  List<String> getList({required int page}) =>
      List.generate(5, (index) => 'page: $page, index: $index');

  PaginatedStreamFailureOr<String> getPageResponse({
    required int page,
    bool shouldFail = false,
  }) async* {
    final paginatedList = PaginatedList(
      data: List.generate(5, (index) => 'page: $page, index: $index'),
      isLast: page == 2,
      page: page,
    );
    if (page == 1) {
      yield Right(paginatedList);
    }
    await 300.milliseconds;
    if (shouldFail) {
      yield Left(Failure.generic(title: 'Unknown error occurred'));
    } else {
      yield Right(paginatedList);
    }
  }

  group('getInitialList()', () {
    test(
        'should emit [Loading, Loaded, Loaded] when repository returns PaginatedList twice',
        () async {
      when(() => testRepository.getListStreamOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      final states = <PaginatedState>[];
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: true,
      );
      await testNotifier.getInitialList();

      expect(
        [
          const PaginatedState<String>.loading(),
          PaginatedState.loaded(getList(page: 1), isLastPage: false),
        ],
        states,
      );
    });

    test(
        'show emit [Loading, Loaded, Error] when repository returns PaginatedList and then Failure with list from first yield',
        () async {
      when(() => testRepository.getListStreamOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1, shouldFail: true));
      final states = <PaginatedState>[];
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: true,
      );
      await testNotifier.getInitialList();
      expect(
        [
          const PaginatedState<String>.loading(),
          PaginatedState.loaded(getList(page: 1), isLastPage: false),
          PaginatedState.error(getList(page: 1), testGenericFailure),
        ],
        states,
      );
    });
  });

  group('getNextPage()', () {
    test(
        'should emit [LoadingMore, Loaded, Loaded] when repository returns PaginatedList twice',
        () async {
      when(() => testRepository.getListStreamOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      final states = <PaginatedState>[];
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.getNextPage();
      expect(
        [
          const PaginatedState<String>.loadingMore([]),
          PaginatedState.loaded(getList(page: 1), isLastPage: false),
        ],
        states,
      );
    });
  });

  group('getInitialList() and getNextPage() combined', () {
    test(
        'should emit [Loading, Loaded, Loaded, LoadingMore, Loaded] when repository first returns PaginatedList twice and then another PaginatedList',
        () async {
      when(() => testRepository.getListStreamOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      when(() => testRepository.getListStreamOrFailure(2))
          .thenAnswer((_) => getPageResponse(page: 2));
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
    });

    test(
        'should emit [Loading, Loaded, Loaded, LoadingMore, Loaded] when repository returns PaginatedList twice and then another PaginatedList (second getNextPage() will be ignored)',
        () async {
      when(() => testRepository.getListStreamOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      when(() => testRepository.getListStreamOrFailure(2))
          .thenAnswer((_) => getPageResponse(page: 2));
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
    });

    test(
        'should emit [Loading, Loaded, LoadingMore, Loaded] when repository returns PaginatedList and then another PaginatedList (getNextPage() is called before getInitialList() finishes)',
        () async {
      when(() => testRepository.getListStreamOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      when(() => testRepository.getListStreamOrFailure(2))
          .thenAnswer((_) => getPageResponse(page: 2));
      final states = <PaginatedState>[];
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: true,
      );
      await testNotifier.getInitialList();
      await 100.milliseconds;
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
    });

    test(
        'show emit [Loading, Loaded, Loaded, LoadingMore, Error] when repository returns PaginatedList twice and then Failure',
        () async {
      when(() => testRepository.getListStreamOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      when(() => testRepository.getListStreamOrFailure(2))
          .thenAnswer((_) => getPageResponse(page: 2, shouldFail: true));
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
    });

    test(
        'show emit [Loading, Error, LoadingMore, Loaded] when repository returns PaginatedList, Failure with list from first yield and then second PaginatedList',
        () async {
      when(() => testRepository.getListStreamOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1, shouldFail: true));
      when(() => testRepository.getListStreamOrFailure(2))
          .thenAnswer((_) => getPageResponse(page: 2));
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
          PaginatedState.error(getList(page: 1), testGenericFailure),
          PaginatedState.loadingMore(getList(page: 1)),
          PaginatedState.loaded(
            getList(page: 1) + getList(page: 2),
            isLastPage: true,
          ),
        ],
        states,
      );
    });
  });

  group('refresh()', () {
    test(
        'show emit [Loading, Loaded, Error, Loading, Loaded] when repository returns PaginatedList then Failure and then first PaginatedList',
        () async {
      var counter = 0;
      when(() => testRepository.getListStreamOrFailure(1)).thenAnswer((_) {
        if (counter == 0) {
          counter++;
          return getPageResponse(page: 1, shouldFail: true);
        }
        return getPageResponse(page: 1);
      });
      when(() => testRepository.getListStreamOrFailure(2))
          .thenAnswer((_) => getPageResponse(page: 2));
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
          PaginatedState.loaded(getList(page: 1), isLastPage: false),
          PaginatedState.error(getList(page: 1), testGenericFailure),
          const PaginatedState<String>.loading(),
          PaginatedState.loaded(getList(page: 1), isLastPage: false),
        ],
        states,
      );
    });

    test(
        'should emit [Loading, Loaded, Loaded, LoadingMore, Loaded, Loading, Loaded, Loaded] when repository returns PaginatedList twice, then PaginatedList and then again PaginatedList twice',
        () async {
      when(() => testRepository.getListStreamOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      when(() => testRepository.getListStreamOrFailure(2))
          .thenAnswer((_) => getPageResponse(page: 2));
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
    });
  });
}

abstract class TestRepository {
  PaginatedStreamFailureOr<String> getListStreamOrFailure(
    int page, [
    Object? parameter,
  ]);
}

class TestNotifier extends PaginatedStreamNotifier<String, Object> {
  final TestRepository _testRepository;

  TestNotifier(this._testRepository) : super(PaginatedLoading());

  @override
  PaginatedStreamFailureOr<String> getListStreamOrFailure(
    int page, [
    Object? parameter,
  ]) =>
      _testRepository.getListStreamOrFailure(page, parameter);
}
