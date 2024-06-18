## 1.0.1

Fix in BaseNotifierMixin initWithRefAndGetOrUpdateState method

## 1.0.0

- Added SimpleNotifier and BaseNotifier classes (SimpleNotifier,
  AutoDisposeSimpleNotifier, FamilySimpleNotifier and
  AutoDisposeFamilySimpleNotifier and similar for BaseNotifier) which extend
  Notifier, updated all the examples to use new Notifier classes instead of
  StateNotifier which will be kept only for legacy purpose
- BREAKING CHANGE: Renamed PaginatedNotifier and PaginatedStreamNotifier to
  PaginatedStateNotifier and PaginatedStreamStateNotifier and created new
  PaginatedNotifier and PaginatedStreamNotifier which are based on Notifier,
  renamed base_state_notifier to base_notifier for importing BaseNotifier and
  BaseStateNotifier classes
- updated examples to work with new Notifier subclasses
- added FormWithOptionMapper for cases when additional data is needed when
  mapping form data

## 0.1.9

Renamed PaginatedListView parameter from autoDisposeStateNotifier to
autoDisposeStateNotifierProvider, added throttleIdentifier parameter to throttle
and cancelThrottle function in SimpleStateNotifier to enable multiple uses at
the same time in the same notifier

## 0.1.8

Added index parameter to PaginatedListView's itemBuilder attribute and
documented PaginatedListView's attributes

## 0.1.7

Added throttle method to SimpleStateNotifier, renamed BaseWidget's onFailure
callback to onGlobalFailure

## 0.1.5

Added optional scrollbarWidgetBuilder and scrollController parameters to
PaginatedListView

## 0.1.4

Added iterable_extension.dart to q_architecture export file

## 0.1.3

Added ErrorToFailure mixin for easier error handling in repositories

## 0.1.2

Added either_dart dependency instead of custom implementation

## 0.1.1

Added README example

## 0.1.0

Initial release
