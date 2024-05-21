// ignore_for_file: invalid_use_of_protected_member
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/base_notifier.dart';
import 'package:q_architecture/q_architecture.dart';

void main() {
  late ProviderContainer providerContainer;
  final Failure testGenericFailure =
      Failure.generic(title: 'Unknown error occurred');
  final provider = NotifierProvider<TestNotifier, BaseState<String>>(
    () => TestNotifier(),
  );
  final provider2 = NotifierProvider<TestNotifier, BaseState<String>>(
    () => TestNotifier(),
  );

  setUp(() {
    providerContainer = ProviderContainer();
  });

  EitherFailureOr<String> getSuccessfulResponse() async {
    return const Right('');
  }

  EitherFailureOr<String> getFailureResponse() async {
    return Left(testGenericFailure);
  }

  StreamFailureOr<String> getSuccessfulResponseStream() async* {
    yield const Right('a');
    await 300.milliseconds;
    yield const Right('b');
  }

  StreamFailureOr<String> getFailureResponseStream() async* {
    yield Left(testGenericFailure);
  }

  StreamFailureOr<String> getSuccessThenFailureResponseStream() async* {
    yield const Right('a');
    await 300.milliseconds;
    yield Left(testGenericFailure);
  }

  group('execute method tests', () {
    test(
      'should emit [loading, data] when successful response',
      () async {
        final states = <BaseState>[];
        providerContainer.listen(
          provider,
          (_, state) => states.add(state),
          fireImmediately: false,
        );
        await providerContainer
            .read(provider.notifier)
            .execute(getSuccessfulResponse());
        expect(
          [const BaseState<Never>.loading(), const BaseState.data('')],
          states,
        );
      },
    );

    test(
      'should emit [data] and update globalLoadingProvider when successful response',
      () async {
        final states = <BaseState>[];
        providerContainer.listen(
          provider,
          (_, state) => states.add(state),
          fireImmediately: false,
        );
        await providerContainer.read(provider.notifier).execute(
              getSuccessfulResponse(),
              withLoadingState: false,
              globalLoading: true,
            );
        expect(
          providerContainer.read(globalLoadingProvider.notifier).state,
          false,
        );
        expect(
          [const BaseState.data('')],
          states,
        );
      },
    );

    test('should emit [loading, error] when successful response', () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer
          .read(provider.notifier)
          .execute(getFailureResponse(), globalFailure: false);
      expect(
        providerContainer.read(globalLoadingProvider.notifier).state,
        false,
      );
      expect(
        [
          const BaseState<Never>.loading(),
          BaseState<String>.error(testGenericFailure),
        ],
        states,
      );
    });

    test(
        'should emit [loading, initial] and update global failure provider when failure response',
        () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer
          .read(provider.notifier)
          .execute(getFailureResponse());
      expect(
        providerContainer.read(globalFailureProvider)?.title,
        testGenericFailure.title,
      );
      expect(
        [
          const BaseState<Never>.loading(),
          const BaseState<Never>.initial(),
        ],
        states,
      );
    });

    test(
        'should emit [] and update global failure provider and global loading provider when failure response',
        () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer.read(provider.notifier).execute(
            getFailureResponse(),
            withLoadingState: false,
            globalLoading: true,
          );
      expect(
        providerContainer.read(globalLoadingProvider),
        false,
      );
      expect(
        providerContainer.read(globalFailureProvider)?.title,
        testGenericFailure.title,
      );
      expect(
        [],
        states,
      );
    });

    test(
        'should emit [error] and update global loading provider when failure response',
        () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer.read(provider.notifier).execute(
            getFailureResponse(),
            withLoadingState: false,
            globalLoading: true,
            globalFailure: false,
          );
      expect(
        providerContainer.read(globalLoadingProvider),
        false,
      );
      expect(
        [BaseState<String>.error(testGenericFailure)],
        states,
      );
    });

    test(
        'should emit [loading, data] when successful response and onDataReceived true',
        () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer
          .read(provider.notifier)
          .execute(getSuccessfulResponse(), onDataReceived: (data) => true);
      expect(
        [const BaseState<Never>.loading(), const BaseState.data('')],
        states,
      );
    });

    test(
      'should emit [loading, initial] when successful response and onDataReceived false',
      () async {
        final states = <BaseState>[];
        providerContainer.listen(
          provider,
          (_, state) => states.add(state),
          fireImmediately: false,
        );
        await providerContainer
            .read(provider.notifier)
            .execute(getSuccessfulResponse(), onDataReceived: (data) => false);
        expect(
          [const BaseState<Never>.loading(), const BaseState<Never>.initial()],
          states,
        );
      },
    );

    test(
        'should emit [loading, initial] when failure response and onFailureOccurred false',
        () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer
          .read(provider.notifier)
          .execute(getFailureResponse(), onFailureOccurred: (failure) => false);
      expect(
        [const BaseState<Never>.loading(), const BaseState<Never>.initial()],
        states,
      );
    });

    test(
        'should emit [loading, error] when failure response and onFailureOccurred true',
        () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer.read(provider.notifier).execute(
            getFailureResponse(),
            onFailureOccurred: (failure) => true,
            globalFailure: false,
          );
      expect(
        [
          const BaseState<Never>.loading(),
          BaseState<String>.error(testGenericFailure),
        ],
        states,
      );
    });

    test(
        'should emit [loading, initial] when failure response and onFailureOccurred false',
        () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer
          .read(provider.notifier)
          .execute(getFailureResponse(), onFailureOccurred: (failure) => false);
      expect(
        [const BaseState<Never>.loading(), const BaseState<Never>.initial()],
        states,
      );
    });
  });

  group('executeStreamed method tests', () {
    test('should emit [loading, data, data] when successful response stream',
        () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer
          .read(provider.notifier)
          .executeStreamed(getSuccessfulResponseStream());
      expect(
        [
          const BaseState<Never>.loading(),
          const BaseState.data('a'),
          const BaseState.data('b'),
        ],
        states,
      );
    });

    test(
        'should emit [data, data] and update global loading provider when successful response stream',
        () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer.read(provider.notifier).executeStreamed(
            getSuccessfulResponseStream(),
            withLoadingState: false,
            globalLoading: true,
          );
      expect(
        [
          const BaseState.data('a'),
          const BaseState.data('b'),
        ],
        states,
      );
    });

    test('should emit [loading, error] when failure response stream', () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer.read(provider.notifier).executeStreamed(
            getFailureResponseStream(),
            globalFailure: false,
          );
      expect(
        [
          const BaseState<Never>.loading(),
          BaseState<String>.error(testGenericFailure),
        ],
        states,
      );
    });

    test(
        'should emit [loading, initial] and update global failure provider when failure response stream',
        () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer
          .read(provider.notifier)
          .executeStreamed(getFailureResponseStream());
      expect(
        providerContainer.read(globalFailureProvider)?.title,
        testGenericFailure.title,
      );
      expect(
        [const BaseState<Never>.loading(), const BaseState<Never>.initial()],
        states,
      );
    });

    test(
        'should emit [loading, data] and update global failure provider when successful then failure response stream',
        () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer
          .read(provider.notifier)
          .executeStreamed(getSuccessThenFailureResponseStream());
      expect(
        providerContainer.read(globalFailureProvider)?.title,
        testGenericFailure.title,
      );
      expect(
        [
          const BaseState<Never>.loading(),
          const BaseState.data('a'),
        ],
        states,
      );
    });

    test(
        'should emit [loading, data, error] when successful then failure response stream',
        () async {
      final states = <BaseState>[];
      providerContainer.listen(
        provider,
        (_, state) => states.add(state),
        fireImmediately: false,
      );
      await providerContainer.read(provider.notifier).executeStreamed(
            getSuccessThenFailureResponseStream(),
            globalFailure: false,
          );
      expect(
        [
          const BaseState<Never>.loading(),
          const BaseState.data('a'),
          BaseState<String>.error(testGenericFailure),
        ],
        states,
      );
    });
  });

  group('simple notifier tests', () {
    test(
      'should set global loading provider to true',
      () {
        providerContainer.read(provider.notifier).showGlobalLoading();
        expect(providerContainer.read(globalLoadingProvider), true);
      },
    );

    test(
      'should set global loading provider to false',
      () async {
        providerContainer.read(provider.notifier).showGlobalLoading();
        await 500.milliseconds;
        providerContainer.read(provider.notifier).clearGlobalLoading();

        expect(providerContainer.read(globalLoadingProvider), false);
      },
    );

    test(
      'should set global loading provider',
      () {
        providerContainer
            .read(provider.notifier)
            .setGlobalFailure(testGenericFailure);
        expect(
          providerContainer.read(globalFailureProvider)?.title,
          testGenericFailure.title,
        );
      },
    );

    test('test on method', () {
      providerContainer.read(provider.notifier).on(
        provider2,
        (previous, next) {
          expect(next, const BaseState.data(''));
        },
        skipUpdateCondition: (previous, next) => switch (next) {
          BaseLoading() => true,
          _ => false,
        },
      );
      providerContainer
          .read(provider2.notifier)
          .execute(getSuccessfulResponse());
    });
  });
}

//ignore: prefer-match-file-name
class TestNotifier extends BaseNotifier<String> {
  @override
  void prepareForBuild() {}
}
