import 'package:example/domain/notifiers/example_simple_notifier/example_simple_notifier.dart';
import 'package:example/domain/notifiers/example_simple_notifier/example_simple_state.dart';
import 'package:example/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:q_architecture/q_architecture.dart';

class ExampleSimplePage extends StatelessWidget {
  static const routeName = '/simple-page';

  const ExampleSimplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final exampleSimpleNotifier = getIt<ExampleSimpleNotifier>();
    return Scaffold(
      body: SimpleNotifierListener(
        simpleNotifier: exampleSimpleNotifier,
        listener: (currentState, previousState) {
          debugPrint('currentState: $currentState');
          debugPrint('previousState: $previousState');
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SimpleNotifierBuilder(
              simpleNotifier: exampleSimpleNotifier,
              builder: (context, currentState, previousState, child) => Text(
                switch (currentState) {
                  Initial() => 'Initial',
                  Empty() => 'Empty',
                  Fetching() => 'Fetching',
                  Success(sentence: final string) => string,
                  Error(:final failure) => failure.title,
                },
                textAlign: TextAlign.center,
              ),
            ),
            TextButton(
              onPressed: () {
                exampleSimpleNotifier.getSomeStringSimpleExample();
                exampleSimpleNotifier.getSomeStringSimpleExample();
              },
              child: const Text('Simple state example with debounce'),
            ),
            TextButton(
              onPressed:
                  exampleSimpleNotifier.getSomeStringSimpleExampleGlobalLoading,
              child: const Text('Global loading example'),
            ),
            ElevatedButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Go back!'),
            ),
          ],
        ),
      ),
    );
  }
}
