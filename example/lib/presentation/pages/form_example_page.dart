//ignore_for_file: always_use_package_imports

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/example_gender.dart';
import '../../domain/notifiers/form_example_state_notifier/form_example_state_notifier.dart';
import '../../forms/example_user_form.dart';

final isNextEnabled = StateProvider<bool>((_) => false);

class FormExamplePage extends ConsumerWidget {
  static const routeName = '/form-example-page';

  final formKey = GlobalKey<FormBuilderState>();
  final List<String> genderList = ['Male', 'Female'];
  final List<String> employeeStatusList = ['Employed', 'Unemployed'];

  FormExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forms'),
      ),
      body: Center(
        child: FormBuilder(
          key: formKey,
          onChanged: () => _refreshNextEnabled(ref),
          child: Column(
            children: [
              FormBuilderTextField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                name: ExampleUserForm.firstNameKey,
                validator: FormBuilderValidators.compose([
                  ExampleUserForm.minLengthName(),
                  ExampleUserForm.maxLengthName(),
                ]),
              ),
              FormBuilderTextField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                name: ExampleUserForm.lastNameKey,
                validator: FormBuilderValidators.compose([
                  ExampleUserForm.minLengthName(),
                  ExampleUserForm.maxLengthName(),
                ]),
              ),
              FormBuilderDateTimePicker(
                name: ExampleUserForm.birthdayKey,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputType: InputType.date,
              ),
              FormBuilderField<String>(
                name: ExampleUserForm.genderKey,
                validator: FormBuilderValidators.compose([
                  ExampleUserForm.isRequired(),
                ]),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                builder: (field) => Column(
                  children: [
                    DropdownButton<String>(
                      items: ExampleGender.values
                          .map((gender) => DropdownMenuItem<String>(
                                value: gender.name,
                                child: Text(gender.name),
                              ))
                          .toList(),
                      selectedItemBuilder: (context) => ExampleGender.values
                          .map((gender) => DropdownMenuItem<String>(
                                value: gender.name,
                                child: Text(gender.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        field.didChange(value);
                      },
                      value: field.value,
                    ),
                    if (field.hasError && !field.isValid)
                      Text(field.errorText!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (formKey.currentState?.saveAndValidate() ?? false) {
            final formMap = formKey.currentState!.value;
            ref.read(formExampleNotifierProvider.notifier).submitForm(formMap);
          } else {
            log('validation failed');
          }
        },
        tooltip: 'Increment',
        child: ref.watch(isNextEnabled)
            ? const Icon(Icons.add)
            : const Icon(Icons.abc_sharp),
      ),
    );
  }

  void _refreshNextEnabled(WidgetRef ref) => WidgetsBinding.instance
      .addPostFrameCallback((_) => ref.read(isNextEnabled.notifier).state =
          formKey.currentState?.isValid ?? false);
}
