import 'package:example/presentation/pages/example_page.dart';
import 'package:example/presentation/pages/example_simple_page.dart';
import 'package:example/presentation/pages/form_example_page.dart';
import 'package:example/presentation/pages/pagination_example_page.dart';
import 'package:example/presentation/pages/pagination_stream_example_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routes: {
          ExamplePage.routeName: (_) => const ExamplePage(),
          FormExamplePage.routeName: (_) => FormExamplePage(),
          PaginationExamplePage.routeName: (_) => const PaginationExamplePage(),
          PaginationStreamExamplePage.routeName: (_) =>
              const PaginationStreamExamplePage(),
          ExampleSimplePage.routeName: (_) => const ExampleSimplePage(),
        },
      ),
    );
  }
}
