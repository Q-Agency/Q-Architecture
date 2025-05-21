# Q-Architecture

A set of reusable classes that should speed up your development time and reduce
unnecessary boilerplate code.

## Get started

- To use Q-Architecture effectively, you must properly set up your service
  locator with GetIt. Start by calling setupServiceLocator() during app
  initialization to register global notifiers (GlobalInfoNotifier,
  GlobalLoadingNotifier and GlobalFailureNotifier). Then register your
  dependencies in logical layers:
  1. Register repositories, services, and mappers as singletons:

```dart
getIt.registerSingleton<YourRepository>(YourRepositoryImplementation());
getIt.registerSingleton<YourService>(YourServiceImplementation());
getIt.registerSingleton<YourMapper>(YourMapperImplementation());
```

2. Register notifiers as lazy singletons with proper disposal and to be able to
   use autoDispose option (additionally explained in [QNotifier](#qnotifier)
   section):

```dart
getIt.registerLazySingleton<YourNotifier>(
  () => YourNotifier(getIt<YourRepository>(), autoDispose: true),
  dispose: (instance) => instance.dispose(),
);
```

- Create your abstract repository and implement it

```dart
abstract class YourRepository {
  EitherFailureOr<String> getYourString();
}

class YourRepositoryImplementation implements YourRepository {
  @override
  EitherFailureOr<String> getYourString() async {
    await Future.delayed(const Duration(seconds: 3));
    if (Random().nextBool()) {
      return const Right('Your string');
    }
    return Left(Failure.generic());
  }
}
```

- Add YourRepository to setupGetIt() method.

````dart
getIt.registerSingleton<YourRepository>(
  YourRepositoryImplementation(),
);
```

- Create your Notifier which extends BaseNotifier and add method to call your
  YourRepository.getYourString() method

```dart
class YourNotifier extends BaseNotifier<String> {
  final YourRepository _yourRepository;

  YourNotifier(this._yourRepository, {super.autoDispose});

  Future getYourString() =>
      execute(
        _yourRepository.getYourString(),
        withLoadingState: true,
        globalLoading: false,
        globalFailure: false,
      );
}
````

- Add YourNotifier to setupGetIt() method.

```dart
getIt.registerLazySingleton<YourNotifier>(
  () => YourNotifier(getIt<YourRepository>(), autoDispose: true),
  dispose: (instance) => instance.dispose(),
);
```

- In your widget call your notifier getYourString() method through your service
  locator and watch the changes through QNotifierBuilder widget

```dart
final yourNotifier = getIt<YourNotifier>();
yourNotifier.getYourString();
return QNotifierBuilder(
  qNotifier: yourNotifier,
  builder: (context, currentState, previousState, child) => Text(
    switch (currentState) {
      Data(data: final sentence) => sentence,
      Loading() => 'Loading',
      Initial() => 'Initial',
      Error(failure: final failure) => failure.toString(),
    }
  )
)
```

That is all you need to get you started, to find out more, head over to the
table of contents.

## Table of contents

- [Example - BaseNotifier](#example---basenotifier)
  - [ExampleNotifier](#examplenotifier)
  - [ExamplePage](#examplepage)
- [Example - Notifier](#example---qnotifier)
  - [ExampleSimpleNotifier](#examplesimplenotifier)
  - [ExampleSimplePage](#examplesimplepage)
- [BaseState<State>](#basestatestate)
- [QNotifier](#qnotifier)
- [BaseNotifier](#basenotifier)
- [QNotifier widgets](#qnotifier-widgets)
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
// in service_locator.dart
getIt.registerLazySingleton<ExampleNotifier>(
  () => ExampleNotifier(getIt<ExampleRepository>(), autoDispose: true),
  dispose: (instance) => instance.dispose(),
);

// in example_notifier.dart
class ExampleNotifier extends BaseNotifier<String> {
 final ExampleRepository _exampleRepository;

 ExampleNotifier(this._exampleRepository, {super.autoDispose});

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
class ExamplePage extends StatelessWidget {
  static const routeName = '/example';

  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final exampleNotifier = getIt<ExampleNotifier>();
    return Scaffold(
      appBar: AppBar(title: Text('Example page')),
      body: ListView(
        children: [
          spacing16,
          QNotifierBuilder(
            notifier: exampleNotifier,
            builder:
                (context, currentState, previousState, child) => Text(
                  switch (currentState) {
                    BaseData(data: final sentence) => sentence,
                    BaseLoading() => 'Loading',
                    BaseInitial() => 'Initial',
                    BaseError(:final failure) => failure.toString(),
                  },
                  style: context.appTextStyles.regular?.copyWith(
                    color: context.appColors.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
          ),
          spacing16,
          TextButton(
            onPressed: exampleNotifier.getSomeStringFullExample,
            child: Text('Get string', style: context.appTextStyles.bold),
          ),
          spacing16,
          TextButton(
            onPressed: exampleNotifier.getSomeStringGlobalLoading,
            child: Text(
              'Global loading example',
              style: context.appTextStyles.bold,
            ),
          ),
          spacing16,
          TextButton(
            onPressed: getIt<ExampleNotifier>().getSomeStringsStreamed,
            child: Text(
              'Cache + Network loading example',
              style: context.appTextStyles.bold,
            ),
          ),
          spacing16,
          TextButton(
            onPressed:
                () => getIt<ExampleFiltersNotifier>().update(
                  'Random ${Random().nextInt(100)}',
                ),
            child: Text(
              'Update filters (to trigger reload of data)',
              style: context.appTextStyles.bold,
            ),
          ),
          spacing16,
          TextButton(
            onPressed: () => QLogger.showLogger(context),
            child: Text('Show log', style: context.appTextStyles.bold),
          ),
          spacing16,
          TextButton(
            onPressed:
                () => context.pushNamed(
                  context.getRouteNameFromCurrentLocation(
                    ExampleSimplePage.routeName,
                  ),
                ),
            child: Text(
              'Go to example simple',
              style: context.appTextStyles.bold,
            ),
          ),
          spacing16,
          TextButton(
            onPressed:
                () => context.pushNamed(
                  context.getRouteNameFromCurrentLocation(
                    FormExamplePage.routeName,
                  ),
                ),
            child: Text(
              'Go to form example',
              style: context.appTextStyles.bold,
            ),
          ),
          spacing16,
          TextButton(
            onPressed:
                () => context.pushNamed(
                  context.getRouteNameFromCurrentLocation(
                    PaginationExamplePage.routeName,
                  ),
                ),
            child: Text('Go to pagination', style: context.appTextStyles.bold),
          ),
          spacing16,
          TextButton(
            onPressed:
                () => context.pushNamed(
                  context.getRouteNameFromCurrentLocation(
                    PaginationStreamExamplePage.routeName,
                  ),
                ),
            child: Text(
              'Go to stream pagination',
              style: context.appTextStyles.bold,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Example - QNotifier

If BaseNotifier restrain you in some way and its BaseState does not cover your
use case, but you want to use some benefits of BaseNotifier, then QNotifier is
here for you.

### ExampleSimpleNotifier

```dart
// in service_locator.dart
getIt.registerLazySingleton<ExampleSimpleNotifier>(
  () => ExampleSimpleNotifier(getIt<ExampleRepository>(), autoDispose: true),
  dispose: (instance) => instance.dispose(),
);

// in example_simple_notifier.dart
class ExampleSimpleNotifier extends QNotifier<ExampleSimpleState> {
  final ExampleRepository _exampleRepository;

  ExampleSimpleNotifier(this._exampleRepository, {super.autoDispose})
    : super(ExampleSimpleState.initial());

  /// Example method when you want to get state updates when calling some repository method
  Future<void> getSomeStringSimpleExample() async {
    await debounce();
    state = ExampleSimpleState.fetching();
    final result = await _exampleRepository.getSomeOtherString();
    result.fold((failure) => state = ExampleSimpleState.error(failure), (data) {
      if (data.isEmpty) {
        state = ExampleSimpleState.empty();
      } else {
        state = ExampleSimpleState.success(data);
      }
    });
  }

  /// Example method when you want to use global loading and global failure methods
  /// when calling some repository method
  Future<void> getSomeStringSimpleExampleGlobalLoading() async {
    showGlobalLoading();
    final result = await _exampleRepository.getSomeOtherString();
    result.fold(setGlobalFailure, (data) {
      clearGlobalLoading();
      if (data.isEmpty) {
        state = ExampleSimpleState.empty();
      } else {
        state = ExampleSimpleState.success(data);
      }
    });
  }
}
```

### Example custom state

```dart
import 'package:equatable/equatable.dart';
import 'package:q_architecture/q_architecture.dart';

sealed class ExampleSimpleState extends Equatable {
  const ExampleSimpleState();

  const factory ExampleSimpleState.initial() = ExampleSimpleStateInitial;

  const factory ExampleSimpleState.empty() = ExampleSimpleStateEmpty;

  const factory ExampleSimpleState.fetching() = ExampleSimpleStateFetching;

  const factory ExampleSimpleState.success(String sentence) =
  ExampleSimpleStateSuccess;

  const factory ExampleSimpleState.error(Failure failure) =
  ExampleSimpleStateError;
}

final class ExampleSimpleStateInitial extends ExampleSimpleState {
  const ExampleSimpleStateInitial();

  @override
  List<Object?> get props => [];
}

final class ExampleSimpleStateEmpty extends ExampleSimpleState {
  const ExampleSimpleStateEmpty();

  @override
  List<Object?> get props => [];
}

final class ExampleSimpleStateFetching extends ExampleSimpleState {
  const ExampleSimpleStateFetching();

  @override
  List<Object?> get props => [];
}

final class ExampleSimpleStateSuccess extends ExampleSimpleState {
  final String data;

  const ExampleSimpleStateSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

final class ExampleSimpleStateError extends ExampleSimpleState {
  final Failure failure;

  const ExampleSimpleStateError(this.failure);

  @override
  List<Object?> get props => [failure];
}
```

### ExampleSimplePage

```dart
class ExampleSimplePage extends StatelessWidget {
  static const routeName = '/simple-page';

  const ExampleSimplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final exampleSimpleNotifier = getIt<ExampleSimpleNotifier>();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QNotifierConsumer(
            qNotifier: exampleSimpleNotifier,
            listener: (context, currentState, previousState) {
              debugPrint(
                'currentState: $currentState, previousState: $previousState',
              );
            },
            builder: (context, currentState, previousState, child) => Column(
              children: [
                Text(
                  switch (currentState) {
                    Initial() => 'Initial',
                    Empty() => 'Empty',
                    Fetching() => 'Fetching',
                    Success(sentence: final string) => string,
                    Error(:final failure) => failure.title,
                  },
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              exampleSimpleNotifier.getSomeStringSimpleExample();
              exampleSimpleNotifier.getSomeStringSimpleExample();
            },
            child: const Text('Simple state example with debounce'),
          ),
          TextButton(
            onPressed:
                exampleSimpleNotifier.getSomeStringSimpleExampleGlobalLoading,
            child: const Text('Global loading example'),
          ),
          ElevatedButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Go back!'),
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

## QNotifier

Abstract QNotifier class which extends ChangeNotifier class which provides some
convenient methods to be used by subclassing it. It can be used when BaseState
doesn't suit you and you need more states, this notifier has
**showGlobalLoading**, **clearGlobalLoading**, **setGlobalFailure**,
**debounce**, **throttle** and **cancelThrottle** methods that are marked as
**@protected** so you can easily use them in your subclasses.

**IMPORTANT**: always register your QNotifier subclasses (including BaseNotifier
as well) as lazy singletons in GetIt with **registerLazySingleton** to be able
to use autoDispose feature when convenient.

- in constructor receives the initial state of the notifier and optionally
  **autoDispose** which defaults to false but if true, the notifier will be
  disposed when all listeners are removed. IMPORTANT: When using
  autoDispose=true, this QNotifier subclass MUST be registered as a
  lazySingleton in GetIt, otherwise an exception will be thrown when attempting
  to reset the lazy singleton

- **listen** adds a listener will be called when the state changes with the
  current and previous state and returns a function that can be called to remove
  the listener

- **removeSpecificListener** removes a specific listener by its ID

- **removeAllListeners** removes all listeners

- **showGlobalLoading** & **clearGlobalLoading** for handling global loading

- **setGlobalFailure** for handling global failure (will automatically call
  **clearGlobalLoading** before showing global failure)

- **debounce** for waiting multiple method calls before only one method call can
  be executed

- **throttle** for executing only first method call for some duration when there
  are multiple method calls

- **cancelThrottle** for canceling throttling if in progress

- **getRandomStringWithTimestamp** generates a random string with a timestamp

## BaseNotifier

Abstract BaseNotifier class which is built on top of QNotifier and uses
BaseState class as its state. It provides all convenient methods like QNotifier
and additionally execute method which will be explained in the next paragraph.

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

```dart
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

```dart
class ExampleNotifier extends BaseNotifier<String> {
//...
Future getSomeStringsStreamed() => executeStreamed(
      _exampleRepository.getSomeStringsStreamed(),
);
```

In repository:

```dart
@override
StreamFailureOr<String> getSomeStringsStreamed() async* {
  yield const Right('Some sentence from cache');
  //...
  yield const Right('Some sentence from network');
}
```

## QNotifier widgets

QNotifier widgets provide a convenient way to consume state changes from
QNotifier instances throughout your application. These widgets handle the
subscription lifecycle automatically and deliver the current and previous states
to your UI through builders, listeners, or a combination of both. They allow you
to create reactive UIs that respond to state changes with minimal boilerplate
code.

### QNotifierBuilder

QNotifierBuilder is a widget that rebuilds its UI when a QNotifier changes
state. It takes a required qNotifier instance to listen to and a builder
function that provides the current state, previous state, and an optional child
widget. The builder pattern allows you to create reactive UI components that
automatically update whenever the underlying state changes.

### QNotifierListener

QNotifierListener is a widget that executes a callback function whenever a
QNotifier changes state. Unlike QNotifierBuilder, it doesn't rebuild the UI but
instead performs side effects like showing dialogs, navigating to different
screens, or updating other parts of your application state. It takes a required
qNotifier instance to listen to and a listener callback that receives the
current state and previous state. This widget is particularly useful for
handling events that should happen in response to state changes without directly
affecting the widget's visual representation.

### QNotifierConsumer

QNotifierConsumer combines the functionality of QNotifierBuilder and
QNotifierListener into a single widget. It allows you to both execute side
effects with a listener callback and rebuild the UI with a builder function in
response to QNotifier state changes. This widget is useful when you need to
perform an action when the state changes (like showing a snackbar) while also
updating the UI to reflect the new state. It simplifies your code by avoiding
the need to nest QNotifierBuilder and QNotifierListener widgets.

## PaginatedStreamNotifier and PaginatedNotifier

Abstract Notifier classes to be used when you need to work with some kind of
list you fetch from local or remote data source.

### PaginatedStreamNotifier

PaginatedStreamNotifier extends QNotifier, uses PaginatedState and provides
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

**GlobalLoadingNotifier** can be used to show the loading indicator without
updating **BaseNotifier** state.

```dart
class GlobalLoadingNotifier extends QNotifier<bool> {
  GlobalLoadingNotifier() : super(false);

  void setGlobalLoading(bool value) => state = value;
}
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

**GlobalFailureNotifier** can be used to show the failure that happened in the
application without updating **BaseNotifier** state.

```dart
class GlobalFailureNotifier extends QNotifier<Failure?> {
  GlobalFailureNotifier() : super(null);

  void setFailure(Failure? failure) => state = failure;
}
```

### Global failure listener

```dart
QNotifierListener(
  qNotifier: GetIt.instance<GlobalFailureNotifier>(),
  onChange: (currentState, previousState) {
    if (currentState == null) return;
    onGlobalFailure(currentState);
  },
  child: ...
)
```

### Failure example

**GlobalFailureNotifier** listener will be triggered by setting
**globalFailure** inside of execute method to **true** when failure happens. If
set to false, instead of updating GlobalFailureNotifier, **BaseNotifier** state
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

**GlobalInfoNotifier** can be used to show any info by passing the info status
with GlobalInfoStatus. GlobalInfoStatus contains values: info, warning, error,
success. Pass the required info status, and message of info that will be
presented to the user. To set GlobalInfo from any notifier, just call
setGlobalInfo() function defined in QNotifier.

Suggestion: setGlobalInfo() can be called from onDataReceived() callback inside
execute() function if there is a need to show alert directly from notifier,
right after request. For any other usage outside of notifier, set the value of
**GlobalInfoNotifier** directly.

```dart
class GlobalInfoNotifier extends QNotifier<GlobalInfo?> {
  GlobalInfoNotifier() : super(null);

  @override
  void setGlobalInfo(GlobalInfo? globalInfo) => state = globalInfo;
}
```

### GlobalInfo listener

```dart
QNotifierListener(
  qNotifier: GetIt.instance<GlobalInfoNotifier>(),
  onChange: (currentState, previousState) {
    if (currentState == null) return;
    onGlobalInfo(currentState);
  },
  child: ...
)
```

## BaseWidget

You can wrap the each widget in **BaseWidget** which listens to:

- **GlobalFailureNotifier**

- **GlobalLoadingNotifier**.

- **GlobalInfoNotifier**

You are required to pass in the **onFailure** and **onGlobalInfo** handlers.

```dart
class BaseWidget extends StatelessWidget {
  final Widget child;
  final Widget? loadingIndicator;
  final Function(Failure failure) onGlobalFailure;
  final Function(GlobalInfo globalInfo) onGlobalInfo;

  const BaseWidget({
    super.key,
    required this.child,
    required this.onGlobalFailure,
    required this.onGlobalInfo,
    this.loadingIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return QNotifierListener(
      qNotifier: GetIt.instance<GlobalFailureNotifier>(),
      onChange: (currentState, previousState) {
        if (currentState == null) return;
        onGlobalFailure(currentState);
      },
      child: QNotifierListener(
        qNotifier: GetIt.instance<GlobalInfoNotifier>(),
        onChange: (currentState, previousState) {
          if (currentState == null) return;
          onGlobalInfo(currentState);
        },
        child: Stack(
          children: [
            child,
            QNotifierBuilder(
              qNotifier: GetIt.instance<GlobalLoadingNotifier>(),
              builder: (context, currentState, previousState, child) {
                if (currentState) {
                  return loadingIndicator ?? const BaseLoadingIndicator();
                }
                return SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

You can simply wrap each widget with your version of the BaseWidget in the
builder of your MaterialApp:

```dart
MaterialApp(
  title: 'Q Architecture',
  builder: (context, child) => Material(
    type: MaterialType.transparency,
    child: MessageDisplayingBaseWidget(child: child),
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
