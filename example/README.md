# Q-Architecture

A set of reusable classes that should speed up your development time and reduce
unnecessary boilerplate code. Powered by
[riverpod](https://pub.dev/packages/riverpod).

## Get started

- Create your abstract repository and implement it

```dart
final repositoryProvider = Provider<YourRepository>(
      (_) => YourRepositoryImplementation(),
);

abstract class YourRepository {
  EitherFailureOr<String> getYourString();
}

class YourRepositoryImplementation implements YourRepository {
  @override
  EitherFailureOr<String> getYourString() async {
    await Future.delayed(const Duration(seconds: 3));
    if (Random().nextBool()) {
      return const Right('Your string');
    } else {
      return Left(Failure.generic());
    }
  }
}
```

- Create your Notifier which extends BaseNotifier and add method to call your
  YourRepository.getYourString() method

```dart
class YourNotifier extends BaseNotifier<String> {
  late YourRepository _yourRepository;

  YourNotifier(this._yourRepository, super.ref);

  @override
  void prepareForBuild() {
    _yourRepository = ref.watch(repositoryProvider);
  }

  Future getYourString() =>
      execute(
        _yourRepository.getYourString(),
        withLoadingState: true,
        globalLoading: false,
        globalFailure: false,
      );
}
```

- Create provider for YourNotifier.

```dart
final yourNotifierProvider = NotifierProvider<YourNotifier, BaseState<String>>(
  () => YourNotifier()
);
```

- In your widget call your notifier getYourString() method through your provider
  and watch for the changes

```
ref.read(yourNotifierProvider.notifier).getYourString();
final state = ref.watch(yourNotifierProvider);
switch (state) {
  Data(data: final sentence) => sentence,
  Loading() => 'Loading',
  Initial() => 'Initial',
  Error(failure: final failure) => failure.toString(),
},
```

That is all you need to get you started, to find out more, head over to the
table of contents.

## Table of contents

- [Example - BaseNotifier](#example---basenotifier)
  - [ExampleNotifier](#examplenotifier)
  - [ExamplePage](#examplepage)
- [Example - SimpleNotifier](#example---simplenotifier)
  - [ExampleSimpleNotifier](#examplesimplenotifier)
  - [ExampleSimplePage](#examplesimplepage)
- [BaseState<State>](#basestatestate)
- [SimpleNotifier](#simplenotifier)
- [BaseNotifier](#basenotifier)
- [PaginatedStreamNotifier and PaginatedNotifier](#paginatedstreamnotifier-and-paginatednotifier)
- [Global loading](#global-loading)
- [Global failure](#global-failure)
- [Global info](#global-info)
- [BaseWidget](#basewidget)
- [ErrorToFailureMixin](#errortofailuremixin)

## Example - BaseNotifier

BaseNotifier is a generic notifier which every notifier should extend to avoid
writing repetitive code and access global loading and failure handling.

### ExampleNotifier

```dart
final exampleNotifierProvider = NotifierProvider<ExampleStateNotifier, BaseState<String>>(
     () => ExampleNotifier(),
);

class ExampleNotifier extends BaseNotifier<String> {
 late ExampleRepository _exampleRepository;

 @override
 void prepareForBuild() {
   _exampleRepository = ref.watch(exampleRepositoryProvider);
 }

 Future getSomeStringFullExample() =>
     execute(
       //Function that is called. Needs to have the same success return type as State
       _exampleRepository.getSomeString(),

       //Set to true if you want to handle error globally (ex. Show error dialog above the entire app)
       globalFailure: true,

       //Set to true if you want to show BaseLoadingIndicator above the entire app
       globalLoading: false,

       //Set to true if you want to update state to BaseState.loading()
       withLoadingState: true,

       //Do some actions with data
       //If you return true, base state will be updated to BaseState.data(data)
       //If you return false, depending on withLoadingState, if true it will be 
       //updated to BaseState.initial() otherwise won't be updated at all
       onDataReceived: (data) {
         // Custom handle data
         return true;
       },

       //Do some actions with failure
       //If you return true, base state will be updated to BaseState.error(failure)
       //If you return false, depending on withLoadingState, if true it will be 
       //updated to BaseState.initial() otherwise won't be updated at all
       onFailureOccurred: (failure) {
         // Custom handle data
         return true;
       },
     );

 //Example of the API request with global loading indicator
 Future getSomeStringGlobalLoading() =>
     execute(
       _exampleRepository.getSomeString(),
       globalLoading: true,
       withLoadingState: false,
     );
}
```

### ExamplePage

```dart
class ExamplePage extends ConsumerWidget {
 static const routeName = '/';

 const ExamplePage({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context, WidgetRef ref) {
   final state = ref.watch(exampleNotifierProvider);
   return Scaffold(
     body: Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Text(
             switch (state) {
               Data(data: final sentence) => sentence,
               Loading() => 'Loading',
               Initial() => 'Initial',
               Error(failure: final failure) => failure.toString(),
             },
           ),
           TextButton(
             onPressed: ref
                 .read(exampleNotifierProvider.notifier)
                 .getSomeStringFullExample,
             child: const Text('Get string'),
           ),
           TextButton(
             onPressed: ref
                 .read(exampleNotifierProvider.notifier)
                 .getSomeStringGlobalLoading,
             child: const Text('Global loading example'),
           ),
           //Navigation example
           TextButton(
             onPressed: () => ref.pushNamed(ExamplePage2.routeName),
             child: const Text('Navigate'),
           ),
         ],
       ),
     ),
   );
 }
}
```

## Example - SimpleNotifier

If BaseNotifier restrain you in some way and its BaseState does not cover your
use case, but you want to use some benefits of BaseNotifier, then SimpleNotifier
is here for you.

### ExampleSimpleNotifier

```dart
final exampleSimpleNotifierProvider = NotifierProvider.autoDispose<
    ExampleSimpleNotifier, ExampleSimpleState>(
  () => ExampleSimpleNotifier(),
);

class ExampleSimpleNotifier
    extends AutoDisposeSimpleNotifier<ExampleSimpleState> {
  final ExampleRepository _exampleRepository;

  @override
  ExampleSimpleState prepareForBuild() {
    _exampleRepository = ref.watch(exampleRepositoryProvider);
    return const ExampleSimpleState.initial();
  }

  /// Example method when you want to get state updates when calling some repository method
  Future<void> getSomeStringSimpleExample() async {
    await debounce();
    state = const ExampleSimpleState.fetching();
    final result = await _exampleRepository.getSomeOtherString();
    result.fold(
      (failure) {
        state = ExampleSimpleState.error(failure);
      },
      (data) {
        if (data.isEmpty) {
          state = const ExampleSimpleState.empty();
        } else {
          state = ExampleSimpleState.success(data);
        }
      },
    );
  }

  /// Example method when you want to use global loading and global failure methods
  /// when calling some repository method
  Future<void> getSomeStringSimpleExampleGlobalLoading() async {
    showGlobalLoading();
    final result = await _exampleRepository.getSomeOtherString();
    result.fold(
      (failure) {
        setGlobalFailure(failure);
      },
      (data) {
        clearGlobalLoading();
        if (data.isEmpty) {
          state = const ExampleSimpleState.empty();
        } else {
          state = ExampleSimpleState.success(data);
        }
      },
    );
  }
}
```

### Example custom state

```dart
import 'package:equatable/equatable.dart';

import '../entities/failure.dart';

sealed class ExampleSimpleState extends Equatable {
  const ExampleSimpleState();

  const factory ExampleSimpleState.empty() = Empty;
  const factory ExampleSimpleState.fetching() = Fetching;
  const factory ExampleSimpleState.error(Failure failure) = Error;
  const factory ExampleSimpleState.success(String data) = Success;
}

final class Empty extends ExampleSimpleState {
  const Empty();

  @override
  List<Object?> get props => [];
}

final class Fetching extends ExampleSimpleState {
  const Fetching();

  @override
  List<Object?> get props => [];
}

final class Error extends ExampleSimpleState {
  final Failure failure;

  const Error(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class Success extends ExampleSimpleState {
  final String data;

  const Data(this.data);

  @override
  List<Object?> get props => [data];
}
```

### ExampleSimplePage

```dart
class ExampleSimplePage extends ConsumerWidget {
  static const routeName = '/simple-page';

  const ExampleSimplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exampleSimpleNotifierProvider);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            switch (state) {
              Initial() => 'Initial',
              Empty() => 'Empty',
              Fetching() => 'Fetching',
              Success(sentence: final string) => string,
              Error(failure: final failure) => failure.title,
            },
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(exampleSimpleNotifierProvider.notifier)
                  .getSomeStringSimpleExample();
              ref
                  .read(exampleSimpleNotifierProvider.notifier)
                  .getSomeStringSimpleExample();
            },
            child: const Text('Simple state example with debounce'),
          ),
          TextButton(
            onPressed: ref
                .read(exampleSimpleNotifierProvider.notifier)
                .getSomeStringSimpleExampleGlobalLoading,
            child: const Text('Global loading example'),
          ),
          ElevatedButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Go back!'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(ExamplePage3.routeName),
            child: const Text('Navigate'),
          ),
        ],
      ),
    );
  }
}
```

## BaseState<State>

BaseState has 4 primary states:

1. **initial**

2. **loading**

3. **data(State)** - ex. Used for showing successful API call response

4. **error(Failure)**

**State** has to be the same type as the return value from the function that is
called

```dart
sealed class BaseState<State> extends Equatable {
  const BaseState();

  const factory BaseState.initial() = Initial;
  const factory BaseState.loading() = Loading;
  const factory BaseState.error(Failure failure) = Error;
  const factory BaseState.data(State data) = Data;
}

final class Initial<State> extends BaseState<State> {
  const Initial();

  @override
  List<Object?> get props => [];
}

final class Loading<State> extends BaseState<State> {
  const Loading();

  @override
  List<Object?> get props => [];
}

final class Error<State> extends BaseState<State> {
  final Failure failure;

  const Error(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class Data<State> extends BaseState<State> {
  final State data;

  const Data(this.data);

  @override
  List<Object?> get props => [data];
}
```

## SimpleNotifier

Abstract Notifier class which provides some convenient methods to be used by
subclassing it. It can be used when BaseState doesn't suit you and you need more
states, this notifier has **showGlobalLoading**, **clearGlobalLoading**,
**setGlobalFailure**, **on**, **debounce**, **throttle** and **cancelThrottle**
methods that are marked as **@protected** so you can easily use them in your
subclasses.

- **showGlobalLoading** & **clearGlobalLoading** for handling global loading

- **setGlobalFailure** for handling global failure (will automatically call
  **clearGlobalLoading** before showing global failure)

- **on** for subscribing to another notifier's state changes so you can react
  appropriately

- **debounce** for waiting multiple method calls before only one method call can
  be executed

- **throttle** for executing only first method call for some duration when there
  are multiple method calls

- **cancelThrottle** for canceling throttling if in progress

## BaseNotifier

Abstract Notifier class which extends SimpleNotifier, uses BaseState as its
state and provides some convenient methods to be used by subclassing it.

### Execute method

The main **BaseNotifier** method which supports different options for handling
the data, failures and loading.

```dart
@protected
Future execute(EitherFailureOr<DataState> function, {
  PreHandleData<DataState>? onDataReceived,
  PreHandleFailure? onFailureOccurred,
  bool withLoadingState = true,
  bool globalLoading = false,
  bool globalFailure = true,
});
```

- **function** parameter receives method to execute with return value
  EitherFailureOr<DataState>.

- **withLoadingState** bool parameter says while calling and waiting
  **function** to finish, loading state should be set.

- **globalLoading** bool parameter says while calling and waiting **function**
  to finish, loading over the the whole app should be shown.

- **globalFailure** bool parameter says if **function** returns Failure, should
  it be shown globally over the whole app or not. &nbsp;

To filter and control which data will update the state, **onDataReceived**
callback can be passed. Alternatively, if callback always return false, custom
data handling can be implemented. &nbsp;

To filter and control which failure will update the state or be shown globally,
** onFailureOccurred** callback can be passed. Similar to **onDataReceived** if
always returned false, custom failure handling can be implemented.

### Execute streamed method

Similar to **BaseNotifier**'s **execute** method is the **executeStreamed**
method which in the core performs the same job as the execute method with a
slight difference in that it requires a **function** parameter's return type to
be of type **Stream** which allows us to return multiple results from the
repository and by doing so we can use this functionality to create an easy to
use caching mechanism by yielding cached data + network data.

```
@protected
Future<void> executeStreamed(
  StreamFailureOr<DataState> function, {
  PreHandleData<DataState>? onDataReceived,
  PreHandleFailure? onFailureOccurred,
  bool withLoadingState = true,
  bool globalLoading = false,
  bool globalFailure = true,
});
```

#### Example usage

In your state notifier:

```
class ExampleNotifier extends BaseNotifier<String> {
//...
Future getSomeStringsStreamed() => executeStreamed(
      _exampleRepository.getSomeStringsStreamed(),
);
```

In repository:

```
@override
StreamFailureOr<String> getSomeStringsStreamed() async* {
  yield const Right('Some sentence from cache');
  //...
  yield const Right('Some sentence from network');
}
```

## PaginatedStreamNotifier and PaginatedNotifier

Abstract Notifier classes to be used when you need to work with some kind of
list you fetch from local or remote data source.

### PaginatedStreamNotifier

PaginatedStreamNotifier extends SimpleNotifier, uses PaginatedState and provides
`PaginatedStreamFailureOr<Entity> getListStreamOrFailure(int page, [Param? parameter])`
to be overridden by the notifier subclassing it. This notifier works with
streams so `getListStreamOrFailure` method if necessary can return first list
fetched from local data source and then from remote data source when retrieved.

### PaginatedNotifier

PaginatedNotifier extends PaginatedStreamNotifier and simplifies it in a way
that class that extends it needs to override
`PaginatedEitherFailureOr<Entity> getListOrFailure(int page, [Param? parameter])`
which returns a Future instead of Stream.

### PaginatedList

Methods that need to be overridden by extending PaginatedStreamNotifier or
PaginatedNotifier return PaginatedList object with few convenient field for
handling infinite lists.

```dart
class PaginatedList<T> extends Equatable {
  final List<T> data;
  final int page;
  final bool isLast;

  const PaginatedList({
    required this.data,
    required this.page,
    required this.isLast,
  });

  @override
  List<Object?> get props => [data];
}
```

### PaginatedState

Consists of 4 states, initial loading(), loadingMore() with List<T> parameter to
be shown while fetching next batch of items, loaded() with List<T> parameter to
show all the list data fetched upon that moment and error with List<T> and
Failure parameters if some error occurs while fetching new batch of items, list
parameter serves if you still want to show on the screen all the list data
fetched until that moment.

```dart
sealed class PaginatedState<T> extends Equatable {
  const PaginatedState();

  const factory PaginatedState.loading() = PaginatedLoading;
  const factory PaginatedState.loadingMore(List<T> list) = LoadingMore;
  const factory PaginatedState.loaded(List<T> list, {bool isLastPage}) = Loaded;
  const factory PaginatedState.error(List<T> list, Failure failure) =
      PaginatedError;
}

final class PaginatedLoading<T> extends PaginatedState<T> {
  const PaginatedLoading();

  @override
  List<Object?> get props => [];
}

final class LoadingMore<T> extends PaginatedState<T> {
  final List<T> list;
  const LoadingMore(this.list);

  @override
  List<Object?> get props => [list];
}

final class PaginatedError<T> extends PaginatedState<T> {
  final Failure failure;
  final List<T> list;

  const PaginatedError(this.list, this.failure);

  @override
  List<Object?> get props => [list, failure];
}

final class Loaded<T> extends PaginatedState<T> {
  final List<T> list;
  final bool isLastPage;

  const Loaded(
    this.list, {
    this.isLastPage = false,
  });

  @override
  List<Object?> get props => [list];
}
```

### PaginatedListView

PaginatedListView widget can be used to easily work with PaginatedStreamNotifier
or PaginatedNotifier and display the data served through one of those two
notifiers.

## Global loading

**globalLoadingProvider** can be used to show the loading indicator without
updating **BaseNotifier** state.

```dart
final globalLoadingProvider = StateProvider<bool>((_) => false);
```

### Loading example

**BaseLoadingIndicator** can be shown by setting **globalLoading** inside of
execute method to **true**

```dart
//...
Future getSomeString() =>
    execute(
      _exampleRepository.getSomeString(),
      globalLoading: true,
    );
//...
```

You can also change **BaseNotifier** state to BaseState.loading by setting
**withLoadingState** to **true**

```dart
//...
Future getSomeString() =>
    execute(
      _exampleRepository.getSomeString(),
      globalLoading: true,
      withLoadingState: true,
    );
//...
```

## Global failure

**globalFailureProvider** can be used to show the failure that happened in the
application without updating **BaseNotifier** state.

```dart
final globalFailureProvider = StateProvider<Failure?>((_) => null);
```

### Global failure listener

```dart
void globalFailureListener() {
  listen<Failure?>(globalFailureProvider, (_, failure) {
    if (failure == null) return;
    //Show global error
    logError('''showing ${failure.isCritical ? '' : 'non-'}critical failure with title ${failure.title},
          error: ${failure.error},
          stackTrace: ${failure.stackTrace}
      ''');
  });
}
```

### Failure example

**globalFailureProvider** listener will be triggered by setting
**globalFailure** inside of execute method to **true** when failure happens. If
set to false, instead of updating globalFailureProvider, **BaseNotifier** state
will be set to error so the failure can be shown directly on the screen, not in
the overlay as a toast or a dialog.

```dart
//...
Future getSomeString() =>
    execute(
      _exampleRepository.getSomeString(),
      globalFailure: false,
    );
//...
```

## Global info

**globalInfoProvider** can be used to show any info by passing the info status
with GlobalInfoStatus. GlobalInfoStatus contains values: info, warning, error,
success. Pass the required info status, and message of info that will be
presented to the user. To set GlobalInfo from any notifier, just call
setGlobalInfo() function defined in SimpleNotifier.

Suggestion: setGlobalInfo() can be called from onDataReceived() callback inside
execute() function if there is a need to show alert directly from notifier,
right after request. For any other usage outside of notifier, set the value of
**globalInfoProvider** directly.

```dart
final globalInfoProvider = StateProvider<GlobalInfo?>((_) => null);
```

### GlobalInfo listener

```dart
void globalInfoListener() {
  listen<GlobalInfo?>(globalInfoProvider, (_, globalInfo) {
    if (globalInfo == null) return;
    //Show global error
    logInfo(''' 
        globalInfoStatus: ${globalInfo.globalInfoStatus}
        title: ${globalInfo.title}, 
        message: ${globalInfo.message},
      ''');
  });
}
```

## BaseWidget

You can wrap the each widget in **BaseWidget** which listens to:

- **globalFailureProvider**

- **globalLoadingProvider**.

- **globalInfoProvider**

You are required to pass in the **onFailure** and **onGlobalInfo** handlers.

```dart
class BaseWidget extends ConsumerWidget {
  final Widget child;
  final Widget? loadingIndicator;
  final Function(Failure) onFailure;
  final Function(GlobalInfo) onGlobalInfo;

  const BaseWidget({
    required this.child,
    required this.onFailure,
    required this.onGlobalInfo,
    this.loadingIndicator,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<Failure?>(globalFailureProvider, (_, failure) {
      if (failure == null) return;
      onFailure(failure);
    });
    ref.listen<GlobalInfo?>(globalInfoProvider, (_, globalInfo) {
      if (globalInfo == null) return;
      onGlobalInfo(globalInfo);
    });
    final showLoading = ref.watch(globalLoadingProvider);
    return Stack(
      children: [
        child,
        if (showLoading) loadingIndicator ?? const BaseLoadingIndicator(),
      ],
    );
  }
}
```

You can simply wrap each widget with your version of the BaseWidget in the
builder of your MaterialApp:

```dart
ProviderScope(
      child: MaterialApp(
        title: 'Q Architecture',
        builder: (context, child) => Material(
          type: MaterialType.transparency,
          child: MessageDisplayingBaseWidget(child: child),
        ),
      ),
    );
```

## ErrorToFailureMixin

This mixin should reduce the needed boilerplate code for appropriate error
handling in repositories.

It executes the received function within a try-catch block. If an error occurs,
the function calls the errorResolver to handle the caught exception.

### ErrorResolver

Simple abstract interface with a single method for resolving a thrown error into
an appropriate Failure.

```dart
abstract interface class ErrorResolver {
  Failure resolve<T>(Object error, [StackTrace? stackTrace]);
}
```
