// ignore_for_file: always_use_package_imports
// ignore_for_file: avoid-dynamic

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/navigation_provider.dart';
import 'route_action.dart';

extension NavigationExtensions on WidgetRef {
  void pop() =>
      read(globalNavigationProvider.notifier).update((_) => PopAction());

  void pushNamed(String routeName, {dynamic data}) =>
      read(globalNavigationProvider.notifier)
          .update((_) => PushNamedAction(routeName, data));

  void pushReplacementNamed(String routeName, {dynamic data}) =>
      read(globalNavigationProvider.notifier)
          .update((_) => PushReplacementNamedAction(routeName, data));
}
