import 'package:example/domain/notifiers/example_simple_notifier/example_simple_notifier.dart';
import 'package:example/domain/notifiers/example_simple_notifier/example_simple_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ExampleSimplePage extends ConsumerWidget {
  static const routeName = '/simple-page';

  const ExampleSimplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exampleSimpleNotifierProvider);
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
              Error(:final failure) => failure.title,
            },
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(exampleSimpleNotifierProvider.notifier)
                  .getSomeStringSimpleExample();
              ref
                  .read(exampleSimpleNotifierProvider.notifier)
                  .getSomeStringSimpleExample();
            },
            child: const Text('Simple state example with debounce'),
          ),
          TextButton(
            onPressed: ref
                .read(exampleSimpleNotifierProvider.notifier)
                .getSomeStringSimpleExampleGlobalLoading,
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
