//ignore_for_file: always_use_package_imports

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:q_architecture/q_architecture.dart';

import '../../../forms/example_user_form.dart';
import '../../entities/example_user.dart';

final formExampleNotifierProvider =
    StateNotifierProvider<FormExampleStateNotifier, String>(
  (ref) => FormExampleStateNotifier(
    ref.watch(exampleUserFormMapperProvider),
    ref,
  ),
);

class FormExampleStateNotifier extends SimpleStateNotifier<String> {
  final FormMapper<ExampleUser> _userFormMapper;

  FormExampleStateNotifier(this._userFormMapper, Ref ref) : super(ref, '');

  void submitForm(Map<String, dynamic> formMap) {
    final user = _userFormMapper(formMap);
    // ignore: avoid_print
    print('Sending user to API: $user');
  }
}
