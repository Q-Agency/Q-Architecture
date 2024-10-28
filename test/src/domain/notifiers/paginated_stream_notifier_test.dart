import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:q_architecture/paginated_notifier.dart';
import 'package:q_architecture/q_architecture.dart';

//ignore: prefer-match-file-name
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
      providerContainer.listen(
        testNotifierProvider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer.read(testNotifierProvider.notifier).getNextPage();
      expect(
        [
          const PaginatedState<String>.loadingMore([]),
          PaginatedState.loaded(getList(page: 1), isLastPage: false),
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
      providerContainer.listen(
        testNotifierProvider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      final notifier = providerContainer.read(testNotifierProvider.notifier);
      notifier.getInitialList();
      await 100.milliseconds;
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
        'show emit [Loading, Loaded, Loaded, LoadingMore, Error] when repository returns PaginatedList twice and then Failure',
        () async {
      when(() => testRepository.getListStreamOrFailure(1))
          .thenAnswer((_) => getPageResponse(page: 1));
      when(() => testRepository.getListStreamOrFailure(2))
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
          PaginatedState.loaded(getList(page: 1), isLastPage: false),
          PaginatedState.error(getList(page: 1), testGenericFailure),
          const PaginatedState<Never>.loading(),
          PaginatedState.loaded(getList(page: 1), isLastPage: false),
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
          PaginatedState.loaded(getList(page: 1), isLastPage: false),
          PaginatedState.loadingMore(getList(page: 1)),
          PaginatedState.loaded(
            getList(page: 1) + getList(page: 2),
            isLastPage: true,
          ),
          const PaginatedState<Never>.loading(),
          PaginatedState.loaded(getList(page: 1), isLastPage: false),
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
  late TestRepository _testRepository;

  @override
  ({PaginatedState<String> initialState, bool useGlobalFailure})
      prepareForBuild() {
    _testRepository = ref.watch(testRepositoryProvider);
    return (initialState: const PaginatedLoading(), useGlobalFailure: false);
  }

  @override
  PaginatedStreamFailureOr<String> getListStreamOrFailure(
    int page, [
    Object? parameter,
  ]) =>
      _testRepository.getListStreamOrFailure(page, parameter);
}
