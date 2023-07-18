// ignore_for_file: always_use_package_imports, prefer-single-widget-per-file

import 'dart:math';

import 'package:example/presentation/pages/example_simple_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/base_state_notifier.dart';
import 'package:q_architecture/q_architecture.dart';

import '../../domain/notifiers/example_filters/example_filters_provider.dart';
import '../../domain/notifiers/example_notifier/example_state_notifier.dart';
import 'form_example_page.dart';
import 'pagination_example_page.dart';
import 'pagination_stream_example_page.dart';

class ExamplePage extends ConsumerWidget {
  static const routeName = '/';

  const ExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exampleNotifierProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              switch (state) {
                Data(data: final sentence) => sentence,
                Loading() => 'Loading',
                Initial() => 'Initial',
                Error(failure: final failure) => failure.toString(),
              },
            ),
            TextButton(
              onPressed: ref
                  .read(exampleNotifierProvider.notifier)
                  .getSomeStringFullExample,
              child: const Text('Get string'),
            ),
            TextButton(
              onPressed: ref
                  .read(exampleNotifierProvider.notifier)
                  .getSomeStringGlobalLoading,
              child: const Text('Global loading example'),
            ),
            TextButton(
              onPressed: ref
                  .read(exampleNotifierProvider.notifier)
                  .getSomeStringsStreamed,
              child: const Text('Cache + Network loading example'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => ref
                  .read(exampleFiltersProvider.notifier)
                  .update((_) => 'Random ${Random().nextInt(100)}'),
              child: const Text(
                'Update filters (to trigger reload of data)',
              ),
            ),
            TextButton(
              onPressed: () => ref.pushNamed(ExampleSimplePage.routeName),
              child: const Text('Navigate'),
            ),
            TextButton(
              onPressed: () => ref.pushNamed(FormExamplePage.routeName),
              child: const Text('Go to form example'),
            ),
            TextButton(
              onPressed: () => ref.pushNamed(PaginationExamplePage.routeName),
              child: const Text('Go to pagination'),
            ),
            TextButton(
              onPressed: () =>
                  ref.pushNamed(PaginationStreamExamplePage.routeName),
              child: const Text('Go to stream pagination'),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamplePage3 extends ConsumerWidget {
  static const routeName = '${ExampleSimplePage.routeName}/page3';

  const ExamplePage3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {
              // Navigate back to the second screen by popping the current route
              // off the stack.
              ref.pop();
            },
            child: const Text('Go back!'),
          ),
        ],
      ),
    );
  }
}
