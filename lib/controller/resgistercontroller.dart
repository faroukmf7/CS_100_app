import 'dart:convert';

import 'package:cs_100_project/constants.dart';
import 'package:cs_100_project/controller/usercontroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class Resgistercontroller extends GetxController {
  final formkey = GlobalKey<FormBuilderState>();

  final counter = 0.obs;
  final emailController = TextEditingController();
  final fNameController = TextEditingController();
  final sNameController = TextEditingController();
  final mNameController = TextEditingController();
  final studentIdController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final seePass = false.obs;

  void seePassword() {
    seePass.value = !seePass.value;
  }

  Future<void> register() async {
    isLoading.value = true;
    final email = emailController.text.trim();
    final fName = fNameController.text.trim();
    final sName = sNameController.text.trim();
    final mName = mNameController.text.trim();
    final password = passwordController.text.trim();
    final studentId = studentIdController.text.trim();
    try {
      final response = await http.post(
        Uri.parse('${endpoint}register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fname': fName,
          'sname': sName,
          'email': email,
          'mname': mName,
          'password':password,
          'studentID':studentId
        }),
      );
     final data =jsonDecode(response.body);
      if (data['status']==false){
        Get.snackbar('Error creating account', data['message']);
        isLoading.value=false;
      }else{
        final userCtrl = Get.put(UserController());
        await userCtrl.login(email, password);

      }
    } catch (exception) {
       Get.snackbar("internal error", 'please contact the admin ${exception}');
       isLoading.value=false;
    }
  }

  void nextStep() {
    if (counter == 2) {
      if (!formkey.currentState!.saveAndValidate()) return;
      final formdata = formkey.currentState?.value;
      if (!(formdata?['password'] == formdata?['passConfirm'])) {
        Get.snackbar(
          'Password mismatch',
          'Your passwords do not match',
          duration: Duration(seconds: 4),
          snackStyle: SnackStyle.FLOATING,
        );
        return;
      }
      register();
    } else {
      counter.value++;
    }
  }

  void stepTap(int step) {
    counter.value = step;
  }

  void stepCancel() {
    if (counter.value > 0) {
      counter.value--;
    } else {
      return;
    }
  }
}
