//ignore_for_file: prefer-match-file-name

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:q_architecture/paginated_notifier.dart';
import 'package:q_architecture/q_architecture.dart';
import 'package:state_notifier_test/state_notifier_test.dart';

class MockTestRepository extends Mock implements TestRepository {}

void main() {
  late TestRepository testRepository;
  late ProviderContainer providerContainer;
  final Failure testGenericFailure =
      Failure.generic(title: 'Unknown error occurred');
  final testNotifierProvider =
      StateNotifierProvider<TestNotifier, PaginatedState<String>>(
    (ref) => throw UnimplementedError(),
  );
  setUpAll(() {
    testRepository = MockTestRepository();
  });
  ProviderContainer getProviderContainer() => ProviderContainer(overrides: [
        testNotifierProvider
            .overrideWith((ref) => TestNotifier(testRepository, ref)),
      ]);

  List<String> getList({required int page}) =>
      List.generate(5, (index) => 'page: $page, index: $index');

  PaginatedEitherFailureOr<String> getPageResponse({
    required int page,
    bool shouldFail = false,
  }) async {
    await 300.milliseconds;
    if (shouldFail) {
      return left(Failure.generic(title: 'Unknown error occurred'));
    }
    return right(PaginatedList(
      data: List.generate(5, (index) => 'page: $page, index: $index'),
      isLast: page == 2,
      page: page,
    ));
  }

  group('getInitialList()', () {
    stateNotifierTest<TestNotifier, PaginatedState<String>>(
      'should emit [Loading, Loaded] when repository returns PaginatedList',
      setUp: () {
        providerContainer = getProviderContainer();
        when(() => testRepository.getListOrFailure(1))
            .thenAnswer((_) => getPageResponse(page: 1));
      },
      build: () => providerContainer.read(testNotifierProvider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.getInitialList();
      },
      expect: () => [
        const PaginatedState<Never>.loading(),
        PaginatedState.loaded(getList(page: 1), isLastPage: false),
      ],
    );

    stateNotifierTest<TestNotifier, PaginatedState<String>>(
      'show emit [Loading, Error] when repository returns PaginatedList and then Failure',
      setUp: () {
        providerContainer = getProviderContainer();
        when(() => testRepository.getListOrFailure(1))
            .thenAnswer((_) => getPageResponse(page: 1, shouldFail: true));
      },
      build: () => providerContainer.read(testNotifierProvider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.getInitialList();
      },
      expect: () => [
        const PaginatedState<Never>.loading(),
        PaginatedState<String>.error(const [], testGenericFailure),
      ],
    );
  });

  group('getNextPage()', () {
    stateNotifierTest<TestNotifier, PaginatedState<String>>(
      'should emit [LoadingMore, Loaded] when repository returns PaginatedList',
      setUp: () {
        providerContainer = getProviderContainer();
        when(() => testRepository.getListOrFailure(1))
            .thenAnswer((_) => getPageResponse(page: 1));
      },
      build: () => providerContainer.read(testNotifierProvider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.getNextPage();
      },
      expect: () => [
        const PaginatedState<String>.loadingMore([]),
        PaginatedState<String>.loaded(getList(page: 1), isLastPage: false),
      ],
    );
  });

  group('getInitialList() and getNextPage() combined', () {
    stateNotifierTest<TestNotifier, PaginatedState<String>>(
      'should emit [Loading, Loaded, LoadingMore, Loaded] when repository first returns PaginatedList and then another PaginatedList',
      setUp: () {
        providerContainer = getProviderContainer();
        when(() => testRepository.getListOrFailure(1))
            .thenAnswer((_) => getPageResponse(page: 1));
        when(() => testRepository.getListOrFailure(2))
            .thenAnswer((_) => getPageResponse(page: 2));
      },
      build: () => providerContainer.read(testNotifierProvider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.getInitialList();
        await stateNotifier.getNextPage();
      },
      expect: () => [
        const PaginatedState<Never>.loading(),
        PaginatedState.loaded(getList(page: 1), isLastPage: false),
        PaginatedState.loadingMore(getList(page: 1)),
        PaginatedState.loaded(
          getList(page: 1) + getList(page: 2),
          isLastPage: true,
        ),
      ],
    );

    stateNotifierTest<TestNotifier, PaginatedState<String>>(
      'should emit [Loading, Loaded, LoadingMore, Loaded] when repository returns PaginatedList and then another PaginatedList (second getNextPage() will be ignored)',
      setUp: () {
        providerContainer = getProviderContainer();
        when(() => testRepository.getListOrFailure(1))
            .thenAnswer((_) => getPageResponse(page: 1));
        when(() => testRepository.getListOrFailure(2))
            .thenAnswer((_) => getPageResponse(page: 2));
      },
      build: () => providerContainer.read(testNotifierProvider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.getInitialList();
        await stateNotifier.getNextPage();
        await stateNotifier.getNextPage();
      },
      expect: () => [
        const PaginatedState<Never>.loading(),
        PaginatedState.loaded(getList(page: 1), isLastPage: false),
        PaginatedState.loadingMore(getList(page: 1)),
        PaginatedState.loaded(
          getList(page: 1) + getList(page: 2),
          isLastPage: true,
        ),
      ],
    );

    stateNotifierTest<TestNotifier, PaginatedState<String>>(
      'show emit [Loading, Loaded, LoadingMore, Error] when repository returns PaginatedList and then Failure',
      setUp: () {
        providerContainer = getProviderContainer();
        when(() => testRepository.getListOrFailure(1))
            .thenAnswer((_) => getPageResponse(page: 1));
        when(() => testRepository.getListOrFailure(2))
            .thenAnswer((_) => getPageResponse(page: 2, shouldFail: true));
      },
      build: () => providerContainer.read(testNotifierProvider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.getInitialList();
        await stateNotifier.getNextPage();
      },
      expect: () => [
        const PaginatedState<Never>.loading(),
        PaginatedState.loaded(getList(page: 1), isLastPage: false),
        PaginatedState.loadingMore(getList(page: 1)),
        PaginatedState.error(getList(page: 1), testGenericFailure),
      ],
    );
  });

  group('refresh()', () {
    stateNotifierTest<TestNotifier, PaginatedState<String>>(
      'should emit [Loading, Error, Loading, Loaded] when repository returns Failure and then PaginatedList',
      setUp: () {
        var counter = 0;
        providerContainer = getProviderContainer();
        when(() => testRepository.getListOrFailure(1)).thenAnswer((_) {
          if (counter == 0) {
            counter++;
            return getPageResponse(page: 1, shouldFail: true);
          }
          return getPageResponse(page: 1);
        });
        when(() => testRepository.getListOrFailure(2))
            .thenAnswer((_) => getPageResponse(page: 2));
      },
      build: () => providerContainer.read(testNotifierProvider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.getInitialList();
        await stateNotifier.refresh();
      },
      expect: () => [
        const PaginatedState<Never>.loading(),
        PaginatedState<String>.error(const [], testGenericFailure),
        const PaginatedState<Never>.loading(),
        PaginatedState<String>.loaded(getList(page: 1), isLastPage: false),
      ],
    );

    stateNotifierTest<TestNotifier, PaginatedState<String>>(
      'should emit [Loading, Loaded, LoadingMore, Loaded, Loading, Loaded] when repository returns PaginatedList, then PaginatedList and then initial PaginatedList',
      setUp: () {
        providerContainer = getProviderContainer();
        when(() => testRepository.getListOrFailure(1))
            .thenAnswer((_) => getPageResponse(page: 1));
        when(() => testRepository.getListOrFailure(2))
            .thenAnswer((_) => getPageResponse(page: 2));
      },
      build: () => providerContainer.read(testNotifierProvider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.getInitialList();
        await stateNotifier.getNextPage();
        await stateNotifier.refresh();
      },
      expect: () => [
        const PaginatedState<Never>.loading(),
        PaginatedState.loaded(getList(page: 1), isLastPage: false),
        PaginatedState.loadingMore(getList(page: 1)),
        PaginatedState.loaded(
          getList(page: 1) + getList(page: 2),
          isLastPage: true,
        ),
        const PaginatedState<Never>.loading(),
        PaginatedState.loaded(getList(page: 1), isLastPage: false),
      ],
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
  TestNotifier(this._testRepository, Ref ref)
      : super(ref, const PaginatedState.loading());

  @override
  PaginatedEitherFailureOr<String> getListOrFailure(
    int page, [
    Object? parameter,
  ]) =>
      _testRepository.getListOrFailure(page, parameter);
}
