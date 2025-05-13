// ignore_for_file: invalid_use_of_protected_member, unused_result

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:q_architecture/q_architecture.dart';

void main() {
  final Failure testGenericFailure =
      Failure.generic(title: 'Unknown error occurred');
  late TestNotifier testNotifier;

  setUpAll(() {
    setupServiceLocator();
  });

  setUp(() {
    testNotifier = TestNotifier();
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
        testNotifier.listen(
          (currentState, _) => states.add(currentState),
          fireImmediately: false,
        );
        await testNotifier.execute(getSuccessfulResponse());
        expect(
          [const BaseState<String>.loading(), const BaseState.data('')],
          states,
        );
      },
    );

    test(
      'should emit [data] and update globalLoadingProvider when successful response',
      () async {
        final states = <BaseState>[];
        testNotifier.listen(
          (currentState, _) => states.add(currentState),
          fireImmediately: false,
        );
        await testNotifier.execute(
          getSuccessfulResponse(),
          withLoadingState: false,
          globalLoading: true,
        );
        expect(
          GetIt.instance<GlobalLoadingNotifier>().value,
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
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.execute(
        getFailureResponse(),
        globalFailure: false,
      );
      expect(
        GetIt.instance<GlobalLoadingNotifier>().value,
        false,
      );
      expect(
        [
          const BaseState<String>.loading(),
          BaseState<String>.error(testGenericFailure),
        ],
        states,
      );
    });

    test(
        'should emit [loading, initial] and update global failure provider when failure response',
        () async {
      final states = <BaseState>[];
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.execute(getFailureResponse());
      expect(
        GetIt.instance<GlobalFailureNotifier>().state?.title,
        testGenericFailure.title,
      );
      expect(
        [
          const BaseState<String>.loading(),
          const BaseState<String>.initial(),
        ],
        states,
      );
    });

    test(
        'should emit [] and update global failure provider and global loading provider when failure response',
        () async {
      final states = <BaseState>[];
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.execute(
        getFailureResponse(),
        withLoadingState: false,
        globalLoading: true,
      );
      expect(
        GetIt.instance<GlobalLoadingNotifier>().value,
        false,
      );
      expect(
        GetIt.instance<GlobalFailureNotifier>().state?.title,
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
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.execute(
        getFailureResponse(),
        withLoadingState: false,
        globalLoading: true,
        globalFailure: false,
      );
      expect(
        GetIt.instance<GlobalLoadingNotifier>().value,
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
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.execute(
        getSuccessfulResponse(),
        onDataReceived: (data) => true,
      );
      expect(
        [const BaseState<String>.loading(), const BaseState.data('')],
        states,
      );
    });

    test(
      'should emit [loading, initial] when successful response and onDataReceived false',
      () async {
        final states = <BaseState>[];
        testNotifier.listen(
          (currentState, _) => states.add(currentState),
          fireImmediately: false,
        );
        await testNotifier.execute(
          getSuccessfulResponse(),
          onDataReceived: (data) => false,
        );
        expect(
          [
            const BaseState<String>.loading(),
            const BaseState<String>.initial(),
          ],
          states,
        );
      },
    );

    test(
        'should emit [loading, initial] when failure response and onFailureOccurred false',
        () async {
      final states = <BaseState>[];
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.execute(
        getFailureResponse(),
        onFailureOccurred: (failure) => false,
      );
      expect(
        [const BaseState<String>.loading(), const BaseState<String>.initial()],
        states,
      );
    });

    test(
        'should emit [loading, error] when failure response and onFailureOccurred true',
        () async {
      final states = <BaseState>[];
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.execute(
        getFailureResponse(),
        onFailureOccurred: (failure) => true,
        globalFailure: false,
      );
      expect(
        [
          const BaseState<String>.loading(),
          BaseState<String>.error(testGenericFailure),
        ],
        states,
      );
    });

    test(
        'should emit [loading, initial] when failure response and onFailureOccurred false',
        () async {
      final states = <BaseState>[];
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.execute(
        getFailureResponse(),
        onFailureOccurred: (failure) => false,
      );
      expect(
        [const BaseState<String>.loading(), const BaseState<String>.initial()],
        states,
      );
    });
  });

  group('executeStreamed method tests', () {
    test('should emit [loading, data, data] when successful response stream',
        () async {
      final states = <BaseState>[];
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.executeStreamed(getSuccessfulResponseStream());
      expect(
        [
          const BaseState<String>.loading(),
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
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.executeStreamed(
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
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.executeStreamed(
        getFailureResponseStream(),
        globalFailure: false,
      );
      expect(
        [
          const BaseState<String>.loading(),
          BaseState<String>.error(testGenericFailure),
        ],
        states,
      );
    });

    test(
        'should emit [loading, initial] and update global failure provider when failure response stream',
        () async {
      final states = <BaseState>[];
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.executeStreamed(getFailureResponseStream());
      expect(
        GetIt.instance<GlobalFailureNotifier>().state?.title,
        testGenericFailure.title,
      );
      expect(
        [const BaseState<String>.loading(), const BaseState<String>.initial()],
        states,
      );
    });

    test(
        'should emit [loading, data] and update global failure provider when successful then failure response stream',
        () async {
      final states = <BaseState>[];
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.executeStreamed(getSuccessThenFailureResponseStream());
      expect(
        GetIt.instance<GlobalFailureNotifier>().state?.title,
        testGenericFailure.title,
      );
      expect(
        [
          const BaseState<String>.loading(),
          const BaseState.data('a'),
        ],
        states,
      );
    });

    test(
        'should emit [loading, data, error] when successful then failure response stream',
        () async {
      final states = <BaseState>[];
      testNotifier.listen(
        (currentState, _) => states.add(currentState),
        fireImmediately: false,
      );
      await testNotifier.executeStreamed(
        getSuccessThenFailureResponseStream(),
        globalFailure: false,
      );
      expect(
        [
          const BaseState<String>.loading(),
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
        GetIt.instance<GlobalLoadingNotifier>().showGlobalLoading();
        expect(GetIt.instance<GlobalLoadingNotifier>().value, true);
      },
    );

    test(
      'should set global loading provider to false',
      () async {
        GetIt.instance<GlobalLoadingNotifier>().showGlobalLoading();
        await 500.milliseconds;
        GetIt.instance<GlobalLoadingNotifier>().clearGlobalLoading();

        expect(GetIt.instance<GlobalLoadingNotifier>().value, false);
      },
    );

    test(
      'should set global loading provider',
      () {
        GetIt.instance<GlobalFailureNotifier>().setGlobalFailure(
          testGenericFailure,
        );
        expect(
          GetIt.instance<GlobalFailureNotifier>().state?.title,
          testGenericFailure.title,
        );
      },
    );
  });
}

class TestNotifier extends BaseNotifier<String> {}
