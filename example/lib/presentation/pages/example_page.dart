import 'dart:math';

import 'package:example/domain/notifiers/example_filters/example_filters_notifier.dart';
import 'package:example/domain/notifiers/example_notifier/example_notifier.dart';
import 'package:example/presentation/pages/example_simple_page.dart';
import 'package:example/presentation/pages/pagination_example_page.dart';
import 'package:example/presentation/pages/pagination_stream_example_page.dart';
import 'package:example/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:q_architecture/q_architecture.dart';

class ExamplePage extends StatefulWidget {
  static const routeName = '/';

  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  @override
  void dispose() {
    getIt.unregister<ExampleNotifier>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exampleNotifier = getIt<ExampleNotifier>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: exampleNotifier,
              builder: (context, value, child) {
                return Text(
                  switch (value) {
                    BaseData(data: final sentence) => sentence,
                    BaseLoading() => 'Loading',
                    BaseInitial() => 'Initial',
                    BaseError(:final failure) => failure.toString(),
                  },
                );
              },
            ),
            TextButton(
              onPressed: exampleNotifier.getSomeStringFullExample,
              child: const Text('Get string'),
            ),
            TextButton(
              onPressed: exampleNotifier.getSomeStringGlobalLoading,
              child: const Text('Global loading example'),
            ),
            TextButton(
              onPressed: exampleNotifier.getSomeStringsStreamed,
              child: const Text('Cache + Network loading example'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => getIt<ExampleFiltersNotifier>().update(
                'Random ${Random().nextInt(100)}',
              ),
              child: const Text(
                'Update filters (to trigger reload of data)',
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(ExampleSimplePage.routeName),
              child: const Text('Navigate'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pushNamed(PaginationExamplePage.routeName),
              child: const Text('Go to pagination'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pushNamed(PaginationStreamExamplePage.routeName),
              child: const Text('Go to stream pagination'),
            ),
          ],
        ),
      ),
    );
  }
}
