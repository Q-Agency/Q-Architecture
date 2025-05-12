import 'dart:developer';

import 'package:example/domain/notifiers/example_pagination/example_paginated_stream_notifier.dart';
import 'package:example/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:q_architecture/q_architecture.dart';

class PaginationStreamExamplePage extends StatefulWidget {
  static const routeName = '/pagination-stream-example-page';

  const PaginationStreamExamplePage({super.key});

  @override
  State<PaginationStreamExamplePage> createState() =>
      _PaginationStreamExamplePageState();
}

class _PaginationStreamExamplePageState
    extends State<PaginationStreamExamplePage> {
  @override
  void dispose() {
    getIt.resetLazySingleton<ExamplePaginatedStreamNotifier>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Pagination'),
      ),
      body: PaginatedListView(
        paginatedStreamNotifier: getIt<ExamplePaginatedStreamNotifier>(),
        itemBuilder: (context, word, index) => _PaginationExampleTile(word),
        emptyListBuilder: (refresh) => const Center(
          child: Text('list empty'),
        ),
        onError: (failure, listIsEmpty, onRefresh) {
          log('failure occurred: $failure');
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
