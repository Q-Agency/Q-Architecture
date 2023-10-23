import 'package:example/domain/notifiers/example_simple_notifier/example_simple_state.dart';
import 'package:example/domain/notifiers/example_simple_notifier/example_simple_state_notifier.dart';
import 'package:example/presentation/pages/example_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ExampleSimplePage extends ConsumerWidget {
  static const routeName = '/simple-page';

  const ExampleSimplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exampleSimpleStateNotifierProvider);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            switch (state) {
              Initial() => 'Initial',
              Empty() => 'Empty',
              Fetching() => 'Fetching',
              Success(sentence: final string) => string,
              Error(failure: final failure) => failure.title,
            },
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(exampleSimpleStateNotifierProvider.notifier)
                  .getSomeStringSimpleExample();
              ref
                  .read(exampleSimpleStateNotifierProvider.notifier)
                  .getSomeStringSimpleExample();
            },
            child: const Text('Simple state example with debounce'),
          ),
          TextButton(
            onPressed: ref
                .read(exampleSimpleStateNotifierProvider.notifier)
                .getSomeStringSimpleExampleGlobalLoading,
            child: const Text('Global loading example'),
          ),
          ElevatedButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Go back!'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(ExamplePage3.routeName),
            child: const Text('Navigate'),
          ),
        ],
      ),
    );
  }
}
