import 'package:example/presentation/pages/example_page.dart';
import 'package:example/presentation/pages/example_simple_page.dart';
import 'package:example/presentation/pages/pagination_example_page.dart';
import 'package:example/presentation/pages/pagination_stream_example_page.dart';
import 'package:example/presentation/widgets/message_displaying_base_widget.dart';
import 'package:example/service_locator.dart';
import 'package:flutter/material.dart';

void main() {
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Q Architecture',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        ExamplePage.routeName: (_) => const ExamplePage(),
        PaginationExamplePage.routeName: (_) => const PaginationExamplePage(),
        PaginationStreamExamplePage.routeName: (_) =>
            const PaginationStreamExamplePage(),
        ExampleSimplePage.routeName: (_) => const ExampleSimplePage(),
      },
      builder: (context, child) => Material(
        type: MaterialType.transparency,
        child: MessageDisplayingBaseWidget(child: child),
      ),
    );
  }
}
