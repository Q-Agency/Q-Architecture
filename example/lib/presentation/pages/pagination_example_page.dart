import 'dart:developer';

import 'package:example/domain/notifiers/example_pagination/example_paginated_notifier.dart';
import 'package:example/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:q_architecture/q_architecture.dart';

class PaginationExamplePage extends StatefulWidget {
  static const routeName = '/pagination-example-page';

  const PaginationExamplePage({super.key});

  @override
  State<PaginationExamplePage> createState() => _PaginationExamplePageState();
}

class _PaginationExamplePageState extends State<PaginationExamplePage> {
  @override
  void dispose() {
    getIt.resetLazySingleton<ExamplePaginatedNotifier>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagination'),
      ),
      body: PaginatedListView(
        itemBuilder: (context, word, index) => _PaginationExampleTile(word),
        paginatedStreamNotifier: getIt<ExamplePaginatedNotifier>(),
        emptyListBuilder: (refresh) => const Center(
          child: Text('list empty'),
        ),
        onError: (failure, listIsEmpty, onRefresh) {
          log('failure occurred: $failure');
          if (listIsEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $failure'),
                TextButton(
                  onPressed: onRefresh,
                  child: const Text('Refresh'),
                ),
              ],
            );
          }
          return null;
        },
      ),
    );
  }
}

class _PaginationExampleTile extends StatelessWidget {
  final String word;
  const _PaginationExampleTile(this.word);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Text(word),
    );
  }
}
