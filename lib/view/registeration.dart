import 'package:cs_100_project/constants.dart';
import 'package:cs_100_project/controller/resgistercontroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resController = Get.put(Resgistercontroller());
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FormBuilder(
          key: resController.formkey,
          child: Obx(
            () => Stepper(
              controlsBuilder: (context, details) {
                return Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Row(
                    children: [
                      // Back button
                      if (resController.counter.value > 0)
                        TextButton(
                          onPressed: resController.isLoading.value ? null : details.onStepCancel,
                          child: const Text('Back'),
                        ),

                      const Spacer(),

                      // Next / Register button with loading
                      ElevatedButton(
                        onPressed: resController.isLoading.value ? null : details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 50),
                        ),
                        child: resController.isLoading.value
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          resController.counter.value == 2 ? 'Create Account' : 'Next',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ));
              },
              steps: [
                Step(
                  title: Text("Email and Student ID"),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          name: 'email',
                          controller: resController.emailController,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.email(),
                            FormBuilderValidators.required(),
                          ]),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: kroundfield,
                          ),
                        ),
                        SizedBox(height: 10),
                        FormBuilderTextField(
                          name: 'studentID',
                          controller: resController.studentIdController,
                          validator: FormBuilderValidators.required(),
                          decoration: InputDecoration(
                            labelText: 'Student ID',
                            border: kroundfield,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Step(
                  title: Text('Full Name'),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          name: 'fname',
                          controller: resController.fNameController,
                          validator: FormBuilderValidators.required(),
                          decoration: InputDecoration(
                            labelText: 'first name',
                            border: kroundfield,
                          ),
                        ),
                        SizedBox(height: 10),
                        FormBuilderTextField(
                          name: 'sname',
                          controller: resController.sNameController,
                          decoration: InputDecoration(
                            labelText: 'Surname',
                            border: kroundfield,
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                        SizedBox(height: 10),
                        FormBuilderTextField(
                          name: 'mnane',
                          controller: resController.mNameController,
                          decoration: InputDecoration(
                            labelText: 'Middle name(optional)',
                            border: kroundfield,
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                      ],
                    ),
                  ),
                ),
                Step(
                  title: Text("Pasword"),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          name: 'password',
                          controller: resController.passwordController,
                          obscureText: resController.seePass.value,
                          decoration: InputDecoration(
                            suffixIcon:GestureDetector(
                              child: resController.seePass.value
                                  ? Icon(Icons.remove_red_eye)
                                  : Icon(Icons.remove_red_eye_outlined),
                              onTap: resController.seePassword,
                            ),
                            labelText: 'Password',
                            border: kroundfield,
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.password(),
                          ]),
                        ),
                        SizedBox(height: 10),
                        FormBuilderTextField(
                          obscureText: resController.seePass.value,
                          name: 'passConfirm',
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              child: resController.seePass.value
                                  ? Icon(Icons.remove_red_eye)
                                  : Icon(Icons.remove_red_eye_outlined),
                              onTap: resController.seePassword,
                            ),
                            labelText: 'Confirm Password',
                            border: kroundfield,
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              currentStep: resController.counter.value,
              onStepContinue: resController.nextStep,
              onStepTapped: (step) => resController.stepTap(step),
              onStepCancel: resController.stepCancel,
            ),
          ),
        ),
      ),
    );
  }
}
