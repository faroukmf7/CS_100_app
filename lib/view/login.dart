import 'package:cs_100_project/constants.dart';
import 'package:cs_100_project/controller/usercontroller.dart';
import 'package:cs_100_project/view/registeration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Loginpage extends StatelessWidget {
  const Loginpage({super.key});

  @override
  Widget build(BuildContext context) {
    final userControl = Get.put(UserController());

    final _formKey = GlobalKey<FormBuilderState>();

    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    void _submitform() {
      if (_formKey.currentState!.saveAndValidate()) {
        final email = emailController.text;
        final password = passwordController.text;
        userControl.login(email, password);
      } else {
        Get.snackbar("Error", "You need pollute the field");
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("CS 100 classes", style: kheadingB50),
                FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'email',
                        controller: emailController,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      FormBuilderTextField(
                        name: "password",
                        controller: passwordController,
                        validator: FormBuilderValidators.required(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MaterialButton(
                      color: Colors.blue,
                      elevation: 10,
                      onPressed: () {
                        _submitform();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Obx(
                          () => userControl.isLoading.value
                              ? CircularProgressIndicator()
                              : Text('Login'),
                        ),
                      ),
                    ),
                    MaterialButton(
                      child: Text('Or you don\'t have an account' ),
                      shape:  RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.all(
                          Radius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Get.to(RegisterScreen());
                      },
                    ),
                  ],
                ),
                // TextButton(
                //   onPressed: () {
                //     _submitform();
                //   },
                //   child: Obx(
                //     () => userControl.isLoading.value
                //         ? CircularProgressIndicator()
                //         : Text('Login'),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
