import 'dart:convert';

import 'package:cs_100_project/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class UserController extends GetxController {
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;

  final baseURL = 'http://localhost/test/';

  Future<void> login(String email, String password) async {
    try {
      final responds = await http.post(
        Uri.parse('${baseURL}login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email':email,'password':password})
      );
      if (responds.statusCode == 200){
        debugPrint("success");

      }
    } catch (e) {
      print("error: $e");
    }
  }
}
