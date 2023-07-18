# Q-Architecture

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

- Create your StateNotifier which extends BaseNotifier and add method to call your
  YourRepository.getYourString() method

```dart
class YourStateNotifier extends BaseStateNotifier<String> {
  final YourRepository _yourRepository;

  YourStateNotifier(this._yourRepository, super.ref);

  Future getYourString() =>
      execute(
        _yourRepository.getYourString(),
        withLoadingState: true,
        globalLoading: false,
        globalFailure: false,
      );
}
```

- Create provider for YourStateNotifier using [BaseStateNotifierProvider](#basestatenotifierprovider).

```dart

final yourNotifierProvider = BaseStateNotifierProvider<YourStateNotifier, String>(
      (ref) => YourStateNotifier(ref.watch(repositoryProvider), ref),
); 
```

- In your widget call your notifier getYourString() method through your provider and watch for the
  changes

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

That is all you need to get you started, to find out more, head over to the table of contents.

## Table of contents

- [Example - BaseStateNotifier](#example---basestatenotifier)
    - [ExampleStateNotifier](#examplestatenotifier)
    - [ExamplePage](#examplepage)
- [Example - SimpleStateNotifier](#example---simplestatenotifier)
    - [ExampleSimpleStateNotifier](#examplesimplestatenotifier)
    - [ExampleSimplePage](#examplesimplepage)
- [BaseState<State>](#basestatestate)
- [SimpleStateNotifier](#simplestatenotifier)
- [BaseStateNotifier](#basestatenotifier)
- [PaginatedStreamNotifier and PaginatedNotifier](#paginatedstreamnotifier-and-paginatednotifier)
- [Global loading](#global-loading)
- [Global failure](#global-failure)
- [Global info](#global-info)
- [Navigation](#navigation)
- [BaseWidget](#basewidget)
- [Switch navigation package to AutoRoute package](#switch-navigation-package-to-autoroute-package)
- [Switch navigation package to GoRouter package](#switch-navigation-package-to-go_router-package)

## Example - BaseStateNotifier

BaseStateNotifier is a generic notifier which every notifier should extend to avoid writing 
repetitive code and access global loading and failure handling. Route navigation is also abstracted 
and made easy to use and even switch navigation packages if necessary.

### ExampleStateNotifier

 ```dart

final exampleNotifierProvider = BaseStateNotifierProvider<ExampleStateNotifier, String>(
      (ref) => ExampleStateNotifier(ref.watch(exampleRepositoryProvider), ref),
);

class ExampleStateNotifier extends BaseStateNotifier<String> {
  final ExampleRepository _exampleRepository;

  ExampleStateNotifier(this._exampleRepository, super.ref);

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

        //Set to true if your method gets called more than once in a short period, 
        //with debounceDuration param, default Duration can be changed
        withDebounce: false,

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
          crossAxisAlignment: CrossAxisAlignment.center,
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

## Example - SimpleStateNotifier

If BaseStateNotifier restrain you in some way and its BaseState does not cover your use case, but
you want to use some benefits of BaseNotifier, then SimpleStateNotifier is here for you.

### ExampleSimpleStateNotifier

```dart

final exampleSimpleStateNotifierProvider = StateNotifierProvider<
    ExampleSimpleStateNotifier,
    ExampleSimpleState>(
      (ref) {
    return ExampleSimpleStateNotifier(
      ref.watch(exampleRepositoryProvider),
      ref,
    );
  },
);

class ExampleSimpleStateNotifier extends SimpleStateNotifier<ExampleSimpleState> {
  final ExampleRepository _exampleRepository;

  ExampleSimpleStateNotifier(this._exampleRepository, Ref ref)
      : super(ref, const ExampleSimpleState.initial());

  /// Example method when you want to get state updates when calling some repository method
  Future<void> getSomeStringSimpleExample() async {
    await debounce();
    state = const ExampleSimpleState.fetching();
    final response = await _exampleRepository.getSomeOtherString();
    response.fold(
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
    final response = await _exampleRepository.getSomeOtherString();
    response.fold(
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
  const BaseState();

  const factory BaseState.empty() = Empty;
  const factory BaseState.fetching() = Fetching;
  const factory BaseState.error(Failure failure) = Error;
  const factory BaseState.success(String data) = Success;
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
class ExampleSimplePage extends ConsumerStatefulWidget {
  static const routeName = '/simple-page';

  const ExampleSimplePage({super.key});

  @override
  ConsumerState<ExampleSimplePage> createState() => _ExampleSimplePageState();
}

class _ExampleSimplePageState extends ConsumerState<ExampleSimplePage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exampleSimpleStateNotifierProvider);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            switch(state) {
              Empty() => 'Empty',
              Fetching() => 'Fetching',
              Success(data: final string) => string,
              Error(failure: final failure) => failure.title,
            },
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(exampleSimpleStateNotifierProvider.notifier)
                  .getSomeStringSimpleExample();
              ref
                  .read(exampleSimpleStateNotifierProvider.notifier)
                  .getSomeStringSimpleExample();
            },
            child: const Text('Simple state example with debounce'),
          ),
          TextButton(
            onPressed: ref
                .read(exampleSimpleStateNotifierProvider.notifier)
                .getSomeStringSimpleExampleGlobalLoading,
            child: const Text('Global loading example'),
          ),
          ElevatedButton(
            onPressed: ref.pop,
            child: const Text('Go back!'),
          ),
          TextButton(
            onPressed: () => ref.pushNamed(ExamplePage3.routeName),
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

**State** has to be the same type as the return value from the function that is called

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

## SimpleStateNotifier

Abstract StateNotifier class which provides some convenient methods to be used by subclassing it. It
can be used when BaseState doesn't suit you and you need more states, this notifier has **showGlobalLoading**, 
**clearGlobalLoading**, **setGlobalFailure**, **on** and **debounce** methods that are marked as **@protected** 
so you can easily use them in your subclasses.

* **showGlobalLoading** & **clearGlobalLoading** for handling global loading

* **setGlobalFailure** for handling global failure (will automatically call **clearGlobalLoading**
  before showing global failure)

* **on** for subscribing to another notifier's state changes so you can react appropriately

* **debounce** for waiting multiple method calls before only one method call can be executed

## BaseStateNotifier

Abstract StateNotifier class which extends SimpleStateNotifier, uses BaseState as 
its state and provides some convenient methods to be used by subclassing it.

### Execute method

The main **BaseStateNotifier** method which supports different options for handling the data,
failures and loading.

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

* **function** parameter receives method to execute with return value EitherFailureOr<DataState>.

* **withLoadingState** bool parameter says while calling and waiting **function** to finish, loading
  state should be set.

* **globalLoading** bool parameter says while calling and waiting **function**
  to finish, loading over the the whole app should be shown.

* **globalFailure** bool parameter says if **function** returns Failure, should it be shown globally
  over the whole app or not. &nbsp;

To filter and control which data will update the state, **onDataReceived** callback can be passed.
Alternatively, if callback always return false, custom data handling can be implemented. &nbsp;

To filter and control which failure will update the state or be shown globally, **
onFailureOccurred**
callback can be passed. Similar to **onDataReceived** if always returned false, custom failure
handling can be implemented.

### Execute streamed method

Similar to **BaseStateNotifier**'s **execute** method is the **executeStreamed** method which in the core 
performs the same job as the execute method with a slight difference in that it requires a **function** 
parameter's return type to be of type **Stream** which allows us to return multiple results from the repository
and by doing so we can use this functionality to create an easy to use caching mechanism by yielding
cached data + network data.

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
  class ExampleStateNotifier extends BaseStateNotifier<String> {
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

### BaseStateNotifierProvider

Simple convenience typedef for providing your BaseStateNotifiers:

```dart
typedef BaseStateNotifierProvider<Notifier extends StateNotifier<BaseState<T>>,T>
    = StateNotifierProvider<Notifier, BaseState<T>>;
```

## PaginatedStreamNotifier and PaginatedNotifier
Abstract StateNotifier classes to be used when you need to work with some kind of list
you fetch from local or remote data source.

### PaginatedStreamNotifier
PaginatedStreamNotifier extends SimpleStateNotifier, uses PaginatedState and provides
`PaginatedStreamFailureOr<Entity> getListStreamOrFailure(int page, [Param? parameter])` 
to be overridden by the notifier subclassing it. This notifier works with streams so 
`getListStreamOrFailure` method if necessary can return first list fetched from local 
data source and then from remote data source when retrieved. 

### PaginatedNotifier
PaginatedNotifier extends PaginatedStreamNotifier and simplifies it in a way that class
that extends it needs to override 
`PaginatedEitherFailureOr<Entity> getListOrFailure(int page, [Param? parameter])`
which returns a Future instead of Stream.

### PaginatedList
Methods that need to be overridden by extending PaginatedStreamNotifier or PaginatedNotifier
return PaginatedList object with few convenient field for handling infinite lists.
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
parameter serves if you still want to show on the screen all the list data fetched
until that moment.

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
or PaginatedNotifier and display the data served through one of those two notifiers.

## Global loading

**globalLoadingProvider** can be used to show the loading indicator without updating
**BaseStateNotifier** state.

```dart

final globalLoadingProvider = StateProvider<bool>((_) => false);
```

### Loading example

**BaseLoadingIndicator** can be shown by setting **globalLoading** inside of execute method to
**true**

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

**globalFailureProvider** can be used to show the failure that happened in the application without
updating **BaseStateNotifier** state.

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

**globalFailureProvider** listener will be triggered by setting **globalFailure** inside of execute
method to **true** when failure happens. If set to false, instead of updating globalFailureProvider,
**BaseStateNotifier** state will be set to error so the failure can be shown directly on the screen,
not in the overlay as a toast or a dialog.

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

**globalInfoProvider** can be used to show any info by passing the info status with GlobalInfoStatus. GlobalInfoStatus contains values: info, warning, error, success.
Pass the required info status, and message of info that will be presented to the user. To set GlobalInfo from any notifier,
just call setGlobalInfo() function defined in SimpleStateNotifier.

Suggestion: setGlobalInfo() can be called from onDataReceived() callback inside execute() function if there is a need to show alert directly from notifier, right after request.
For any other usage outside of notifier, set the value of **globalInfoProvider** directly.


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

## Navigation

**globalNavigationProvider** with **RouteAction** type can be used to execute push, pop and similar
navigation actions. Navigation can be used directly by updating **globalNavigationProvider** or by
using extension on WidgetRef class which initially provides **pushNamed**,
**pushReplacementNamed** and **pop** methods.
**BaseWidget** registers listener for **globalNavigationProvider** and therefore any change
triggers **execute** method of **RouteAction** object.

### Global navigation listener

```dart
void globalNavigationListener() {
  listen<RouteAction?>(
    globalNavigationProvider,
        (_, state) => state?.execute(read(baseRouterProvider)),
  );
}
```

To navigate from current to the next page it can be done like this:

```
ref.pushNamed(nextPageRouteName);
```

or to pop back to previous page:

```
ref.pop();
```

With pushNamed and pushReplacementNamed methods, optional **data** parameter can be passed 
containing some data that you might want to pass to the next screen. To read that data on 
the next screen (data can be shared within the same BeamLocation) **getData** method can be 
called on the BaseRouter class:
```
ref.read(baseRouterProvider).getData
```

If more navigation actions are necessary, RouteAction can be subclassed with desired action and new
method can be added into BaseStateNotifier that will use that class. Also, BaseRouter can be
expanded with new navigation method and then implemented in the descendant class which will be used
in RouteAction descendant class.

Default navigation package being used is **Beamer** and in **baseRouterProvider** its BaseRouter
subclass BeamerRouter is being instantiated.

If necessary, by making few changes navigation package can be easily switched to **AutoRoute**,
**GoRouter** or probably any other navigation package but here short notes will be provided for only
two mentioned alternatives to Beamer.

## BaseWidget

You can wrap the entire app in **BaseWidget** which listens to:

* **globalFailureProvider**

* **globalNavigationProvider**

* **globalLoadingProvider**.

* **globalInfoProvider**

```dart

class BaseWidget extends ConsumerWidget {
  final Widget child;

  const BaseWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // if you need context to showDialog or bottomSheet, use BaseRouter's navigatorContext because main context
    // won't work as BaseWidget is the first widget in builder method of MaterialApp.router so Navigator is not ready yet.
    // Be careful not to use it directly in build method (it is not ready yet), but in button callback or within 
    // WidgetsBinding.instance.addPostFrameCallback.
    // final navigatorContext = ref.read(baseRouterProvider).navigatorContext;
    ref.globalFailureListener();
    ref.globalNavigationListener();
    ref.globalInfoListener();
    final showLoading = ref.watch(globalLoadingProvider);
    return Stack(
      children: [
        child,
        if (showLoading) const BaseLoadingIndicator(),
      ],
    );
  }
}
```

## Switch navigation package to AutoRoute package

1. add auto_route dependency to pubspec.yaml
2. create app_router.dart file, define AppRouter class with options defined in its documentation
3. (including generating .gr.dart file by running **flutter packages pub run build_runner build**
   in terminal)
4. create **AppRouterRouter** class in **base_router.dart** and override BaseRouter's navigation
   methods, it can look something like this:

  ```
  class AppRouterRouter extends BaseRouter {
    AppRouterRouter({required super.routerDelegate, required super.routeInformationParser, super.router});

    @override
    void pushNamed(String routeName, {dynamic data}) {
      (router as AppRouter).pushNamed(routeName);
    }
  
    ...
  }
  ```

5. update **baseRouterProvider** in **base_router_provider.dart** to use **AppRouterRouter**
   class instead of **BeamerRouter**
6. remove **BeamerProvider** widget from **main.dart**

&nbsp;

## Switch navigation package to go_router package:

1. add go_router dependency to pubspec.yaml

2. create **GoRouterRouter** class in **base_router.dart** and override BaseRouter's navigation
   methods, it can look something like this:
      ```
      class GoRouterRouter extends BaseRouter {
        GoRouterRouter({
          required super.routerDelegate,
          required super.routeInformationParser,
          super.routeInformationProvider,
          super.router,
        });
      
        @override
        void pushNamed(String routeName, {dynamic data}) {
          (router as GoRouter).push(routeName, extra: data);
        }
      
        ...
      }
      ```
3. update **baseRouterProvider** in **base_router_provider.dart** to use **GoRouterRouter** class
   instead of **BeamerRouter**

  ```
  final baseRouterProvider = StateProvider<BaseRouter>((ref) {
    final goRouter = GoRouter(
      routes: <GoRoute>[
        ...
      ],
    );
    return GoRouterRouter(
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      routeInformationProvider: goRouter.routeInformationProvider,
      router: goRouter,
    );
  });
  ```

4. remove **BeamerProvider** widget from **main.dart**
