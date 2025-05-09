import 'package:q_architecture/q_architecture.dart';

class ExampleFiltersNotifier extends SimpleNotifier<String?> {
  ExampleFiltersNotifier() : super(null);

  void update(String? text) => state = text;
}
