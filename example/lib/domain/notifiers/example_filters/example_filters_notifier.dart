import 'package:q_architecture/q_architecture.dart';

class ExampleFiltersNotifier extends QNotifier<String?> {
  ExampleFiltersNotifier() : super(null);

  void update(String? text) => state = text;
}
