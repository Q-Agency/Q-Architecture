import 'package:hooks_riverpod/hooks_riverpod.dart';

final exampleFiltersProvider = StateProvider<String?>((ref) => null);

// This is also possible, subscription will work the same for StateProvider
// and for NotifierProvider

// final exampleFiltersProvider =
//     NotifierProvider<ExampleFiltersNotifier, String?>(
//   () => ExampleFiltersNotifier(),
// );

// class ExampleFiltersNotifier extends SimpleNotifier<String?> {
//   @override
//   String? prepareForBuild() => null;

//   void update(String? text) => state = text;
// }
