// ignore_for_file: invalid_use_of_protected_member
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/q_architecture.dart';
import 'package:state_notifier_test/state_notifier_test.dart';

void main() {
  late ProviderContainer providerContainer;
  final Failure testGenericFailure =
      Failure.generic(title: 'Unknown error occurred');
  final provider = BaseStateNotifierProvider<TestNotifier, String>(
    (ref) => TestNotifier(ref),
  );
  final provider2 = BaseStateNotifierProvider<TestNotifier, String>(
    (ref) => TestNotifier(ref),
  );

  ProviderContainer getProviderContainer() => ProviderContainer();

  EitherFailureOr<String> getSuccessfulResponse() async {
    return right('');
  }

  EitherFailureOr<String> getFailureResponse() async {
    return left(testGenericFailure);
  }

  StreamFailureOr<String> getSuccessfulResponseStream() async* {
    yield right('a');
    await 300.milliseconds;
    yield right('b');
  }

  StreamFailureOr<String> getFailureResponseStream() async* {
    yield left(testGenericFailure);
  }

  StreamFailureOr<String> getSuccessThenFailureResponseStream() async* {
    yield right('a');
    await 300.milliseconds;
    yield left(testGenericFailure);
  }

  group('execute method tests', () {
    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, data] when successful response',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.execute(getSuccessfulResponse());
      },
      expect: () =>
          [const BaseState<Never>.loading(), const BaseState.data('')],
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [data] and update globalLoadingProvider when successful response',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.execute(
          getSuccessfulResponse(),
          withLoadingState: false,
          globalLoading: true,
        );
      },
      expect: () {
        expect(
          providerContainer.read(globalLoadingProvider.notifier).state,
          false,
        );
        return [const BaseState.data('')];
      },
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, error] when successful response',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.execute(getFailureResponse(), globalFailure: false);
      },
      expect: () => [
        const BaseState<Never>.loading(),
        BaseState<String>.error(testGenericFailure),
      ],
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, initial] and update global failure provider when failure response',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.execute(getFailureResponse());
      },
      expect: () {
        expect(
          providerContainer.read(globalFailureProvider)?.title,
          testGenericFailure.title,
        );
        return [
          const BaseState<Never>.loading(),
          const BaseState<Never>.initial(),
        ];
      },
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [] and update global failure provider and global loading provider when failure response',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.execute(
          getFailureResponse(),
          withLoadingState: false,
          globalLoading: true,
        );
      },
      expect: () {
        expect(
          providerContainer.read(globalLoadingProvider),
          false,
        );
        expect(
          providerContainer.read(globalFailureProvider)?.title,
          testGenericFailure.title,
        );
        return [];
      },
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [error] and update global loading provider when failure response',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.execute(
          getFailureResponse(),
          withLoadingState: false,
          globalLoading: true,
          globalFailure: false,
        );
      },
      expect: () {
        expect(
          providerContainer.read(globalLoadingProvider),
          false,
        );
        return [
          BaseState<String>.error(testGenericFailure),
        ];
      },
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, data] when successful response withDebounce true',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        stateNotifier.execute(getSuccessfulResponse(), withDebounce: true);
        await stateNotifier.execute(
          getSuccessfulResponse(),
          withDebounce: true,
        );
      },
      expect: () =>
          [const BaseState<Never>.loading(), const BaseState.data('')],
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, data] when successful response and onDataReceived true',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.execute(
          getSuccessfulResponse(),
          onDataReceived: (data) => true,
        );
      },
      expect: () =>
          [const BaseState<Never>.loading(), const BaseState.data('')],
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, initial] when successful response and onDataReceived false',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.execute(
          getSuccessfulResponse(),
          onDataReceived: (data) => false,
        );
      },
      expect: () =>
          [const BaseState<Never>.loading(), const BaseState<Never>.initial()],
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, initial] when failure response and onFailureOccurred false',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.execute(
          getFailureResponse(),
          onFailureOccurred: (failure) => true,
        );
      },
      expect: () =>
          [const BaseState<Never>.loading(), const BaseState<Never>.initial()],
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, error] when failure response and onFailureOccurred true',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.execute(
          getFailureResponse(),
          onFailureOccurred: (failure) => true,
          globalFailure: false,
        );
      },
      expect: () => [
        const BaseState<Never>.loading(),
        BaseState<String>.error(testGenericFailure),
      ],
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, initial] when failure response and onFailureOccurred false',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.execute(
          getFailureResponse(),
          onFailureOccurred: (failure) => false,
        );
      },
      expect: () =>
          [const BaseState<Never>.loading(), const BaseState<Never>.initial()],
    );
  });

  group('executeStreamed method tests', () {
    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, data, data] when successful response stream',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.executeStreamed(getSuccessfulResponseStream());
      },
      expect: () => [
        const BaseState<Never>.loading(),
        const BaseState.data('a'),
        const BaseState.data('b'),
      ],
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [data, data] and update global loading provider when successful response stream',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.executeStreamed(
          getSuccessfulResponseStream(),
          withLoadingState: false,
          globalLoading: true,
        );
      },
      expect: () {
        expect(
          providerContainer.read(globalLoadingProvider.notifier).state,
          false,
        );
        return [const BaseState.data('a'), const BaseState.data('b')];
      },
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, error] when failure response stream',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.executeStreamed(
          getFailureResponseStream(),
          globalFailure: false,
        );
      },
      expect: () => [
        const BaseState<Never>.loading(),
        BaseState<String>.error(testGenericFailure),
      ],
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, initial] and update global failure provider when failure response stream',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.executeStreamed(getFailureResponseStream());
      },
      expect: () {
        expect(
          providerContainer.read(globalFailureProvider)?.title,
          testGenericFailure.title,
        );
        return [
          const BaseState<Never>.loading(),
          const BaseState<Never>.initial(),
        ];
      },
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, data] and update global failure provider when successful then failure response stream',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier
            .executeStreamed(getSuccessThenFailureResponseStream());
      },
      expect: () {
        expect(
          providerContainer.read(globalFailureProvider)?.title,
          testGenericFailure.title,
        );
        return [
          const BaseState<Never>.loading(),
          const BaseState.data('a'),
        ];
      },
    );

    stateNotifierTest<TestNotifier, BaseState<String>>(
      'should emit [loading, data, error] when successful then failure response stream',
      setUp: () {
        providerContainer = getProviderContainer();
      },
      build: () => providerContainer.read(provider.notifier),
      actions: (stateNotifier) async {
        await stateNotifier.executeStreamed(
          getSuccessThenFailureResponseStream(),
          globalFailure: false,
        );
      },
      expect: () {
        return [
          const BaseState<Never>.loading(),
          const BaseState.data('a'),
          BaseState<String>.error(testGenericFailure),
        ];
      },
    );
  });

  group('simple state notifier tests', () {
    test(
      'should set global loading provider to true',
      () {
        final providerContainer = getProviderContainer();
        providerContainer.read(provider.notifier).showGlobalLoading();

        expect(providerContainer.read(globalLoadingProvider), true);
      },
    );

    test(
      'should set global loading provider to false',
      () async {
        final providerContainer = getProviderContainer();
        providerContainer.read(provider.notifier).showGlobalLoading();
        await 500.milliseconds;
        providerContainer.read(provider.notifier).clearGlobalLoading();

        expect(providerContainer.read(globalLoadingProvider), false);
      },
    );

    test(
      'should set global loading provider',
      () {
        final providerContainer = getProviderContainer();
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
      final providerContainer = getProviderContainer();
      providerContainer.read(provider.notifier).on(
        provider2,
        (previous, next) {
          expect(next, const BaseState.data(''));
        },
        skipUpdateCondition: (previous, next) => switch (next) {
          Loading() => true,
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
class TestNotifier extends BaseStateNotifier<String> {
  TestNotifier(super.ref);
}
