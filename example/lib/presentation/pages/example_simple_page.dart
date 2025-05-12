import 'dart:developer';

import 'package:example/domain/notifiers/example_simple_notifier/example_simple_notifier.dart';
import 'package:example/domain/notifiers/example_simple_notifier/example_simple_state.dart';
import 'package:example/service_locator.dart';
import 'package:flutter/material.dart';

class ExampleSimplePage extends StatefulWidget {
  static const routeName = '/simple-page';

  const ExampleSimplePage({super.key});

  @override
  State<ExampleSimplePage> createState() => _ExampleSimplePageState();
}

class _ExampleSimplePageState extends State<ExampleSimplePage> {
  @override
  void dispose() {
    getIt.resetLazySingleton<ExampleSimpleNotifier>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exampleSimpleNotifier = getIt<ExampleSimpleNotifier>();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder(
            valueListenable: exampleSimpleNotifier,
            builder: (context, value, child) {
              log('state: $value');
              return Text(
                switch (value) {
                  Initial() => 'Initial',
                  Empty() => 'Empty',
                  Fetching() => 'Fetching',
                  Success(sentence: final string) => string,
                  Error(:final failure) => failure.title,
                },
                textAlign: TextAlign.center,
              );
            },
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
    );
  }
}
