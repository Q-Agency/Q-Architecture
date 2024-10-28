//ignore_for_file: prefer-match-file-name

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:q_architecture/paginated_notifier.dart';
import 'package:q_architecture/q_architecture.dart';

class MockTestRepository extends Mock implements TestRepository {}

final testRepositoryProvider =
    Provider<TestRepository>((ref) => throw UnimplementedError());

void main() {
  late TestRepository testRepository;
  late ProviderContainer providerContainer;
  final Failure testGenericFailure =
      Failure.generic(title: 'Unknown error occurred');
  final testNotifierProvider =
      NotifierProvider<TestNotifier, PaginatedState<String>>(
    () => TestNotifier(),
  );
  setUp(() {
    testRepository = MockTestRepository();
    providerContainer = ProviderContainer(
      overrides: [
        testRepositoryProvider.overrideWith((ref) => testRepository),
      ],
    );
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
    test('should emit [Loading, Loaded] when repository returns PaginatedList',
        () async {
      when(() => testRepository.getListOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      final states = <PaginatedState>[];
      providerContainer.listen(
        testNotifierProvider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer
          .read(testNotifierProvider.notifier)
          .getInitialList();
      expect(
        [
          const PaginatedState<Never>.loading(),
          PaginatedState.loaded(getList(page: 1), isLastPage: false),
        ],
        states,
      );
    });

    test(
        'show emit [Loading, Error] when repository returns PaginatedList and then Failure',
        () async {
      when(() => testRepository.getListOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1, shouldFail: true));
      final states = <PaginatedState>[];
      providerContainer.listen(
        testNotifierProvider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer
          .read(testNotifierProvider.notifier)
          .getInitialList();
      expect(
        [
          const PaginatedState<Never>.loading(),
          PaginatedState<String>.error(const [], testGenericFailure),
        ],
        states,
      );
    });
  });

  group('getNextPage()', () {
    test(
        'should emit [LoadingMore, Loaded] when repository returns PaginatedList',
        () async {
      when(() => testRepository.getListOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      final states = <PaginatedState>[];
      providerContainer.listen(
        testNotifierProvider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer.read(testNotifierProvider.notifier).getNextPage();
      expect(
        [
          const PaginatedState<String>.loadingMore([]),
          PaginatedState<String>.loaded(getList(page: 1), isLastPage: false),
        ],
        states,
      );
    });
  });

  group('getInitialList() and getNextPage() combined', () {
    test(
        'should emit [Loading, Loaded, LoadingMore, Loaded] when repository first returns PaginatedList and then another PaginatedList',
        () async {
      when(() => testRepository.getListOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      when(() => testRepository.getListOrFailure(2))
          .thenAnswer((_) => getPageResponse(page: 2));
      final states = <PaginatedState>[];
      providerContainer.listen(
        testNotifierProvider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      final notifier = providerContainer.read(testNotifierProvider.notifier);
      await notifier.getInitialList();
      await notifier.getNextPage();
      expect(
        [
          const PaginatedState<Never>.loading(),
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
        'should emit [Loading, Loaded, LoadingMore, Loaded] when repository returns PaginatedList and then another PaginatedList (second getNextPage() will be ignored)',
        () async {
      when(() => testRepository.getListOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      when(() => testRepository.getListOrFailure(2))
          .thenAnswer((_) => getPageResponse(page: 2));
      final states = <PaginatedState>[];
      providerContainer.listen(
        testNotifierProvider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      final notifier = providerContainer.read(testNotifierProvider.notifier);
      await notifier.getInitialList();
      await notifier.getNextPage();
      await notifier.getNextPage();
      expect(
        [
          const PaginatedState<Never>.loading(),
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
        'show emit [Loading, Loaded, LoadingMore, Error] when repository returns PaginatedList and then Failure',
        () async {
      when(() => testRepository.getListOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      when(() => testRepository.getListOrFailure(2))
          .thenAnswer((_) => getPageResponse(page: 2, shouldFail: true));
      final states = <PaginatedState>[];
      providerContainer.listen(
        testNotifierProvider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      final notifier = providerContainer.read(testNotifierProvider.notifier);
      await notifier.getInitialList();
      await notifier.getNextPage();
      expect(
        [
          const PaginatedState<Never>.loading(),
          PaginatedState.loaded(getList(page: 1), isLastPage: false),
          PaginatedState.loadingMore(getList(page: 1)),
          PaginatedState.error(getList(page: 1), testGenericFailure),
        ],
        states,
      );
    });
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
      when(() => testRepository.getListOrFailure(2))
          .thenAnswer((_) => getPageResponse(page: 2));
      final states = <PaginatedState>[];
      providerContainer.listen(
        testNotifierProvider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      final notifier = providerContainer.read(testNotifierProvider.notifier);
      await notifier.getInitialList();
      await notifier.refresh();
      expect(
        [
          const PaginatedState<Never>.loading(),
          PaginatedState<String>.error(const [], testGenericFailure),
          const PaginatedState<Never>.loading(),
          PaginatedState<String>.loaded(getList(page: 1), isLastPage: false),
        ],
        states,
      );
    });

    test(
        'should emit [Loading, Loaded, LoadingMore, Loaded, Loading, Loaded] when repository returns PaginatedList, then PaginatedList and then initial PaginatedList',
        () async {
      when(() => testRepository.getListOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      when(() => testRepository.getListOrFailure(2))
          .thenAnswer((_) => getPageResponse(page: 2));
      final states = <PaginatedState>[];
      providerContainer.listen(
        testNotifierProvider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      final notifier = providerContainer.read(testNotifierProvider.notifier);
      await notifier.getInitialList();
      await notifier.getNextPage();
      await notifier.refresh();
      expect(
        [
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
        states,
      );
    });
  });
}

abstract class TestRepository {
  PaginatedEitherFailureOr<String> getListOrFailure(
    int page, [
    Object? parameter,
  ]);
}

class TestNotifier extends PaginatedNotifier<String, Object> {
  late TestRepository _testRepository;

  @override
  ({PaginatedState<String> initialState, bool useGlobalFailure})
      prepareForBuild() {
    _testRepository = ref.watch(testRepositoryProvider);
    return (initialState: const PaginatedLoading(), useGlobalFailure: false);
  }

  @override
  PaginatedEitherFailureOr<String> getListOrFailure(
    int page, [
    Object? parameter,
  ]) =>
      _testRepository.getListOrFailure(page, parameter);
}
