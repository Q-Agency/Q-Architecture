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

