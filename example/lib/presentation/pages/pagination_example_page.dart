//ignore_for_file: always_use_package_imports
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/q_architecture.dart';

import '../../domain/notifiers/example_pagination/example_paginated_notifier.dart';

class PaginationExamplePage extends ConsumerWidget {
  static const routeName = '/pagination-example-page';

  const PaginationExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagination'),
      ),
      body: PaginatedListView(
        itemBuilder: (context, word, index) => _PaginationExampleTile(word),
        autoDisposeNotifierProvider: paginatedNotifierProvider,
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
