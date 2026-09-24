import 'package:example/presentation/pages/example_page.dart';
import 'package:example/presentation/pages/example_simple_page.dart';
import 'package:example/presentation/pages/pagination_example_page.dart';
import 'package:example/presentation/pages/pagination_stream_example_page.dart';
import 'package:example/presentation/widgets/message_displaying_base_widget.dart';
import 'package:example/service_locator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:q_architecture/q_architecture.dart';

void main() {
  initQArchitecture(
    observers: [LoggingObserver()],
  );
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

class LoggingObserver implements QNotifierObserver {
  @override
  void onDisposed(QNotifier notifier, finalState) {
    debugPrint('🔴 [$notifier] Disposed: $finalState');
  }

  @override
  void onInitialized(QNotifier notifier, initialState) {
    debugPrint('🟢 [$notifier] Init: $initialState');
  }

  @override
  void onStateChanged(QNotifier notifier, previousState, currentState) {
    debugPrint('🔄 [$notifier] State Changed: $previousState → $currentState');
  }
}
